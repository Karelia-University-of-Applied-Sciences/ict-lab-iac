output "vm_info" {
  description = "Map of VM name to its primary IPv4 address"
  value = {
    for _, vm in module.vms :
    vm.vm_name => vm.primary_ipv4
  }
}

output "server_vm" {
  description = "Server VM name to its primary IPv4 address"
  value = {
    (module.server_vm.vm_name) = module.server_vm.primary_ipv4
  }
}

output "project_info" {
  description = "Project details"
  value = {
    id   = module.project.project_id
    name = module.project.project_name
  }
}
