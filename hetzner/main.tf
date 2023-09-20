resource "hcloud_network" "dream" {
  name     = "dream"
  ip_range = local.dream_private_ip_range
}
resource "hcloud_network_subnet" "dream" {
  network_id   = hcloud_network.dream.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = local.dream_private_ip_range
}

resource "hcloud_firewall" "default" {
  name = "default"

  rule {
    direction = "in"
    protocol  = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  dynamic "rule" {
    for_each = toset([
      "80",
      "443",
      "8080",
      "8443",
      "5000-5050",
      "30022",
    ])
    content {
      direction = "in"
      protocol  = "tcp"
      port      = rule.key
      source_ips = [
        "0.0.0.0/0",
        "::/0"
      ]
    }
  }
}

module "dream0" {
  source          = "./instance"
  name            = "dream0"
  server_type     = "cx21" # 2 Intel vCPUs, 4GB
  ssh_key_id      = "11083624"
  network_id      = hcloud_network.dream.id
  firewall_ids    = [hcloud_firewall.default.id]
  private_ip_addr = "192.168.35.2"
}
