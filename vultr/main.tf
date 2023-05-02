resource "vultr_instance" "starlight20" {
  region            = "nrt"
  plan              = "vc2-2c-2gb"
  os_id             = 391 // Fedora CoreOS Stable
  label             = "starlight20(Rin)"
  hostname          = "rin"
  backups           = "disabled"
  ddos_protection   = false
  firewall_group_id = vultr_firewall_group.default.id
  vpc_ids           = [vultr_vpc.hnd3.id]
  user_data         = file("ignition.ign")
}

resource "vultr_instance" "starlight21" {
  region            = "nrt"
  plan              = "vc2-1c-1gb"
  os_id             = 391 // Fedora CoreOS Stable
  label             = "starlight21(Madoka)"
  hostname          = "madoka"
  backups           = "disabled"
  ddos_protection   = false
  firewall_group_id = vultr_firewall_group.default.id
  vpc_ids           = [vultr_vpc.hnd3.id]
  user_data         = file("ignition.ign")
}

resource "vultr_instance" "starlight22" {
  region            = "nrt"
  plan              = "vc2-1c-1gb"
  os_id             = 391 // Fedora CoreOS Stable
  label             = "starlight22(Juri)"
  hostname          = "juri"
  backups           = "disabled"
  ddos_protection   = false
  firewall_group_id = vultr_firewall_group.default.id
  vpc_ids           = [vultr_vpc.hnd3.id]
  user_data         = file("ignition.ign")
}

resource "vultr_reverse_ipv4" "starlight20" {
  instance_id = vultr_instance.starlight20.id
  ip          = vultr_instance.starlight20.main_ip
  reverse     = "starlight20.sr0.dev"
}

resource "vultr_reverse_ipv4" "starlight21" {
  instance_id = vultr_instance.starlight21.id
  ip          = vultr_instance.starlight21.main_ip
  reverse     = "starlight21.sr0.dev"
}

resource "vultr_reverse_ipv4" "starlight22" {
  instance_id = vultr_instance.starlight22.id
  ip          = vultr_instance.starlight22.main_ip
  reverse     = "starlight22.sr0.dev"
}
