output "dns_entries" {
  value = templatefile("${path.module}/templates/dns.zone", {
    "node_name_suffix" = local.node_name_suffix,
    "api_vip"          = var.lb_count != 0 ? split("/", cloudscale_floating_ip.api_vip[0].network)[0] : ""
    "router_vip"       = var.lb_count != 0 ? split("/", cloudscale_floating_ip.router_vip[0].network)[0] : ""
    "internal_vip"     = cidrhost(var.privnet_cidr, 100),
    "masters"          = module.master.ip_addresses,
    "cluster_id"       = var.cluster_id,
    "lbs"              = cloudscale_server.lb[*].public_ipv4_address,
    "lb_hostnames"     = random_id.lb[*].hex
  })
}

output "node_name_suffix" {
  value = local.node_name_suffix
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

output "hieradata_mr" {
  value = var.lb_count > 0 ? data.local_file.hieradata_mr_url[0].content : ""
}
