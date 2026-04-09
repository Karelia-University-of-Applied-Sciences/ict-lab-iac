terraform {
  required_providers {
    nutanix = {
      source = "nutanix/nutanix"
    }
  }
}

resource "nutanix_project" "this" {
  api_version          = "3.1"
  name                 = var.project_name
  description          = local.effective_project_description
  use_project_internal = false

  cluster_reference_list {
    kind = "cluster"
    uuid = var.cluster_uuid
  }

  subnet_reference_list {
    kind = "subnet"
    uuid = var.default_subnet_uuid
  }

  default_subnet_reference {
    kind = "subnet"
    uuid = var.default_subnet_uuid
  }
}