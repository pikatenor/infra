terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.47.0"
    }
  }
  cloud {
    organization = "pikatenor"
    workspaces {
      name = "hetzner"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}
