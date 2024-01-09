locals {
  cluster_name          = var.cluster_name != "" ? var.cluster_name : var.cluster_id
  node_name_suffix      = "${local.cluster_name}.${var.base_domain}"
  create_privnet_subnet = var.subnet_uuid == "" ? 1 : 0
  subnet_uuid           = var.subnet_uuid == "" ? cloudscale_subnet.privnet_subnet[0].id : var.subnet_uuid
  privnet_uuid          = local.create_privnet_subnet > 0 ? cloudscale_network.privnet[0].id : data.cloudscale_subnet.privnet_subnet[0].network_uuid
  privnet_cidr          = local.create_privnet_subnet > 0 ? var.privnet_cidr : data.cloudscale_subnet.privnet_subnet[0].cidr
  worker_volume_size_gb = var.worker_volume_size_gb == 0 ? var.default_volume_size_gb : var.worker_volume_size_gb
}

resource "cloudscale_network" "privnet" {
  count                   = local.create_privnet_subnet
  name                    = "privnet-${var.cluster_id}"
  zone_slug               = "${var.region}1"
  auto_create_ipv4_subnet = false
}

resource "cloudscale_subnet" "privnet_subnet" {
  count           = local.create_privnet_subnet
  network_uuid    = local.privnet_uuid
  cidr            = local.privnet_cidr
  gateway_address = cidrhost(local.privnet_cidr, 1)
}

data "cloudscale_subnet" "privnet_subnet" {
  count = var.subnet_uuid == "" ? 0 : 1
  id    = var.subnet_uuid
}
