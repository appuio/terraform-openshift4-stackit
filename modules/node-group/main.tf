locals {
  anti_affinity_capacity = 4
  anti_affinity_group_count = ceil(var.node_count / local.anti_affinity_capacity)
}

resource "random_id" "node" {
  count       = var.node_count
  prefix      = "${var.role}-"
  byte_length = 2
}

resource "cloudscale_server_group" "nodes" {
  count = var.node_count != 0 ? local.anti_affinity_group_count : 0
  name      = "${var.role}-group"
  type      = "anti-affinity"
  zone_slug = "${var.region}1"
}

resource "cloudscale_server" "node" {
  count            = var.node_count
  name             = "${random_id.node[count.index].hex}.${var.node_name_suffix}"
  zone_slug        = "${var.region}1"
  flavor_slug      = var.flavor_slug
  image_slug       = var.image_slug
  server_group_ids = var.node_count != 0 ? [cloudscale_server_group.nodes[floor(count.index / local.anti_affinity_capacity)].id] : []
  volume_size_gb   = var.volume_size_gb
  interfaces {
    type = "private"
    addresses {
      subnet_uuid = var.subnet_uuid
    }
  }
  user_data = <<-EOF
    {
      "ignition": {
        "version": "3.1.0",
        "config": {
          "merge": [{
            "source": "https://${var.api_int}:22623/config/${var.ignition_config}"
          }]
        },
        "security": {
          "tls": {
            "certificateAuthorities": [{
              "source": "data:text/plain;charset=utf-8;base64,${base64encode(var.ignition_ca)}"
            }]
          }
        }
      },
      "storage": {
        "files": [{
          "filesystem": "root",
          "path": "/etc/hostname",
          "mode": 420,
          "contents": {
              "source": "data:,${random_id.node[count.index].hex}"
          }
        }]
      }
    }
    EOF
}
