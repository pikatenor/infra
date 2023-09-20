resource "hcloud_server" "this" {
  name        = var.name
  server_type = var.server_type
  datacenter  = "fsn1-dc14"

  firewall_ids = var.firewall_ids

  # Image is ignored, as we boot into rescue mode, but is a required field
  image    = "fedora-37"
  rescue   = "linux64"
  ssh_keys = [data.hcloud_ssh_key.ssh-key.id]

  connection {
    host    = hcloud_server.this.ipv4_address
    timeout = "5m"
    agent   = true
    # Root is the available user in rescue mode
    user = "root"
  }

  # Copy config.yaml
  provisioner "file" {
    content     = file("${path.module}/ignition.fcc.yml")
    destination = "/root/ignition.fcc.yml"
  }

  # Copy coreos-installer binary, as initramfs has not sufficient space to compile it in rescue mode
  provisioner "file" {
    source      = "${path.module}/coreos-installer.${local.coreos_installer_version}"
    destination = "/usr/local/bin/coreos-installer"
  }

  # Install Fedora CoreOS in rescue mode
  provisioner "remote-exec" {
    inline = [
      "set -x",
      # Convert ignition yaml into json using butane
      "wget -O /usr/local/bin/butane 'https://github.com/coreos/butane/releases/download/v${local.butane_version}/butane-x86_64-unknown-linux-gnu'",
      "chmod +x /usr/local/bin/butane",
      "butane < ignition.fcc.yml > ignition.ign",
      # coreos-installer binary is copied, if you have sufficient RAM available, you can also uncomment the following
      # two lines and comment-out the `chmod +x` line, to build coreos-installer in rescue mode
      # "apt install cargo",
      # "cargo install coreos-installer",
      "chmod +x /usr/local/bin/coreos-installer",
      # Download and install Fedora CoreOS to /dev/sda
      "coreos-installer install /dev/sda -i /root/ignition.ign",
      # Exit rescue mode and boot into coreos
      "reboot"
    ]
  }
}

resource "hcloud_server_network" "this" {
  server_id  = hcloud_server.this.id
  network_id = var.network_id
  ip         = var.private_ip_addr
}

resource "hcloud_rdns" "this" {
  server_id  = hcloud_server.this.id
  ip_address = hcloud_server.this.ipv4_address
  dns_ptr    = "${var.name}.sr0.dev"
}
