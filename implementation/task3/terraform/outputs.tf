output "ca_vm" {
  description = "CA VM name and its primary IPv4 address"
  value = {
    (module.ca_vm.vm_name) = module.ca_vm.primary_ipv4
  }
}

output "lb_vm" {
  description = "Load balancer VM name and its primary IPv4 address"
  value = {
    (module.lb_vm.vm_name) = module.lb_vm.primary_ipv4
  }
}

output "project_info" {
  description = "Project details"
  value = {
    id   = module.project.project_id
    name = module.project.project_name
  }
}

output "web_vms" {
  description = "Map of web VM name to its primary IPv4 address"
  value = {
    for _, vm in module.web_vms :
    vm.vm_name => vm.primary_ipv4
  }
}
