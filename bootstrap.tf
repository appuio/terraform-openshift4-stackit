resource "stackit_server" "bootstrap" {
  count        = var.bootstrap_count
  project_id   = var.stackit_project_id
  name         = "bootstrap.${local.node_name_suffix}"
  machine_type = "g2i.4"
  keypair_name = local.ssh_key_name
  boot_volume = {
    size        = 128
    source_type = "image"
    source_id   = var.image_id
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
}

resource "stackit_network_interface" "bootstrap_nic" {
  count              = var.bootstrap_count
  project_id         = var.stackit_project_id
  network_id         = local.subnet_uuid
  security_group_ids = [stackit_security_group.cluster_sg.security_group_id]
  ipv4               = cidrhost(local.privnet_cidr, 10)
  lifecycle {
    ignore_changes = [security_group_ids]
  }
}

resource "stackit_server_network_interface_attach" "bootstrap-nic-attach" {
  count                = var.bootstrap_count
  project_id           = var.stackit_project_id
  server_id            = stackit_server.bootstrap[count.index].server_id
  network_interface_id = stackit_network_interface.bootstrap_nic[count.index].network_interface_id
}
