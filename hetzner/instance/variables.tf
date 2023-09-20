variable "name" {
  type = string
}

variable "server_type" {
  type = string
}

variable "ssh_key_id" {
  type = string
}

variable "network_id" {
  type = string
}

variable "firewall_ids" {
  type = list(string)
}

variable "private_ip_addr" {
  type = string
}
