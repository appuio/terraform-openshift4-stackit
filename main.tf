locals {
  node_name_suffix      = "${var.cluster_id}.${var.base_domain}"
  create_privnet_subnet = var.subnet_uuid == "" ? 1 : 0
  subnet_uuid           = var.subnet_uuid == "" ? cloudscale_subnet.privnet_subnet[0].id : var.subnet_uuid
  privnet_uuid          = var.privnet_uuid == "" ? cloudscale_network.privnet[0].id : var.privnet_uuid
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
  cidr            = var.privnet_cidr
  gateway_address = cidrhost(var.privnet_cidr, 1)
}
