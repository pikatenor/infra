terraform {
  required_providers {
    vultr = {
      source  = "vultr/vultr"
      version = "2.19.0"
    }
  }
  cloud {
    organization = "pikatenor"
    workspaces {
      name = "vultr"
    }
  }
}

provider "vultr" {
  api_key = var.vultr_api_key
}
