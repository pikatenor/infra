module "vcn" {
  source  = "oracle-terraform-modules/vcn/oci"
  version = "3.5.3"

  compartment_id = local.root_compartment_id
  region         = "ap-tokyo-1"

  vcn_name      = "yotsuboshi"
  vcn_dns_label = "yotsuboshi"
  label_prefix  = "yotsuboshi"
  vcn_cidrs     = ["10.10.0.0/16"]

  create_internet_gateway = true
  create_nat_gateway      = true
  create_service_gateway  = true

  internet_gateway_route_rules = null
  local_peering_gateways       = null
  nat_gateway_route_rules      = null

}
