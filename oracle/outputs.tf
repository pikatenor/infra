output "yuzu_lb_ip_addr" {
  value = data.oci_load_balancer_load_balancers.yuzu_lb.load_balancers[0].ip_address_details[0].ip_address
}

output "yuzu_k8sapi_ip_addr" {
  value = split(":", oci_containerengine_cluster.oke25.endpoints[0].public_endpoint)[0]
}
