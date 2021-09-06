resource "random_id" "lb" {
  count       = var.lb_count
  prefix      = "lb-"
  byte_length = 1
}

resource "cloudscale_server_group" "lb" {
  count     = var.lb_count != 0 ? 1 : 0
  name      = "lb-group"
  type      = "anti-affinity"
  zone_slug = "${var.region}1"
}

locals {
  instance_fqdns = formatlist("%s.${local.node_name_suffix}", random_id.lb[*].hex)

  common_user_data = {
    "package_update"  = true,
    "package_upgrade" = true,
    "runcmd" = [
      "sleep '5'",
      "wget -O /tmp/puppet-source.deb https://apt.puppetlabs.com/puppet6-release-focal.deb",
      "dpkg -i /tmp/puppet-source.deb",
      "rm /tmp/puppet-source.deb",
      "apt-get update",
      "apt-get -y install puppet-agent",
      "apt-get -y purge snapd",
      "mkdir -p /etc/puppetlabs/facter/facts.d",
      "netplan apply",
      ["bash", "-c",
      "set +e -x; for ((i=0; i < 3; ++i)); do /opt/puppetlabs/bin/puppet facts && break; done; for ((i=0; i < 3; ++i)); do /opt/puppetlabs/bin/puppet agent -t --server master.puppet.vshn.net && break; done"],
      "sleep 5",
      "shutdown --reboot +1 'Reboot for system setup'",
    ],
    "manage_etc_hosts" = true,
    "write_files" = [
      {
        path       = "/etc/netplan/60-ens4.yaml"
        "encoding" = "b64"
        "content" = base64encode(yamlencode({
          "network" = {
            "ethernets" = {
              "ens4" = {
                "dhcp4" = true,
              },
            },
            "version" = 2,
          }
        }))
      }
    ]
  }
}

resource "null_resource" "register_lb" {
  triggers = {
    # Refresh resource when script changes -- this is probaby not required for production
    script_sha1 = filesha1("${path.module}/files/register-server.sh")
    # Refresh resource when lb fqdn changes
    lb_id = local.instance_fqdns[count.index]
  }

  count = var.lb_count

  provisioner "local-exec" {
    command = "${path.module}/files/register-server.sh"
    environment = {
      CONTROL_VSHN_NET_TOKEN = var.control_vshn_net_token
      SERVER_FQDN            = local.instance_fqdns[count.index]
      SERVER_REGION          = "${var.region}.ch"
      # Cluster id is used as encdata stage
      CLUSTER_ID = var.cluster_id
    }
  }
}

resource "gitfile_checkout" "appuio_hieradata" {
  repo = "https://${var.hieradata_repo_user}@git.vshn.net/appuio/appuio_hieradata.git"
  path = "${path.root}/appuio_hieradata"

  count = var.lb_count > 0 ? 1 : 0

  lifecycle {
    ignore_changes = [
      branch
    ]
  }
}

resource "local_file" "lb_hieradata" {
  count = var.lb_count > 0 ? 1 : 0

  content = templatefile(
    "${path.module}/templates/hieradata.yaml.tmpl",
    {
      "cluster_id"   = var.cluster_id
      "api_vip"      = cidrhost(cloudscale_floating_ip.api_vip[0].network, 0)
      "router_vip"   = cidrhost(cloudscale_floating_ip.router_vip[0].network, 0)
      "api_secret"   = var.lb_cloudscale_api_secret
      "internal_vip" = cidrhost(var.privnet_cidr, 100)
      "nat_vip"      = cidrhost(cloudscale_floating_ip.nat_vip[0].network, 0)
      "nodes"        = local.instance_fqdns
      "backends" = {
        "api"    = formatlist("etcd-%d.${local.node_name_suffix}", range(3))
        "router" = module.infra.ip_addresses[*],
      }
      "bootstrap_node" = var.bootstrap_count > 0 ? cidrhost(var.privnet_cidr, 10) : ""
  })

  filename             = "${path.cwd}/appuio_hieradata/lbaas/${var.cluster_id}.yaml"
  file_permission      = "0644"
  directory_permission = "0755"

  depends_on = [
    gitfile_checkout.appuio_hieradata[0]
  ]

  provisioner "local-exec" {
    command = "${path.module}/files/commit-hieradata.sh ${var.cluster_id} ${path.cwd}/.mr_url.txt"
  }
}

data "local_file" "hieradata_mr_url" {
  count    = var.lb_count > 0 ? 1 : 0
  filename = "${path.cwd}/.mr_url.txt"

  depends_on = [
    local_file.lb_hieradata
  ]
}

resource "cloudscale_server" "lb" {
  count                          = var.lb_count
  name                           = local.instance_fqdns[count.index]
  zone_slug                      = "${var.region}1"
  flavor_slug                    = "plus-8"
  image_slug                     = "ubuntu-20.04"
  server_group_ids               = var.lb_count != 0 ? [cloudscale_server_group.lb[0].id] : []
  volume_size_gb                 = 50
  ssh_keys                       = var.ssh_keys
  skip_waiting_for_ssh_host_keys = true
  interfaces {
    type = "public"
  }
  interfaces {
    type         = "private"
    network_uuid = cloudscale_network.privnet.id
  }
  lifecycle {
    ignore_changes = [
      skip_waiting_for_ssh_host_keys,
      image_slug,
      user_data,
    ]
    create_before_destroy = true
  }

  user_data = format("#cloud-config\n%s", yamlencode(merge(
    local.common_user_data,
    {
      "fqdn"     = local.instance_fqdns[count.index],
      "hostname" = random_id.lb[count.index].hex,
    }
  )))

  depends_on = [
    null_resource.register_lb,
    local_file.lb_hieradata[0]
  ]
}
