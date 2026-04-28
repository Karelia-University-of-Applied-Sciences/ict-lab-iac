resource "nutanix_virtual_machine_v2" "vm" {
  name = var.name

  cluster {
    ext_id = var.cluster_ext_id
  }

  num_cores_per_socket = var.num_cores_per_socket
  num_sockets          = var.num_sockets
}
