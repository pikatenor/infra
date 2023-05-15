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

resource "oci_core_subnet" "public-subnet" {
  compartment_id    = local.root_compartment_id
  vcn_id            = module.vcn.vcn_id
  cidr_block        = local.vcn_cidrs.yotsuboshi_public1
  route_table_id    = module.vcn.ig_route_id
  security_list_ids = [oci_core_security_list.public-security-list.id]
  display_name      = "public-subnet"
}

resource "oci_core_subnet" "private-subnet" {
  compartment_id             = local.root_compartment_id
  vcn_id                     = module.vcn.vcn_id
  prohibit_public_ip_on_vnic = true
  cidr_block                 = local.vcn_cidrs.yotsuboshi_private1
  route_table_id             = module.vcn.nat_route_id
  security_list_ids          = [oci_core_security_list.private-security-list.id]
  display_name               = "private-subnet"
}

resource "oci_core_subnet" "oke-api-subnet" {
  compartment_id    = local.root_compartment_id
  vcn_id            = module.vcn.vcn_id
  cidr_block        = local.vcn_cidrs.yotsuboshi_oke
  route_table_id    = module.vcn.ig_route_id
  security_list_ids = [oci_core_security_list.oke-api-security-list.id]
  display_name      = "oke-k8sApiEndpoint-subnet-yuzu-regional"
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
  ingress_security_rules {
    description = "k8s worker internal"
    stateless   = false
    source      = local.vcn_cidrs.yotsuboshi_private1
    source_type = "CIDR_BLOCK"
    protocol    = "all"
  }
  ingress_security_rules {
    description = "to kube-proxy from LB"
    stateless   = false
    source      = local.vcn_cidrs.yotsuboshi_public1
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    tcp_options {
      min = 10256
      max = 10256
    }
  }
  ingress_security_rules {
    description = "to k8s from LB"
    stateless   = false
    source      = local.vcn_cidrs.yotsuboshi_public1
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    tcp_options {
      min = 30000
      max = 32767
    }
  }

  # to surpress plan diff
  dynamic "ingress_security_rules" {
    for_each = toset(local.diff_k8s_ingress_rule_port)
    content {
      description = null
      stateless   = false
      source      = local.vcn_cidrs.yotsuboshi_public1
      source_type = "CIDR_BLOCK"
      protocol    = "6"
      tcp_options {
        min = ingress_security_rules.value
        max = ingress_security_rules.value
      }
    }
  }
  ingress_security_rules {
    stateless   = false
    source      = local.vcn_cidrs.yotsuboshi_oke
    source_type = "CIDR_BLOCK"
    protocol    = "6"
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
  egress_security_rules {
    description      = "from LB to kube-proxy"
    destination      = local.vcn_cidrs.yotsuboshi_private1
    destination_type = "CIDR_BLOCK"
    protocol         = "6"
    stateless        = false
    tcp_options {
      max = 10256
      min = 10256
    }
  }
  egress_security_rules {
    description      = "from LB to k8s"
    destination      = local.vcn_cidrs.yotsuboshi_private1
    destination_type = "CIDR_BLOCK"
    protocol         = "6"
    stateless        = false
    tcp_options {
      min = 30000
      max = 32767
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
  ingress_security_rules {
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    tcp_options {
      min = 80
      max = 80
    }
  }
  ingress_security_rules {
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    tcp_options {
      min = 443
      max = 443
    }
  }

  # to surpress plan diff
  dynamic "egress_security_rules" {
    for_each = toset(local.diff_k8s_ingress_rule_port)
    content {
      stateless        = false
      destination      = local.vcn_cidrs.yotsuboshi_private1
      destination_type = "CIDR_BLOCK"
      protocol         = "6"
      tcp_options {
        min = egress_security_rules.value
        max = egress_security_rules.value
      }
    }
  }
}

resource "oci_core_security_list" "oke-api-security-list" {
  compartment_id = local.root_compartment_id
  vcn_id         = module.vcn.vcn_id
  display_name   = "oke-k8sApiEndpoint-seclist-yuzu"
  egress_security_rules {
    description      = "Allow Kubernetes Control Plane to communicate with OKE"
    destination      = "all-nrt-services-in-oracle-services-network"
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol         = "6"
    stateless        = false
    tcp_options {
      max = 443
      min = 443
    }
  }
  ingress_security_rules {
    description = "External access to Kubernetes API endpoint"
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false
    tcp_options {
      max = 6443
      min = 6443
    }
  }

  ingress_security_rules {
    stateless   = false
    source      = local.vcn_cidrs.yotsuboshi_private1
    source_type = "CIDR_BLOCK"
    protocol    = "1"
    icmp_options {
      type = 3
      code = 4
    }
  }
  ingress_security_rules {
    protocol    = "6"
    source      = local.vcn_cidrs.yotsuboshi_private1
    source_type = "CIDR_BLOCK"
    stateless   = false
    tcp_options {
      max = 12250
      min = 12250
    }
  }
  egress_security_rules {
    destination      = local.vcn_cidrs.yotsuboshi_private1
    destination_type = "CIDR_BLOCK"
    protocol         = "6"
    stateless        = false
  }
}

resource "oci_containerengine_cluster" "oke25" {
  compartment_id     = local.root_compartment_id
  kubernetes_version = "v1.25.4"
  name               = "yuzu"
  vcn_id             = module.vcn.vcn_id

  endpoint_config {
    is_public_ip_enabled = true
    nsg_ids              = []
    subnet_id            = oci_core_subnet.oke-api-subnet.id
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
      fault_domains = [
        data.oci_identity_fault_domains.fds.fault_domains[0].name,
        data.oci_identity_fault_domains.fds.fault_domains[1].name,
      ]
    }
    size = 2
  }
  node_shape = "VM.Standard.A1.Flex"
  node_shape_config {
    memory_in_gbs = 12
    ocpus         = 2
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

resource "oci_objectstorage_bucket" "rancher-backup" {
  #Required
  compartment_id = local.root_compartment_id
  name           = "rancher-backup"
  namespace      = data.oci_objectstorage_namespace.ns.namespace
}
resource "oci_identity_group" "rancher-backup-access" {
  compartment_id = local.root_compartment_id
  name           = "ObjectStorageAccess-rancher-backup"
  description    = "user group for rancher-backup"
}
resource "oci_identity_user_group_membership" "rancher-backup-s3-user-backup-access" {
  group_id = oci_identity_group.rancher-backup-access.id
  user_id  = oci_identity_user.rancher-backup-s3-user.id
}
resource "oci_identity_user" "rancher-backup-s3-user" {
  compartment_id = local.root_compartment_id
  description    = "user for rancher-backup-s3"
  name           = "rancher-backup-s3-user"
}
#resource "oci_identity_customer_secret_key" "rancher-backup-s3-user-key" {
#  display_name = "s3-key"
#  user_id      = oci_identity_user.rancher-backup-s3-user.id
#}
resource "oci_identity_user_capabilities_management" "rancher-backup-s3-user" {
  user_id                      = oci_identity_user.rancher-backup-s3-user.id
  can_use_api_keys             = "false"
  can_use_auth_tokens          = "false"
  can_use_console_password     = "false"
  can_use_customer_secret_keys = "true"
  can_use_smtp_credentials     = "false"
}
resource "oci_identity_policy" "rancher-backup-policy" {
  compartment_id = local.root_compartment_id
  name           = "ObjectStorageAccess-rancher-backup-policy"
  description    = "allow bucket access to ObjectStorageAccess-rancher-backup user group"
  statements = [
    "Allow group ObjectStorageAccess-rancher-backup to read buckets in tenancy",
    join("", [
      "Allow group ObjectStorageAccess-rancher-backup to manage objects in tenancy ",
      "where all {",
      "any { request.permission='OBJECT_CREATE', request.permission='OBJECT_INSPECT' }, ",
      "target.bucket.name='rancher-backup'",
      "}",
    ])
  ]
}
