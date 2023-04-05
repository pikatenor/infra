locals {
  root_compartment_id = "ocid1.tenancy.oc1..aaaaaaaaxfprp3257tv44dwtyturey2g7l6uxiwdv5ha6g55wqxzsubvwmyq"

  vcn_cidrs = {
    yotsuboshi = [
      "10.10.0.0/16"
    ]
  }
}
