output "instance_private_ip" {
  value = oci_core_instance.vm.private_ip
}

output "instance_id" {
  value = oci_core_instance.vm.id
}