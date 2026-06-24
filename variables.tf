variable "tenancy_ocid" {
  description = "OCID do Tenancy OCI"
  type        = string
}

variable "user_ocid" {
  description = "OCID do usuário OCI"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint da chave de API OCI"
  type        = string
}

variable "private_key_path" {
  description = "Caminho para a chave privada OCI"
  type        = string
}

variable "region" {
  description = "Região OCI"
  type        = string
  default     = "sa-saopaulo-1"
}

variable "compartment_ocid" {
  description = "OCID do compartment onde a VM será criada"
  type        = string
}

variable "ssh_public_key" {
  description = "Chave pública SSH para acesso à VM"
  type        = string
}

variable "ad_index" {
  description = "Indice do Availability Domain a usar (0, 1 ou 2)"
  type        = number
  default     = 0
}