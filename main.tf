locals {
  node_name_suffix = "${var.cluster_id}.${var.base_domain}"
}

resource "cloudscale_network" "privnet" {
  name                    = "privnet-${var.cluster_id}"
  zone_slug               = var.region
  auto_create_ipv4_subnet = false
}

resource "cloudscale_subnet" "privnet_subnet" {
  network_uuid    = cloudscale_network.privnet.id
  cidr            = var.privnet_cidr
  gateway_address = cidrhost(var.privnet_cidr, 1)
}

resource "cloudscale_floating_ip" "api_vip" {
  ip_version = 4

  lifecycle {
    ignore_changes = [
      # Will be handled by Keepalived (Ursula)
      server,
      next_hop,
    ]
  }
}
