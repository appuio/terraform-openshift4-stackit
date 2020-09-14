terraform {
  required_providers {
    cloudscale = {
      source = "terraform-providers/cloudscale"
    }
    random = {
      source = "hashicorp/random"
    }
  }
  required_version = ">= 0.13"
}
