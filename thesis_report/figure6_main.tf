resource "nutanix_virtual_machine_v2" "vm1" {
  name = "example-vm1"
  cluster {
    ext_id = "000622f6-5ec8-d3d7-3fc4-0025b500001f"
  }
  
  num_cores_per_socket = 1
  num_sockets          = 1
}