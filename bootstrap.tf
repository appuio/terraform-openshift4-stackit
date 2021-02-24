resource "cloudscale_server" "bootstrap" {
  count          = var.bootstrap_count
  name           = "bootstrap.${local.node_name_suffix}"
  zone_slug      = "${var.region}1"
  flavor_slug    = "flex-16"
  image_slug     = var.image_slug
  volume_size_gb = 128
  interfaces {
    type = "private"
    addresses {
      address     = cidrhost(var.privnet_cidr, 10)
      subnet_uuid = cloudscale_subnet.privnet_subnet.id
    }
  }
  user_data = <<-EOF
    {
        "ignition": {
            "version": "3.1.0",
            "config": {
                "merge": [
                    {
                        "source": "${var.ignition_bootstrap}"
                    }
                ]
            }
        }
    }
    EOF
  depends_on = [
    cloudscale_server.lb,
  ]
}
