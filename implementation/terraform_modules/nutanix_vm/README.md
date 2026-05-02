# nutanix_vm Module

Provisions a Nutanix VM with cloud-init user management using the Nutanix v4 API.
Supports a default ubuntu user, shared admin users, and per-VM additional users.

## Usage

```hcl
module "vm" {
  source = "../modules/nutanix_vm"

  vm_name    = "my-vm"
  cluster_id = "<CLUSTER_EXT_ID>"
  subnet_id  = "<SUBNET_EXT_ID>"
  image_uuid = "<IMAGE_EXT_ID>"
  # project_id = "<PROJECT_EXT_ID>"  # optional; omit to create VM outside any project

  disk_size_gb         = 20
  memory_size_gb       = 2
  num_sockets          = 1
  num_cores_per_socket = 2
  power_state          = "ON"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `admin_users` | Shared admin users on all VMs (e.g. ansible, deploy) | `list(object)` | `[]` | no |
| `additional_users` | Per-VM regular users with optional sudo and expiry date | `list(object)` | `[]` | no |
| `additional_users_expiredate` | Default expiry date for all additional users (`YYYY-MM-DD`); overridden per user; empty string disables expiry | `string` | `""` | no |
| `cluster_id` | Cluster external ID where the VM will be created | `string` | — | yes |
| `disk_size_gb` | Boot disk size in GB | `number` | — | yes |
| `image_uuid` | UUID of the image to boot | `string` | — | yes |
| `memory_size_gb` | Memory size in GB | `number` | — | yes |
| `ngt_iso_uuid` | UUID of the NGT ISO for guest tools installation | `string` | `""` | no |
| `num_cores_per_socket` | CPU cores per socket | `number` | — | yes |
| `num_sockets` | Number of CPU sockets | `number` | — | yes |
| `power_state` | Initial power state (`ON` or `OFF`) | `string` | — | yes |
| `project_id` | Project external ID for VM placement; omit to create VM outside any project | `string` | `null` | no |
| `subnet_id` | Subnet external ID for the VM NIC | `string` | — | yes |
| `ubuntu_password` | Password for the default ubuntu user | `string` | `""` | no |
| `ubuntu_ssh_keys` | SSH public keys for the ubuntu user | `list(string)` | `[]` | no |
| `vm_name` | Name of the VM | `string` | — | yes |

### additional_users object

| Field | Description | Type | Default | Required |
|-------|-------------|------|---------|----------|
| `name` | Username | `string` | — | yes |
| `expiredate` | Account expiry date in `YYYY-MM-DD` format; account is locked after this date | `string` | `""` | no |
| `password` | Login password | `string` | `""` | no |
| `ssh_keys` | SSH public keys | `list(string)` | `[]` | no |
| `sudo` | Grant passwordless sudo | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| `vm_id` | Unique identifier of the created VM |
| `vm_name` | Name of the VM |
| `primary_ipv4` | Primary IPv4 address assigned to the VM's NIC |
