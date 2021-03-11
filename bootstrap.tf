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
        },
        "systemd": {
            "units": [{
                "name": "cloudscale-hostkeys.service",
                "enabled": true,
                "contents": "[Unit]\nDescription=Print SSH Public Keys to tty\nAfter=sshd-keygen.target\n\n[Install]\nWantedBy=multi-user.target\n\n[Service]\nType=oneshot\nStandardOutput=tty\nTTYPath=/dev/ttyS0\nExecStart=/bin/sh -c \"echo '-----BEGIN SSH HOST KEY KEYS-----'; cat /etc/ssh/ssh_host_*key.pub; echo '-----END SSH HOST KEY KEYS-----'\""
            }]
        }
    }
    EOF
  depends_on = [
    cloudscale_server.lb,
  ]
}
