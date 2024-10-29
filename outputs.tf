output "dns_entries" {
  value = templatefile("${path.module}/templates/dns.zone", {
    "node_name_suffix"    = local.node_name_suffix,
    "api_vip"             = var.enable_api_vip && var.lb_count != 0 ? split("/", module.lb.api_vip[0].network)[0] : ""
    "router_vip"          = var.enable_router_vip && var.lb_count != 0 ? split("/", module.lb.router_vip[0].network)[0] : ""
    "egress_vip"          = var.enable_nat_vip && var.lb_count != 0 ? split("/", module.lb.nat_vip[0].network)[0] : ""
    "internal_vip"        = local.internal_vip,
    "internal_router_vip" = var.internal_router_vip,
    "masters"             = module.master.ip_addresses,
    "cluster_id"          = var.cluster_id,
    "lbs"                 = module.lb.public_ipv4_addresses,
    "lb_hostnames"        = module.lb.server_names
  })
}

output "node_name_suffix" {
  value = local.node_name_suffix
}

output "subnet_uuid" {
  value = local.subnet_uuid
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
  value = module.lb.hieradata_mr_url
}

output "master-machines_yml" {
  value = var.make_master_adoptable_by_provider ? module.master.machine_yml : null
}

output "master-machineset_yml" {
  value = var.make_master_adoptable_by_provider ? module.master.machineset_yml : null
}

output "infra-machines_yml" {
  value = var.make_worker_adoptable_by_provider ? module.infra.machine_yml : null
}

output "infra-machineset_yml" {
  value = var.make_worker_adoptable_by_provider ? module.infra.machineset_yml : null
}

output "worker-machines_yml" {
  value = var.make_worker_adoptable_by_provider ? module.worker.machine_yml : null
}

output "worker-machineset_yml" {
  value = var.make_worker_adoptable_by_provider ? module.worker.machineset_yml : null
}

output "additional-worker-machines_yml" {
  value = var.make_worker_adoptable_by_provider && length(module.additional_worker) > 0 ? {
    "apiVersion" = "v1",
    "kind"       = "List",
    "items"      = flatten(values(module.additional_worker)[*].machines)
  } : null
}

output "additional-worker-machinesets_yml" {
  value = var.make_worker_adoptable_by_provider && length(module.additional_worker) > 0 ? join("\n---\n", values(module.additional_worker)[*].machineset_yml) : null
}
