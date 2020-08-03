module "infra" {
  source = "./modules/node-group"

  cluster_id       = var.cluster_id
  region           = var.region
  role             = "infra"
  node_count       = var.infra_count
  node_name_suffix = local.node_name_suffix
  image_slug       = var.image_slug
  flavor_slug      = var.infra_flavor
  subnet_uuid      = cloudscale_subnet.privnet_subnet.id
  ignition_ca      = var.ignition_ca
  api_int          = "api-int.${local.node_name_suffix}"
}
