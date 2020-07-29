output "api_vip" {
  value = split("/", cloudscale_floating_ip.api_vip.network)[0]
}

output "router_servers" {
  value = cloudscale_server.worker[*].private_ipv4_address
}

output "dns_entries" {
  value = <<EOF


  api.${var.cluster_id}.${var.base_domain} IN A ${split("/", cloudscale_floating_ip.api_vip.network)[0]}

  *.apps.${var.cluster_id}.${var.base_domain} IN CNAME api.${var.cluster_id}.${var.base_domain}.

  api-int.${var.cluster_id}.${var.base_domain} IN A ${cidrhost(var.privnet_cidr, 100)}

  etcd-0.${var.cluster_id}.${var.base_domain} IN A ${cloudscale_server.master[0].private_ipv4_address}
  etcd-1.${var.cluster_id}.${var.base_domain} IN A ${cloudscale_server.master[1].private_ipv4_address}
  etcd-2.${var.cluster_id}.${var.base_domain} IN A ${cloudscale_server.master[2].private_ipv4_address}

  _etcd-server-ssl._tcp.${var.cluster_id}.${var.base_domain} IN SRV 0 10 2380 etcd-0.${var.cluster_id}.${var.base_domain}
  _etcd-server-ssl._tcp.${var.cluster_id}.${var.base_domain} IN SRV 0 10 2380 etcd-1.${var.cluster_id}.${var.base_domain}
  _etcd-server-ssl._tcp.${var.cluster_id}.${var.base_domain} IN SRV 0 10 2380 etcd-2.${var.cluster_id}.${var.base_domain}
EOF
}
