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

data "oci_load_balancer_load_balancers" "yuzu_lb" {
    compartment_id = local.root_compartment_id
    display_name = "ff8fa28a-63b4-43c4-99c6-49dc39d46ccb"
}
