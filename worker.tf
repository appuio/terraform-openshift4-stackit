module "worker" {
  source = "./modules/node-group"

  cluster_id       = var.cluster_id
  region           = var.region
  role             = "worker"
  node_count       = var.worker_count
  node_name_suffix = "${var.cluster_id}.${var.base_domain}"
  subnet_uuid      = cloudscale_subnet.privnet_subnet.id
  ignition_ca      = var.ignition_ca
  api_int          = "api-int.${var.cluster_id}.${var.base_domain}"
}
