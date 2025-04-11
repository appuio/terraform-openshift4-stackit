resource "random_id" "node" {
  count       = var.node_count
  prefix      = "${var.role}-"
  byte_length = 2
}

resource "stackit_server" "node" {
  count        = var.node_count
  project_id   = var.stackit_project_id
  name         = "${random_id.node[count.index].hex}.${var.node_name_suffix}"
  machine_type = var.machine_type
  keypair_name = var.ssh_key_name
  boot_volume = {
    size        = var.volume_size_gb
    source_type = "image"
    source_id   = var.image_id
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
        "files": [
          {
            "path": "/etc/hostname",
            "mode": 420,
            "contents": {
              "source": "data:text/plain;charset=utf-8;base64,${base64encode("${random_id.node[count.index].hex}.${var.node_name_suffix}")}"
            }
          }
        ]
      }
    }
    EOF
}

resource "stackit_network_interface" "nic" {
  count              = var.node_count
  project_id         = var.stackit_project_id
  network_id         = var.network_id
  security_group_ids = var.security_group_ids
  lifecycle {
    ignore_changes = [security_group_ids]
  }
}

resource "stackit_server_network_interface_attach" "nic-attach" {
  count                = var.node_count
  project_id           = var.stackit_project_id
  server_id            = stackit_server.node[count.index].server_id
  network_interface_id = stackit_network_interface.nic[count.index].network_interface_id
}
