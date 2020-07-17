terraform {
  backend "s3" {
    key                         = "tf/"
    endpoint                    = "https://objects.rma.cloudscale.ch"
    region                      = "us-east-1" # Ignored
    skip_credentials_validation = true
    skip_metadata_api_check     = true
  }
}
