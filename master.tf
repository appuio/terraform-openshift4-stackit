module "master" {
  source = "./modules/node-group"

  stackit_project_id = var.stackit_project_id
  ssh_key_name       = local.ssh_key_name
  region             = var.region
  role               = "master"
  ignition_config    = "master"
  node_count         = var.master_count
  node_name_suffix   = local.node_name_suffix
  image_id           = var.image_id
  machine_type       = var.master_type
  volume_size_gb     = var.default_volume_size_gb
  network_id         = local.subnet_uuid
  security_group_ids = [stackit_security_group.cluster_sg.security_group_id]
  ignition_ca        = var.ignition_ca
  api_int            = "api-int.${local.node_name_suffix}"
  cluster_id         = var.cluster_id
}
