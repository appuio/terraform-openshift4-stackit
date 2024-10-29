output "ip_addresses" {
  value = cloudscale_server.node[*].private_ipv4_address
}

locals {
  machine_spec = {
    "lifecycleHooks" = {}
    "metadata" = {
      labels = var.role == "master" ? {
        "node-role.kubernetes.io/control-plane" = ""
        "node-role.kubernetes.io/master"        = ""
        } : (var.role == "worker" ? {
          // Legacy case, "worker" nodes without additional specification are the "app" nodes of the cluster
          "node-role.kubernetes.io/app"    = ""
          "node-role.kubernetes.io/worker" = ""
          } : {
          "node-role.kubernetes.io/${var.role}" = ""
          "node-role.kubernetes.io/worker"      = ""

      })
    }
    "providerSpec" = {
      "value" = {
        "zone"             = "${var.region}1"
        "baseDomain"       = var.node_name_suffix
        "flavor"           = var.flavor_slug
        "image"            = var.image_slug
        "rootVolumeSizeGB" = var.volume_size_gb
        "antiAffinityKey"  = var.role
        "userDataSecret" = {
          "name" = "cloudscale-user-data"
        }
        "tokenSecret" = {
          "name" = "cloudscale-rw-token"
        }
        "interfaces" = [{
          "type" = "Private"
          "addresses" = [{
            "subnetUUID" = var.subnet_uuid,
          }]
        }]
      }
    }
  }

  machines = [
    for id in random_id.node : {
      "apiVersion" = "machine.openshift.io/v1beta1"
      "kind"       = "Machine"
      "metadata" = {
        "name"        = id.hex
        "annotations" = {}
        "labels" = {
          "machine.openshift.io/cluster-api-cluster"    = var.cluster_id
          "machine.openshift.io/cluster-api-machineset" = var.role
        }
      }
      "spec" = local.machine_spec
    }
  ]
}

output "machines" {
  value = local.machines
}

output "machine_yml" {
  value = yamlencode({
    "apiVersion" = "v1",
    "kind"       = "List",
    "items"      = local.machines,
  })
}

output "machineset_yml" {
  value = yamlencode({
    "apiVersion" = "machine.openshift.io/v1beta1",
    "kind"       = "MachineSet",
    "metadata" = {
      "name"      = var.role,
      "namespace" = "openshift-machine-api",
      "labels" = {
        "machine.openshift.io/cluster-api-cluster" = var.cluster_id,
        "name"                                     = var.role,
      },
    },
    "spec" = {
      "deletePolicy" = "Oldest",
      "replicas"     = var.node_count,
      "selector" = {
        "matchLabels" = {
          "machine.openshift.io/cluster-api-cluster"    = var.cluster_id,
          "machine.openshift.io/cluster-api-machineset" = var.role
        }
      },
      "template" = {
        "metadata" = {
          "labels" = {
            "machine.openshift.io/cluster-api-cluster" = var.cluster_id,
            // Legacy case, "worker" nodes without additional specification are the "app" nodes of the cluster
            "machine.openshift.io/cluster-api-machine-role" = var.role == "worker" ? "app" : var.role,
            "machine.openshift.io/cluster-api-machine-type" = var.role == "worker" ? "app" : var.role,
            "machine.openshift.io/cluster-api-machineset"   = var.role,
          }
        },
        "spec" = local.machine_spec,
      },
    },
    }
  )
}
