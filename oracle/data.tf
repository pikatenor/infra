data "oci_identity_availability_domains" "ads" {
  compartment_id = local.root_compartment_id
}

data "oci_identity_fault_domains" "fds" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = local.root_compartment_id
}

data "oci_objectstorage_namespace" "ns" {
  compartment_id = local.root_compartment_id
}
