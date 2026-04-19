terraform {
  required_providers {
    nutanix = {
      source  = "nutanix/nutanix"
      version = "2.3.4"
    }
    ansible = {
      source  = "ansible/ansible"
      version = "1.4.0"
    }
  }
}

# insecure = true: Prism Central uses a self-signed certificate in this lab environment;
# TLS verification is intentionally disabled as a known deviation from policy.
provider "nutanix" {
  endpoint     = var.nutanix_endpoint
  insecure     = true
  password     = var.nutanix_password
  port         = var.nutanix_port
  session_auth = true
  username     = var.nutanix_username
  wait_timeout = 10
}

module "project" {
  source = "../../terraform_modules/nutanix_project"

  cluster_uuid        = var.cluster_uuid
  default_subnet_uuid = var.default_subnet_uuid
  project_name        = var.project_name
}

module "vms" {
  depends_on = [module.project]
  for_each   = { for user in var.users : user.name => user }

  source = "../../terraform_modules/nutanix_vm"

  cluster_id           = local.cluster_id
  disk_size_gb         = var.disk_size_gb
  image_uuid           = var.image_uuid
  memory_size_gb       = var.memory_size_gb
  ngt_iso_uuid         = var.ngt_iso_uuid
  num_cores_per_socket = var.num_cores_per_socket
  num_sockets          = var.num_sockets
  power_state          = var.power_state
  project_id           = local.project_id
  subnet_id            = local.subnet_id

  ubuntu_password  = var.ubuntu_password
  ubuntu_ssh_keys  = var.ubuntu_ssh_keys
  admin_users      = var.admin_users

  additional_users            = [each.value]
  additional_users_expiredate = var.additional_users_expiredate

  vm_name = "${var.vm_name_prefix}-${each.key}"
}

resource "ansible_host" "vm" {
  for_each = module.vms
  name     = each.value.vm_name
  groups   = ["task2_vms"]
  variables = {
    ansible_host      = each.value.primary_ipv4
    ansible_user      = "ansible"
    db_admin_user     = each.key
    db_admin_password = each.value.user_password
  }
}