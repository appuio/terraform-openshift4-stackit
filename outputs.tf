output "infra_servers" {
  value = module.infra.ip_addresses
}

output "dns_entries" {
  value = <<-EOF
    api.${var.cluster_id}.${var.base_domain} IN A ${split("/", cloudscale_floating_ip.api_vip.network)[0]}

    *.apps.${var.cluster_id}.${var.base_domain} IN CNAME api.${var.cluster_id}.${var.base_domain}.

    api-int.${var.cluster_id}.${var.base_domain} IN A ${cidrhost(var.privnet_cidr, 100)}

    etcd-0.${var.cluster_id}.${var.base_domain} IN A ${cidrhost(var.privnet_cidr, 20)}
    etcd-1.${var.cluster_id}.${var.base_domain} IN A ${cidrhost(var.privnet_cidr, 21)}
    etcd-2.${var.cluster_id}.${var.base_domain} IN A ${cidrhost(var.privnet_cidr, 22)}

    _etcd-server-ssl._tcp.${var.cluster_id}.${var.base_domain} IN SRV 0 10 2380 etcd-0.${var.cluster_id}.${var.base_domain}
    _etcd-server-ssl._tcp.${var.cluster_id}.${var.base_domain} IN SRV 0 10 2380 etcd-1.${var.cluster_id}.${var.base_domain}
    _etcd-server-ssl._tcp.${var.cluster_id}.${var.base_domain} IN SRV 0 10 2380 etcd-2.${var.cluster_id}.${var.base_domain}
    EOF
}

output "node_name_suffix" {
  value = "${var.cluster_id}.${var.base_domain}"
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
  value = "api-int.${var.cluster_id}.${var.base_domain}"
}
