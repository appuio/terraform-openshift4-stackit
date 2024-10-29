module "infra" {
  source = "./modules/node-group"

  region                     = var.region
  role                       = "infra"
  node_count                 = var.infra_count
  node_name_suffix           = local.node_name_suffix
  image_slug                 = var.image_slug
  flavor_slug                = var.infra_flavor
  volume_size_gb             = var.default_volume_size_gb
  subnet_uuid                = local.subnet_uuid
  ignition_ca                = var.ignition_ca
  api_int                    = "api-int.${local.node_name_suffix}"
  cluster_id                 = var.cluster_id
  make_adoptable_by_provider = var.make_worker_adoptable_by_provider
}
