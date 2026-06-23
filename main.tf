terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

# ============================================================
# VCN (Rede Virtual)
# ============================================================
resource "oci_core_vcn" "vcn_lab" {
  compartment_id = var.compartment_ocid
  display_name   = "vcn-lab-terraform"
  cidr_block     = "10.0.0.0/16"
  dns_label      = "vcnlab"
}

# ============================================================
# Internet Gateway
# ============================================================
resource "oci_core_internet_gateway" "igw_lab" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn_lab.id
  display_name   = "igw-lab-terraform"
  enabled        = true
}

# ============================================================
# Route Table
# ============================================================
resource "oci_core_route_table" "rt_lab" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn_lab.id
  display_name   = "rt-lab-terraform"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.igw_lab.id
  }
}

# ============================================================
# Security List (libera SSH e ping)
# ============================================================
resource "oci_core_security_list" "sl_lab" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn_lab.id
  display_name   = "sl-lab-terraform"

  ingress_security_rules {
    protocol  = "6" # TCP
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol  = "1" # ICMP
    source    = "0.0.0.0/0"
    stateless = false
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    stateless   = false
  }
}

# ============================================================
# Subnet
# ============================================================
resource "oci_core_subnet" "subnet_lab" {
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.vcn_lab.id
  display_name      = "subnet-lab-terraform"
  cidr_block        = "10.0.1.0/24"
  dns_label         = "subnetlab"
  route_table_id    = oci_core_route_table.rt_lab.id
  security_list_ids = [oci_core_security_list.sl_lab.id]
}

# ============================================================
# Busca o Availability Domain disponível
# ============================================================
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# ============================================================
# Busca a imagem Oracle Linux mais recente
# ============================================================
data "oci_core_images" "oracle_linux" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = "VM.Standard.E4.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# ============================================================
# VM
# ============================================================
resource "oci_core_instance" "vm_lab" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = "vm-lab-terraform"
  shape               = "VM.Standard.E4.Flex"

  shape_config {
    ocpus         = 1
    memory_in_gbs = 8
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.oracle_linux.images[0].id
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.subnet_lab.id
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
}
