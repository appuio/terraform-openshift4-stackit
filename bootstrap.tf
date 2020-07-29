resource "cloudscale_server" "bootstrap" {
  count          = var.bootstrap_count
  name           = "bootstrap.${var.cluster_id}.${var.base_domain}"
  zone_slug      = var.region
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
  user_data = <<-EOF
    {
        "ignition": {
            "version": "2.2.0",
            "config": {
                "append": [
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
