terraform {
  required_providers {
    ansible = {
      source  = "ansible/ansible"
      version = "1.4.0"
    }
    nutanix = {
      source  = "nutanix/nutanix"
      version = "2.3.4"
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

# VM 1: Root CA server — holds the CA key and signs CSRs from all other VMs
module "ca_vm" {
  depends_on = [module.project]

  source = "../../terraform_modules/nutanix_vm"

  admin_users          = var.admin_users
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
  ubuntu_ssh_keys      = var.ubuntu_ssh_keys

  vm_name = "${var.vm_name_prefix}-ca"
}

resource "ansible_host" "ca" {
  name   = module.ca_vm.vm_name
  groups = ["task3_ca"]
  variables = {
    ansible_host = module.ca_vm.primary_ipv4
    ansible_user = "ansible"
  }
}

# VM 2: Nginx load balancer — HTTPS (443), CA-signed cert, round-robin proxy to web VMs
module "lb_vm" {
  depends_on = [module.project]

  source = "../../terraform_modules/nutanix_vm"

  admin_users          = var.admin_users
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
  ubuntu_ssh_keys      = var.ubuntu_ssh_keys

  vm_name = "${var.vm_name_prefix}-lb"
}

resource "ansible_host" "lb" {
  name   = module.lb_vm.vm_name
  groups = ["task3_lb"]
  variables = {
    ansible_host = module.lb_vm.primary_ipv4
    ansible_user = "ansible"
  }
}

# VMs 3+: Web servers — HTTPS (443), CA-signed certs, each serves a unique page
# To scale out: add more names to var.web_server_names in infra.auto.tfvars,
# then run terraform apply followed by ansible-playbook site.yml
module "web_vms" {
  depends_on = [module.project]
  for_each   = toset(var.web_server_names)

  source = "../../terraform_modules/nutanix_vm"

  admin_users          = var.admin_users
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
  ubuntu_ssh_keys      = var.ubuntu_ssh_keys

  vm_name = "${var.vm_name_prefix}-${each.key}"
}

resource "ansible_host" "web" {
  for_each = module.web_vms
  name     = each.value.vm_name
  groups   = ["task3_web"]
  variables = {
    ansible_host = each.value.primary_ipv4
    ansible_user = "ansible"
    # Injected into index.html so each server identifies itself in round-robin responses
    server_name = each.key
  }
}
