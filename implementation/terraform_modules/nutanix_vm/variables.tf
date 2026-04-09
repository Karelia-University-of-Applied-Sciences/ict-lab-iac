variable "admin_users" {
  description = "Admin users (ansible, deploy, etc) with SSH or password"
  type = list(object({
    name     = string
    password = optional(string, "")
    ssh_keys = optional(list(string), [])
  }))
  default = []
}

variable "additional_users" {
  description = "Regular users with optional sudo access and SSH/password"
  type = list(object({
    name     = string
    password = optional(string, "")
    ssh_keys = optional(list(string), [])
    sudo     = optional(bool, false)
  }))
  default = []
}

variable "cluster_id" {
  description = "Cluster external ID where the VM will be created"
  type        = string
}

variable "disk_size_gb" {
  description = "Size of SCSI boot disk in GB"
  type        = number
}

variable "image_uuid" {
  description = "UUID of the image/ISO attached to the VM"
  type        = string
}

variable "memory_size_gb" {
  description = "Memory size in GB"
  type        = number
}

variable "ngt_iso_uuid" {
  description = "UUID of NGT ISO for guest tools installation (optional)"
  type        = string
  default     = ""
}

variable "num_cores_per_socket" {
  description = "Number of CPU cores per socket"
  type        = number
}

variable "num_sockets" {
  description = "Number of CPU sockets"
  type        = number
}

variable "power_state" {
  description = "Initial power state of the VM (ON or OFF)"
  type        = string
}

variable "project_id" {
  description = "Project external ID for VM placement (optional; omit to create VM outside any project)"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Subnet external ID for the VM NIC"
  type        = string
}

variable "ubuntu_password" {
  description = "Password for ubuntu admin user"
  sensitive   = true
  type        = string
  default     = ""
}

variable "ubuntu_ssh_keys" {
  description = "SSH keys for ubuntu user"
  type        = list(string)
  default     = []
}

variable "vm_name" {
  description = "Name of the VM"
  type        = string
}

