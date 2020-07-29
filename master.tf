resource "random_id" "master" {
  count       = var.master_count
  prefix      = "master-"
  byte_length = 1
}

resource "cloudscale_server" "master" {
  count          = var.master_count
  name           = "${random_id.master[count.index].hex}.${var.cluster_id}.${var.base_domain}"
  zone_slug      = var.region
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
  user_data = <<-EOF
    {
      "ignition": {
        "version": "2.2.0",
        "config": {
          "append": [
            {
              "source": "https://api-int.${var.cluster_id}.${var.base_domain}:22623/config/master"
            }
          ]
        },
        "security": {
          "tls": {
            "certificateAuthorities": [
              {
                "source": "data:text/plain;charset=utf-8;base64,${base64encode(var.ignition_ca)}"
              }
            ]
          }
        }
      }
    }
    EOF

  depends_on = [
    cloudscale_server.bootstrap,
  ]
}
