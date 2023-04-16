locals {
  root_compartment_id = "ocid1.tenancy.oc1..aaaaaaaaxfprp3257tv44dwtyturey2g7l6uxiwdv5ha6g55wqxzsubvwmyq"

  vcn_cidrs = {
    yotsuboshi = [
      "10.10.0.0/16"
    ]
    yotsuboshi_public1  = "10.10.0.0/24"
    yotsuboshi_private1 = "10.10.1.0/24"
    yotsuboshi_oke      = "10.10.9.0/24"
  }

  diff_k8s_ingress_rule_port = [
    10256,
    31486,
    32292,
  ]
}
