module "worker" {
  source = "./modules/node-group"

  stackit_project_id = var.stackit_project_id
  ssh_key_name       = local.ssh_key_name
  region             = var.region
  role               = "worker"
  node_count         = var.worker_count
  node_name_suffix   = local.node_name_suffix
  image_id           = var.image_id
  machine_type       = var.worker_type
  volume_size_gb     = local.worker_volume_size_gb
  network_id         = local.subnet_uuid
  security_group_ids = [stackit_security_group.cluster_sg.security_group_id]
  ignition_ca        = var.ignition_ca
  api_int            = "api-int.${local.node_name_suffix}"
  cluster_id         = var.cluster_id
}

// Additional worker groups.
// Configured from var.additional_worker_groups
module "additional_worker" {
  for_each = var.additional_worker_groups

  source = "./modules/node-group"

  stackit_project_id = var.stackit_project_id
  ssh_key_name       = local.ssh_key_name
  region             = var.region
  role               = each.key
  node_count         = each.value.count
  node_name_suffix   = local.node_name_suffix
  image_id           = var.image_id
  machine_type       = each.value.type
  volume_size_gb     = each.value.volume_size_gb != null ? each.value.volume_size_gb : local.worker_volume_size_gb
  network_id         = local.subnet_uuid
  security_group_ids = [stackit_security_group.cluster_sg.security_group_id]
  ignition_ca        = var.ignition_ca
  api_int            = "api-int.${local.node_name_suffix}"
  cluster_id         = var.cluster_id
}
