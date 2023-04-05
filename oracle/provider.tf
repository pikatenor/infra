terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

provider "oci" {
  tenancy_ocid     = local.root_compartment_id
  user_ocid        = var.user_ocid
  private_key_path = var.api_rsa_key.private_key_path
  fingerprint      = var.api_rsa_key.fingerprint
  region           = "ap-tokyo-1"
}
