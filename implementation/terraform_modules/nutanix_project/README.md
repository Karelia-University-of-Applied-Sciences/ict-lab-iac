# nutanix_project Module

Creates and manages a Nutanix project with cluster and subnet assignments.

## Usage

```hcl
module "project" {
  source = "../modules/nutanix_project"

  cluster_uuid        = "<CLUSTER_UUID>"
  default_subnet_uuid = "<SUBNET_UUID>"
  project_name        = "my-project"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `cluster_uuid` | UUID of the cluster assigned to the project | `string` | — | yes |
| `default_subnet_uuid` | UUID of the default subnet assigned to the project | `string` | — | yes |
| `project_name` | Name of the Nutanix project | `string` | — | yes |
| `project_description` | Description for the project; defaults to `project_name` when null | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| `project_id` | ID of the created Nutanix project |
| `project_name` | Name of the created Nutanix project |
