resource "stackit_public_ip" "lb_ip" {
  project_id = var.stackit_project_id
  lifecycle {
    ignore_changes = [network_interface_id]
  }
}

resource "stackit_loadbalancer" "cluster_lb" {
  lifecycle {
    ignore_changes = [options.acl]
  }
  project_id = var.stackit_project_id
  name       = "load-balancer-${var.cluster_id}"
  target_pools = flatten([
    var.bootstrap_count + var.master_count > 0 ? [
      {
        name        = "master-target-pool-api"
        target_port = 6443
        targets = concat([
          for index, ipv4 in module.master.ip_addresses : {
            display_name = replace(module.master.node_names[index], ".", "-")
            ip           = ipv4
          }
          ], [
          for index, nic in stackit_network_interface.bootstrap_nic :
          {
            display_name = replace(stackit_server.bootstrap[0].name, ".", "-")
            ip           = nic.ipv4
          }
        ])
        active_health_check = {
          healthy_threshold   = 10
          interval            = "3s"
          interval_jitter     = "3s"
          timeout             = "3s"
          unhealthy_threshold = 10
        }
      },
      {
        name        = "master-target-pool-machineconfig"
        target_port = 22623
        targets = concat([
          for index, ipv4 in module.master.ip_addresses : {
            display_name = replace(module.master.node_names[index], ".", "-")
            ip           = ipv4
          }
          ], [
          for index, nic in stackit_network_interface.bootstrap_nic :
          {
            display_name = replace(stackit_server.bootstrap[0].name, ".", "-")
            ip           = nic.ipv4
          }
        ])
        active_health_check = {
          healthy_threshold   = 10
          interval            = "3s"
          interval_jitter     = "3s"
          timeout             = "3s"
          unhealthy_threshold = 10
        }
    }] : [],
    var.infra_count > 0 ? [
      {
        name        = "infra-target-pool-http"
        target_port = 80
        targets = [
          for index, ipv4 in module.infra.ip_addresses : {
            display_name = replace(module.infra.node_names[index], ".", "-")
            ip           = ipv4
          }
        ]
        active_health_check = {
          healthy_threshold   = 10
          interval            = "3s"
          interval_jitter     = "3s"
          timeout             = "3s"
          unhealthy_threshold = 10
        }
      },
      {
        name        = "infra-target-pool-https"
        target_port = 443
        targets = [
          for index, ipv4 in module.infra.ip_addresses : {
            display_name = replace(module.infra.node_names[index], ".", "-")
            ip           = ipv4
          }
        ]
        active_health_check = {
          healthy_threshold   = 10
          interval            = "3s"
          interval_jitter     = "3s"
          timeout             = "3s"
          unhealthy_threshold = 10
        }
    }] : []
  ])
  listeners = flatten([
    var.bootstrap_count + var.master_count > 0 ? [
      {
        display_name = "api"
        port         = 6443
        protocol     = "PROTOCOL_TCP"
        target_pool  = "master-target-pool-api"
      },
      {
        display_name = "machineconfig"
        port         = 22623
        protocol     = "PROTOCOL_TCP"
        target_pool  = "master-target-pool-machineconfig"
      }
    ] : [],
    var.infra_count > 0 ? [
      {
        display_name = "ingress-http"
        port         = 80
        protocol     = var.lb_enable_proxy_protocol ? "PROTOCOL_TCP_PROXY" : "PROTOCOL_TCP"
        target_pool  = "infra-target-pool-http"
      },
      {
        display_name = "ingress-https"
        port         = 443
        protocol     = var.lb_enable_proxy_protocol ? "PROTOCOL_TCP_PROXY" : "PROTOCOL_TCP"
        target_pool  = "infra-target-pool-https"
      }
    ] : []
  ])
  networks = [
    {
      network_id = local.subnet_uuid
      role       = "ROLE_LISTENERS_AND_TARGETS"
    }
  ]
  external_address = stackit_public_ip.lb_ip.ip
  options = {
    private_network_only = false
  }
}

resource "stackit_dns_zone" "cluster_dns_zone" {
  project_id = var.stackit_project_id
  name       = "${var.cluster_id} DNS zone"
  dns_name   = "${var.cluster_id}.${var.base_domain}"
}


resource "stackit_dns_record_set" "api" {
  project_id = var.stackit_project_id
  zone_id    = stackit_dns_zone.cluster_dns_zone.zone_id
  name       = "api"
  type       = "A"
  records    = [stackit_public_ip.lb_ip.ip]
}

resource "stackit_dns_record_set" "api-int" {
  project_id = var.stackit_project_id
  zone_id    = stackit_dns_zone.cluster_dns_zone.zone_id
  name       = "api-int"
  type       = "A"
  records    = [stackit_public_ip.lb_ip.ip]
}

resource "stackit_dns_record_set" "ingress" {
  project_id = var.stackit_project_id
  zone_id    = stackit_dns_zone.cluster_dns_zone.zone_id
  name       = "ingress"
  type       = "A"
  records    = [stackit_public_ip.lb_ip.ip]
}

resource "stackit_dns_record_set" "apps" {
  project_id = var.stackit_project_id
  zone_id    = stackit_dns_zone.cluster_dns_zone.zone_id
  name       = "*.apps"
  type       = "CNAME"
  records    = ["ingress.${var.cluster_id}.${var.base_domain}."]
}
