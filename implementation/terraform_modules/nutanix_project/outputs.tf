output "project_id" {
  description = "ID of the created Nutanix project"
  value       = nutanix_project.this.id
}

output "project_name" {
  description = "Name of the created Nutanix project"
  value       = nutanix_project.this.name
}