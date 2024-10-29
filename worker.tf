module "worker" {
  source = "./modules/node-group"

  region                     = var.region
  role                       = "worker"
  node_count                 = var.worker_count
  node_name_suffix           = local.node_name_suffix
  image_slug                 = var.image_slug
  flavor_slug                = var.worker_flavor
  volume_size_gb             = local.worker_volume_size_gb
  subnet_uuid                = local.subnet_uuid
  ignition_ca                = var.ignition_ca
  api_int                    = "api-int.${local.node_name_suffix}"
  cluster_id                 = var.cluster_id
  make_adoptable_by_provider = var.make_worker_adoptable_by_provider
}

// Additional worker groups.
// Configured from var.additional_worker_groups
module "additional_worker" {
  for_each = var.additional_worker_groups

  source = "./modules/node-group"

  region                     = var.region
  role                       = each.key
  node_count                 = each.value.count
  node_name_suffix           = local.node_name_suffix
  image_slug                 = var.image_slug
  flavor_slug                = each.value.flavor
  volume_size_gb             = each.value.volume_size_gb != null ? each.value.volume_size_gb : local.worker_volume_size_gb
  subnet_uuid                = local.subnet_uuid
  ignition_ca                = var.ignition_ca
  api_int                    = "api-int.${local.node_name_suffix}"
  cluster_id                 = var.cluster_id
  make_adoptable_by_provider = var.make_worker_adoptable_by_provider
}
