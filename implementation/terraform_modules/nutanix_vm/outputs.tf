output "primary_ipv4" {
  description = "Primary IPv4 address assigned to the VM's primary NIC"
  value       = try(nutanix_virtual_machine_v2.this.nics[0].network_info[0].ipv4_config[0].ip_address[0].value, "")
}

output "vm_id" {
  description = "Unique identifier of the created VM resource"
  value       = nutanix_virtual_machine_v2.this.id
}

output "vm_name" {
  description = "Name of the VM as passed to the module"
  value       = nutanix_virtual_machine_v2.this.name
}
