terraform {
  required_version = ">= 0.14"
  required_providers {
    cloudscale = {
      source = "terraform-providers/cloudscale"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}
