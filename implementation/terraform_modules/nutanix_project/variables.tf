variable "cluster_uuid" {
  description = "UUID of the cluster assigned to the project"
  type        = string
}

variable "default_subnet_uuid" {
  description = "UUID of the default subnet assigned to the project"
  type        = string
}

variable "project_description" {
  description = "Description for the Nutanix project; defaults to project_name when null"
  type        = string
  default     = null
}

variable "project_name" {
  description = "Name of the Nutanix project"
  type        = string
}