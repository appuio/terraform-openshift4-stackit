resource "random_id" "lb" {
  count       = var.lb_count
  prefix      = "lb-"
  byte_length = 1
}
resource "random_id" "master" {
  count       = var.master_count
  prefix      = "master-"
  byte_length = 1
}
resource "random_id" "worker" {
  count       = var.worker_count
  prefix      = "node-"
  byte_length = 2
}

resource "cloudscale_network" "privnet" {
  name      = "privnet-${var.cluster_name}"
  zone_slug = "rma1"
}

resource "cloudscale_subnet" "privnet_subnet" {
  network_uuid    = cloudscale_network.privnet.id
  cidr            = var.privnet_cidr
  gateway_address = cidrhost(var.privnet_cidr, 1)
}

resource "cloudscale_server" "lb" {
  count          = var.lb_count
  name           = "${random_id.lb[count.index].hex}.${var.cluster_name}.${var.base_domain}"
  zone_slug      = "rma1"
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
  user_data = <<EOF
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
  "api_eip" = var.api_eip
  "api_int" = cidrhost(var.privnet_cidr, 100)
  "gateway" = cloudscale_subnet.privnet_subnet.gateway_address
  "api_servers" = [
    cidrhost(var.privnet_cidr, 10),
    cidrhost(var.privnet_cidr, 20),
    cidrhost(var.privnet_cidr, 21),
    cidrhost(var.privnet_cidr, 22)
  ]
  "prio" = (var.lb_count - count.index) * 10
  }))}
- path: "/etc/haproxy/haproxy.cfg"
  encoding: b64
  content: ${base64encode(templatefile("${path.module}/templates/haproxy.cfg", {
  "api_eip" = var.api_eip
  "api_int" = cidrhost(var.privnet_cidr, 100)
  "api_servers" = [
    cidrhost(var.privnet_cidr, 10),
    cidrhost(var.privnet_cidr, 20),
    cidrhost(var.privnet_cidr, 21),
    cidrhost(var.privnet_cidr, 22)
  ]
  "router_servers" = var.router_servers
}))}
EOF
}

resource "cloudscale_server" "bootstrap" {
  count          = var.bootstrap_count
  name           = "bootstrap.${var.cluster_name}.${var.base_domain}"
  zone_slug      = "rma1"
  flavor_slug    = "flex-16"
  image_slug     = "rhcos-4.4"
  volume_size_gb = 128
  interfaces {
    type = "private"
    addresses {
      address     = cidrhost(var.privnet_cidr, 10)
      subnet_uuid = cloudscale_subnet.privnet_subnet.id
    }
  }
  user_data = templatefile(var.ignition_template, {
    role = "bootstrap"
    cluster_name = var.cluster_name
  })
  depends_on = [
    cloudscale_server.lb,
  ]
}

resource "cloudscale_server" "master" {
  count          = var.master_count
  name           = "${random_id.master[count.index].hex}.${var.cluster_name}.${var.base_domain}"
  zone_slug      = "rma1"
  flavor_slug    = "flex-16"
  image_slug     = "rhcos-4.4"
  volume_size_gb = 128
  interfaces {
    type = "private"
    addresses {
      address     = cidrhost(var.privnet_cidr, 20 + count.index)
      subnet_uuid = cloudscale_subnet.privnet_subnet.id
    }
  }
  user_data = templatefile(var.ignition_template, {
    role = "master"
    cluster_name = var.cluster_name
  })
  depends_on = [
    cloudscale_server.bootstrap,
  ]
}

resource "cloudscale_server" "worker" {
  count          = var.worker_count
  name           = "${random_id.worker[count.index].hex}.${var.cluster_name}.${var.base_domain}"
  zone_slug      = "rma1"
  flavor_slug    = "flex-8"
  image_slug     = "rhcos-4.4"
  volume_size_gb = 128
  interfaces {
    type = "private"
    addresses {
      subnet_uuid = cloudscale_subnet.privnet_subnet.id
    }
  }
  user_data = templatefile(var.ignition_template, {
    role = "worker"
    cluster_name = var.cluster_name
  })
  depends_on = [
    cloudscale_server.master,
  ]
}

resource "cloudscale_floating_ip" "api_vip" {
  server      = cloudscale_server.lb[0].id
  ip_version  = 4
  reverse_ptr = "api.${var.cluster_name}.${var.base_domain}"
}
