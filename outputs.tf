output "node_name_suffix" {
  value = local.node_name_suffix
}

output "network_id" {
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

output "dns_nameserver" {
  value = stackit_dns_zone.cluster_dns_zone.primary_name_server
}

# NOTE(aa): The STACKIT terraform provider only provides us a single NS for a DNS zone (the primary NS).
#  However, they currently operate two NS and recommend adding both of them for delegation.
#  I have thus decided to statically include their second NS here.
output "ns_records" {
  value = <<EOF

; Add these records in the ${var.base_domain} zone file.
;
; If ${var.base_domain} is a subdomain of one of your zones, you'll need to
; adjust the labels of records below to the form
; '${local.cluster_name}.<subdomain>'.
;
; Delegate  ${var.cluster_id}'s subdomain to STACKIT
${local.cluster_name}  IN  NS     ${stackit_dns_zone.cluster_dns_zone.primary_name_server}.
${local.cluster_name}  IN  NS     ns2.stackit.cloud.

EOF
}
