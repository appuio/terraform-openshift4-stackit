module "master" {
  source = "./modules/node-group"

  region           = var.region
  role             = "master"
  ignition_config  = "master"
  node_count       = var.master_count
  node_name_suffix = local.node_name_suffix
  image_slug       = var.image_slug
  flavor_slug      = "plus-16-4"
  subnet_uuid      = local.subnet_uuid
  ignition_ca      = var.ignition_ca
  api_int          = "api-int.${local.node_name_suffix}"
}
