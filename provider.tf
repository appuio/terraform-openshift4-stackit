terraform {
  required_version = ">= 1.3.0"
  required_providers {
    stackit = {
      source  = "stackitcloud/stackit"
      version = "0.49.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 2.1"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.3"
    }
    gitfile = {
      source  = "igal-s/gitfile"
      version = "1.0.0"
    }
  }
}

provider "stackit" {
  default_region = var.region
}
