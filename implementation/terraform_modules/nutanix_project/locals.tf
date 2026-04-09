locals {
  effective_project_description = coalesce(var.project_description, var.project_name)
}
