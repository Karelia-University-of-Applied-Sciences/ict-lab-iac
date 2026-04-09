terraform {
  required_providers {
    nutanix = {
      source = "nutanix/nutanix"
    }
  }
}

resource "nutanix_virtual_machine_v2" "this" {
  name = var.vm_name

  cluster {
    ext_id = var.cluster_id
  }

  memory_size_bytes    = var.memory_size_gb * pow(1024, 3)
  num_cores_per_socket = var.num_cores_per_socket
  num_sockets          = var.num_sockets
  power_state          = var.power_state

  # Boot disk (SCSI)
  disks {
    disk_address {
      bus_type = "SCSI"
      index    = 0
    }
    backing_info {
      vm_disk {
        data_source {
          reference {
            image_reference {
              image_ext_id = var.image_uuid
            }
          }
        }
        disk_size_bytes = var.disk_size_gb * pow(1024, 3)
      }
    }
  }

  # Optional NGT ISO (CD-ROM on SATA)
  dynamic "cd_roms" {
    for_each = var.ngt_iso_uuid != "" ? [1] : []
    content {
      disk_address {
        bus_type = "SATA"
        index    = 1
      }
      backing_info {
        data_source {
          reference {
            image_reference {
              image_ext_id = var.ngt_iso_uuid
            }
          }
        }
      }
    }
  }

  # Boot configuration
  boot_config {
    legacy_boot {
      boot_order = ["DISK", "CDROM", "NETWORK"]
    }
  }

  # Guest customization (always add - at least ubuntu user)
  guest_customization {
    config {
      cloud_init {
        cloud_init_script {
          user_data {
            value = local.cloud_init_user_data
          }
        }
      }
    }
  }

  nics {
    network_info {
      nic_type = "NORMAL_NIC"
      subnet {
        ext_id = var.subnet_id
      }
      vlan_mode = "ACCESS"
    }
  }

  dynamic "project" {
    for_each = var.project_id != null ? [1] : []
    content {
      ext_id = var.project_id
    }
  }

  lifecycle {
    ignore_changes = [
      guest_customization,
      cd_roms
    ]
  }
}
