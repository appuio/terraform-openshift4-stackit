terraform {
  required_providers {
    cloudscale = {
      source  = "terraform-providers/cloudscale"
      version = ">= 2.2"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 2.1"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.3"
    }
  }
  required_version = ">= 0.13"
}
