# ---------------------------------------------------------------------------
# Provider Variables
# ---------------------------------------------------------------------------

variable "nutanix_endpoint" {
  description = "Nutanix Prism Central endpoint"
  type        = string
}

variable "nutanix_password" {
  description = "Nutanix password"
  sensitive   = true
  type        = string
}

variable "nutanix_port" {
  description = "Nutanix API port"
  type        = number
  default     = 9440
}

variable "nutanix_username" {
  description = "Nutanix username"
  type        = string
}

# ---------------------------------------------------------------------------
# Infrastructure Variables
# ---------------------------------------------------------------------------

variable "cluster_uuid" {
  description = "UUID of the cluster used for project and VM placement"
  type        = string
}

variable "default_subnet_uuid" {
  description = "UUID of the subnet used for project and VM placement"
  type        = string
}

variable "project_name" {
  description = "Name of the Nutanix project to create and use for VM placement"
  type        = string
}

# ---------------------------------------------------------------------------
# VM Variables
# ---------------------------------------------------------------------------

variable "admin_users" {
  description = "Shared admin users on all VMs (ansible, deploy, etc)"
  type = list(object({
    name     = string
    password = optional(string, "")
    ssh_keys = optional(list(string), [])
  }))
  default = []
}

variable "disk_size_gb" {
  description = "Size of the SCSI boot disk in GB"
  type        = number
}

variable "image_uuid" {
  description = "UUID of the image to boot on VMs"
  type        = string
}

variable "memory_size_gb" {
  description = "Memory size in GB"
  type        = number
  default     = 1
}

variable "ngt_iso_uuid" {
  description = "UUID of the NGT ISO for guest tools installation"
  type        = string
  default     = ""
}

variable "num_cores_per_socket" {
  description = "Number of cores per CPU socket"
  type        = number
  default     = 1
}

variable "num_sockets" {
  description = "Number of CPU sockets"
  type        = number
  default     = 1
}

variable "power_state" {
  description = "Initial power state of the VM (ON or OFF)"
  type        = string
  default     = "OFF"
}

variable "ubuntu_ssh_keys" {
  description = "SSH keys for ubuntu admin on all VMs"
  type        = list(string)
  default     = []
}

variable "vm_name_prefix" {
  description = "Prefix for VM names"
  type        = string
}

# ---------------------------------------------------------------------------
# Task3-specific Variables
# ---------------------------------------------------------------------------

variable "web_server_names" {
  description = "Names of the web server VMs; each name gets one VM added to the LB pool. Add names to scale out."
  type        = list(string)
  default     = ["web1", "web2"]
}
