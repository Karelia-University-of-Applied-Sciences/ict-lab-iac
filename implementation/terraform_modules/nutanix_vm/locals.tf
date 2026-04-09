locals {
  # Build ubuntu user object
  ubuntu_user = {
    name     = "ubuntu"
    ssh_keys = var.ubuntu_ssh_keys
    password = var.ubuntu_password
    sudo     = true
  }

  # Build admin users list from admin_users variable
  admin_users_list = [
    for admin in var.admin_users : {
      name     = admin.name
      ssh_keys = admin.ssh_keys
      password = admin.password
      sudo     = true
    }
  ]

  # Build additional users list from additional_users variable
  additional_users_list = [
    for user in var.additional_users : {
      name     = user.name
      ssh_keys = user.ssh_keys
      password = user.password
      sudo     = user.sudo
    }
  ]

  # Render cloud-init template with user objects
  cloud_init_yaml = templatefile(
    "${path.module}/cloud-init.tftpl",
    {
      admin_users_list      = local.admin_users_list
      additional_users_list = local.additional_users_list
      ubuntu_user           = local.ubuntu_user
      vm_name               = var.vm_name
    }
  )

  # Base64 encode for Nutanix guest customization API
  cloud_init_user_data = base64encode(local.cloud_init_yaml)
}
