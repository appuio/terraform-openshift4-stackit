resource "random_id" "node" {
  count       = var.node_count
  prefix      = "${var.role}-"
  byte_length = 2
}

resource "cloudscale_server" "node" {
  count          = var.node_count
  name           = "${random_id.node[count.index].hex}.${var.node_name_suffix}"
  zone_slug      = var.region
  flavor_slug    = var.flavor_slug
  image_slug     = var.image_slug
  volume_size_gb = var.volume_size_gb
  interfaces {
    type = "private"
    addresses {
      subnet_uuid = var.subnet_uuid
    }
  }
  user_data = <<-EOF
    {
      "ignition": {
        "version": "2.2.0",
        "config": {
          "append": [{
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
