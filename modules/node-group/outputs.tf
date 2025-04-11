output "ip_addresses" {
  value = stackit_network_interface.nic[*].ipv4
}

output "node_names" {
  value = stackit_server.node[*].name
}
