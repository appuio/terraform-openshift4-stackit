locals {
  node_name_suffix = "${var.cluster_id}.${var.base_domain}"
  create_privnet_subnet = var.subnet_uuid == "" ? 1 : 0
  subnet_uuid = var.subnet_uuid == "" ? cloudscale_subnet.privnet_subnet.id : var.subnet_uuid
}

resource "cloudscale_network" "privnet" {
  count                   = local.create_privnet_subnet
  name                    = "privnet-${var.cluster_id}"
  zone_slug               = "${var.region}1"
  auto_create_ipv4_subnet = false
}

resource "cloudscale_subnet" "privnet_subnet" {
  count           = local.create_privnet_subnet
  network_uuid    = cloudscale_network.privnet.id
  cidr            = var.privnet_cidr
  gateway_address = cidrhost(var.privnet_cidr, 1)
}

resource "cloudscale_floating_ip" "api_vip" {
  count       = var.lb_count != 0 ? 1 : 0
  ip_version  = 4
  region_slug = var.region

  lifecycle {
    ignore_changes = [
      # Will be handled by Keepalived (Ursula)
      server,
      next_hop,
    ]
  }
}

resource "cloudscale_floating_ip" "router_vip" {
  count       = var.lb_count != 0 ? 1 : 0
  ip_version  = 4
  region_slug = var.region

  lifecycle {
    ignore_changes = [
      # Will be handled by Keepalived (Ursula)
      server,
      next_hop,
    ]
  }
}

resource "cloudscale_floating_ip" "nat_vip" {
  count       = var.lb_count != 0 ? 1 : 0
  ip_version  = 4
  region_slug = var.region

  lifecycle {
    ignore_changes = [
      # Will be handled by Keepalived (Ursula)
      server,
      next_hop,
    ]
  }
}
