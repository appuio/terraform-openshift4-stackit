resource "random_id" "lb" {
  count       = var.lb_count
  prefix      = "lb-"
  byte_length = 1
  keepers = {
    api_eip        = cidrhost(cloudscale_floating_ip.api_vip.network, 0)
    router_servers = join(",", var.router_servers)
  }
}

resource "cloudscale_server" "lb" {
  count          = var.lb_count
  name           = "${random_id.lb[count.index].hex}.${var.cluster_id}.${var.base_domain}"
  zone_slug      = var.region
  flavor_slug    = "flex-4"
  image_slug     = "ubuntu-20.04"
  volume_size_gb = 20
  ssh_keys       = var.ssh_keys
  interfaces {
    type = "public"
  }
  interfaces {
    type         = "private"
    network_uuid = cloudscale_network.privnet.id
    no_address   = true
  }
  lifecycle {
    create_before_destroy = true
  }
  user_data = <<-EOF
    #cloud-config
    package_update: true
    packages:
    - haproxy
    - keepalived
    bootcmd:
    - "iptables -t nat -A POSTROUTING -o ens3 -j MASQUERADE"
    - "sysctl -w net.ipv4.ip_forward=1"
    - "sysctl -w net.ipv4.ip_nonlocal_bind=1"
    - "ip link set ens7 up"
    - "ip address add ${cidrhost(var.privnet_cidr, 2 + count.index)}/24 dev ens7"
    write_files:
    - path: "/etc/keepalived/keepalived.conf"
      encoding: b64
      content: ${base64encode(templatefile("${path.module}/templates/keepalived.conf", {
  "api_eip" = random_id.lb[count.index].keepers.api_eip
  "api_int" = cidrhost(var.privnet_cidr, 100)
  "gateway" = cloudscale_subnet.privnet_subnet.gateway_address
  "api_servers" = [
    cidrhost(var.privnet_cidr, 10),
    cidrhost(var.privnet_cidr, 20),
    cidrhost(var.privnet_cidr, 21),
    cidrhost(var.privnet_cidr, 22)
  ]
  "prio" = "${(var.lb_count - count.index) * 10}"
  }))}
    - path: "/etc/haproxy/haproxy.cfg"
      encoding: b64
      content: ${base64encode(templatefile("${path.module}/templates/haproxy.cfg", {
  "api_eip" = cidrhost(cloudscale_floating_ip.api_vip.network, 0)
  "api_int" = cidrhost(var.privnet_cidr, 100)
  "api_servers" = [
    cidrhost(var.privnet_cidr, 10),
    cidrhost(var.privnet_cidr, 20),
    cidrhost(var.privnet_cidr, 21),
    cidrhost(var.privnet_cidr, 22)
  ]
  "router_servers" = length(random_id.lb[count.index].keepers.router_servers) > 0 ? split(",", random_id.lb[count.index].keepers.router_servers) : []
}))}
    EOF
}

resource "null_resource" "api_vip_assignement" {
  triggers = {
    api_eip = cloudscale_floating_ip.api_vip.network
    server  = cloudscale_server.lb[0].id
  }

  provisioner "local-exec" {
    command = <<-EOF
      wget --header "Authorization: Bearer $CLOUDSCALE_TOKEN" \
        -O - \
        --post-data server=${cloudscale_server.lb[0].id} \
        https://api.cloudscale.ch/v1/floating-ips/${cidrhost(cloudscale_floating_ip.api_vip.network, 0)}
      EOF
  }
}
