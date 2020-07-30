output "infra_servers" {
  value = module.infra.ip_addresses
}

output "dns_entries" {
  value = templatefile("${path.module}/templates/dns.zone", {
    "node_name_suffix" = local.node_name_suffix,
    "eip_api"          = split("/", cloudscale_floating_ip.api_vip.network)[0],
    "api_int"          = cidrhost(var.privnet_cidr, 100),
    "masters"          = module.master.ip_addresses,
  })
}

output "node_name_suffix" {
  value = "${local.node_name_suffix}"
}

output "subnet_uuid" {
  value = cloudscale_subnet.privnet_subnet.id
}

output "region" {
  value = var.region
}

output "cluster_id" {
  value = var.cluster_id
}

output "ignition_ca" {
  value = var.ignition_ca
}

output "api_int" {
  value = "api-int.${local.node_name_suffix}"
}
