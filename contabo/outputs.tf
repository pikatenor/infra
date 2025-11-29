output "starlight30_ip_addr" {
  value = [for i in contabo_instance.starlight30.ip_config : i.v4][0][0].ip
}

output "starlight30_ipv6_addr" {
  value = [for i in contabo_instance.starlight30.ip_config : i.v6][0][0].ip
}

output "starlight31_ip_addr" {
  value = [for i in contabo_instance.starlight31.ip_config : i.v4][0][0].ip
}

output "starlight31_ipv6_addr" {
  value = [for i in contabo_instance.starlight31.ip_config : i.v6][0][0].ip
}

output "starlight32_ip_addr" {
  value = [for i in contabo_instance.starlight32.ip_config : i.v4][0][0].ip
}

output "starlight32_ipv6_addr" {
  value = [for i in contabo_instance.starlight32.ip_config : i.v6][0][0].ip
}
