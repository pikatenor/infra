resource "vultr_firewall_group" "default" {
  description = "default"
}

resource "vultr_firewall_rule" "accept-icmp" {
  firewall_group_id = vultr_firewall_group.default.id
  ip_type           = "v4"
  protocol          = "icmp"
  subnet            = "0.0.0.0"
  subnet_size       = 0
}
resource "vultr_firewall_rule" "accept-ssh" {
  firewall_group_id = vultr_firewall_group.default.id
  ip_type           = "v4"
  port              = "22"
  protocol          = "tcp"
  subnet            = "0.0.0.0"
  subnet_size       = 0
}
resource "vultr_firewall_rule" "accept-http" {
  firewall_group_id = vultr_firewall_group.default.id
  ip_type           = "v4"
  port              = "80"
  protocol          = "tcp"
  subnet            = "0.0.0.0"
  subnet_size       = 0
}
resource "vultr_firewall_rule" "accept-https" {
  firewall_group_id = vultr_firewall_group.default.id
  ip_type           = "v4"
  port              = "443"
  protocol          = "tcp"
  subnet            = "0.0.0.0"
  subnet_size       = 0
}
resource "vultr_firewall_rule" "accept-http-alt" {
  firewall_group_id = vultr_firewall_group.default.id
  ip_type           = "v4"
  port              = "8080"
  protocol          = "tcp"
  subnet            = "0.0.0.0"
  subnet_size       = 0
}
resource "vultr_firewall_rule" "accept-https-alt" {
  firewall_group_id = vultr_firewall_group.default.id
  ip_type           = "v4"
  port              = "8443"
  protocol          = "tcp"
  subnet            = "0.0.0.0"
  subnet_size       = 0
}
resource "vultr_firewall_rule" "accept-tcp5000" {
  firewall_group_id = vultr_firewall_group.default.id
  ip_type           = "v4"
  port              = "5000:5050"
  protocol          = "tcp"
  subnet            = "0.0.0.0"
  subnet_size       = 0
  notes             = "nandemo"
}
resource "vultr_firewall_rule" "accept-http-alt2" {
  firewall_group_id = vultr_firewall_group.default.id
  ip_type           = "v4"
  port              = "8081:8089"
  protocol          = "tcp"
  subnet            = "0.0.0.0"
  subnet_size       = 0
}
resource "vultr_firewall_rule" "accept-ssh-gitea" {
  firewall_group_id = vultr_firewall_group.default.id
  ip_type           = "v4"
  port              = "30022"
  protocol          = "tcp"
  subnet            = "0.0.0.0"
  subnet_size       = 0
  notes             = "gitea ssh"
}
resource "vultr_firewall_rule" "accept-sshv6" {
  firewall_group_id = vultr_firewall_group.default.id
  ip_type           = "v6"
  port              = "22"
  protocol          = "tcp"
  subnet            = "::"
  subnet_size       = 0
}
