data "oci_identity_availability_domains" "ads" {
  compartment_id = local.root_compartment_id
}
