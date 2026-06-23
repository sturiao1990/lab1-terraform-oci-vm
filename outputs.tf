output "instance_public_ip" {
  description = "IP público da VM"
  value       = oci_core_instance.vm_lab.public_ip
}

output "instance_private_ip" {
  description = "IP privado da VM"
  value       = oci_core_instance.vm_lab.private_ip
}

output "instance_id" {
  description = "OCID da VM"
  value       = oci_core_instance.vm_lab.id
}