variable "cluster_ext_id" {
  description = "The ext_id of the Nutanix cluster to deploy the VM on."
  type        = string
}

variable "name" {
  description = "The name of the virtual machine."
  type        = string
}

variable "num_cores_per_socket" {
  default     = 1
  description = "The number of CPU cores per socket."
  type        = number
}

variable "num_sockets" {
  default     = 1
  description = "The number of CPU sockets."
  type        = number
}
