module "lb" {
  source = "git::https://github.com/appuio/terraform-modules.git//modules/vshn-lbaas-cloudscale?ref=v6.5.0"

  node_name_suffix       = local.node_name_suffix
  cluster_id             = var.cluster_id
  region                 = var.region
  ssh_keys               = var.ssh_keys
  privnet_id             = local.privnet_uuid
  lb_count               = var.lb_count
  lb_flavor              = var.lb_flavor
  control_vshn_net_token = var.control_vshn_net_token
  team                   = var.team
  additional_networks    = var.additional_lb_networks
  use_existing_vips      = var.use_existing_vips
  enable_api_vip         = var.enable_api_vip
  enable_router_vip      = var.enable_router_vip
  enable_nat_vip         = var.enable_nat_vip

  router_backends          = var.infra_count > 0 ? module.infra.ip_addresses[*] : module.worker.ip_addresses[*]
  bootstrap_node           = var.bootstrap_count > 0 ? cidrhost(local.privnet_cidr, 10) : ""
  lb_cloudscale_api_secret = var.lb_cloudscale_api_secret
  hieradata_repo_user      = var.hieradata_repo_user
  internal_vip             = local.internal_vip
  internal_router_vip      = var.internal_router_vip
  enable_proxy_protocol    = var.lb_enable_proxy_protocol
}
