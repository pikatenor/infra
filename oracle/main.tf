module "vcn" {
  source  = "oracle-terraform-modules/vcn/oci"
  version = "3.5.3"

  compartment_id = local.root_compartment_id
  region         = "ap-tokyo-1"

  label_prefix  = "yotsuboshi"
  vcn_dns_label = "yotsuboshi"
  vcn_cidrs     = local.vcn_cidrs.yotsuboshi

  create_internet_gateway = true
  create_nat_gateway      = true
  create_service_gateway  = true

  internet_gateway_route_rules = null
  local_peering_gateways       = null
  nat_gateway_route_rules      = null

}

resource "oci_core_security_list" "private-security-list" {
  compartment_id = local.root_compartment_id
  vcn_id         = module.vcn.vcn_id
  display_name   = "security-list-for-private-subnet"

  egress_security_rules {
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }
  ingress_security_rules {
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "1"
    icmp_options {
      type = 3
      code = 4
    }
  }
  dynamic "ingress_security_rules" {
    for_each = toset(local.vcn_cidrs.yotsuboshi)
    content {
      stateless   = false
      source      = ingress_security_rules.value
      source_type = "CIDR_BLOCK"
      protocol    = "1"
      icmp_options {
        type = 3
      }
    }
  }
  dynamic "ingress_security_rules" {
    for_each = toset(local.vcn_cidrs.yotsuboshi)
    content {
      stateless   = false
      source      = ingress_security_rules.value
      source_type = "CIDR_BLOCK"
      protocol    = "6"
      tcp_options {
        min = 22
        max = 22
      }
    }
  }
}

resource "oci_core_security_list" "public-security-list" {
  compartment_id = local.root_compartment_id
  vcn_id         = module.vcn.vcn_id
  display_name   = "security-list-for-public-subnet"

  egress_security_rules {
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }
  ingress_security_rules {
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "1"
    icmp_options {
      type = 3
      code = 4
    }
  }
  dynamic "ingress_security_rules" {
    for_each = toset(local.vcn_cidrs.yotsuboshi)
    content {
      stateless   = false
      source      = ingress_security_rules.value
      source_type = "CIDR_BLOCK"
      protocol    = "1"
      icmp_options {
        type = 3
      }
    }
  }

  ingress_security_rules {
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    tcp_options {
      min = 22
      max = 22
    }
  }
}

resource "oci_core_subnet" "public-subnet" {
  compartment_id    = local.root_compartment_id
  vcn_id            = module.vcn.vcn_id
  cidr_block        = "10.10.0.0/24"
  route_table_id    = module.vcn.ig_route_id
  security_list_ids = [oci_core_security_list.public-security-list.id]
  display_name      = "public-subnet"
}

resource "oci_core_subnet" "private-subnet" {
  compartment_id             = local.root_compartment_id
  vcn_id                     = module.vcn.vcn_id
  prohibit_public_ip_on_vnic = true
  cidr_block                 = "10.10.1.0/24"
  route_table_id             = module.vcn.nat_route_id
  security_list_ids          = [oci_core_security_list.private-security-list.id]
  display_name               = "private-subnet"
}

resource "oci_containerengine_cluster" "oke25" {
  compartment_id     = local.root_compartment_id
  kubernetes_version = "v1.25.4"
  name               = "yuzu"
  vcn_id             = module.vcn.vcn_id

  endpoint_config {
    is_public_ip_enabled = true
    nsg_ids              = []
    subnet_id            = oci_core_subnet.public-subnet.id
  }


  options {
    add_ons {
      is_kubernetes_dashboard_enabled = false
      is_tiller_enabled               = false
    }
    kubernetes_network_config {
      pods_cidr     = "10.244.0.0/16"
      services_cidr = "10.96.0.0/16"
    }
    service_lb_subnet_ids = [oci_core_subnet.public-subnet.id]
  }
}

resource "oci_containerengine_node_pool" "oke25-node-pool" {
  cluster_id         = oci_containerengine_cluster.oke25.id
  compartment_id     = local.root_compartment_id
  kubernetes_version = "v1.25.4"

  name = "yuzu-pool1"

  node_config_details {
    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
      subnet_id           = oci_core_subnet.private-subnet.id
    }
    size = 1
  }
  node_shape = "VM.Standard.A1.Flex"
  node_shape_config {
    memory_in_gbs = 8
    ocpus         = 1
  }
  node_source_details {
    # Oracle-Linux-8.7-aarch64-2023.01.31-3-OKE-1.25.4-549
    image_id    = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaad6dof5conwtja4eqhl5wvwzlsveixwnkt7spgpwqmjzan6umkr3a"
    source_type = "image"
  }

  ssh_public_key = file("~/.ssh/OC.pub")

  initial_node_labels {
    key   = "name"
    value = "yuzu-node"
  }
}
