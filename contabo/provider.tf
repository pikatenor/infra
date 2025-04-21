terraform {
  required_providers {
    contabo = {
      source  = "contabo/contabo"
      version = ">= 0.1.31"
    }
  }
  cloud {
    organization = "pikatenor"
    workspaces {
      name = "contabo"
    }
  }
}

provider "contabo" {
  oauth2_client_id     = var.api_credential.oauth2_client_id
  oauth2_client_secret = var.api_credential.oauth2_client_secret
  oauth2_user          = var.api_credential.oauth2_user
  oauth2_pass          = var.api_credential.oauth2_pass
}
