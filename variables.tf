variable "cluster_id" {
  type        = string
  description = "Project Syn ID of the cluster"
}

variable "cluster_name" {
  type        = string
  description = "User-facing name of the cluster. If left empty, cluster_id will be used as cluster_name"
  default     = ""
}

variable "ignition_bootstrap" {
  type        = string
  description = "URL of the bootstrap ignition config (only used during installation)"
  default     = ""
}

variable "ignition_ca" {
  type        = string
  description = "CA certificate of the ignition API"
}

variable "base_domain" {
  type        = string
  description = "Base domain of the cluster"
}

variable "region" {
  type        = string
  description = "Region where to deploy nodes"
}

variable "ssh_keys" {
  type        = list(string)
  description = "SSH keys to add to LBs"
  default     = []
}

variable "subnet_uuid" {
  type        = string
  description = "UUID of an existing subnet. If provided, the variable `privnet_cidr` is ignored and the CIDR of the provided network is used."
  default     = ""
}

variable "privnet_cidr" {
  default     = "172.18.200.0/24"
  description = "CIDR for the private network. Will be ignored if the variable subnet_uuid is set."
}

variable "bootstrap_count" {
  type    = number
  default = 0
}

variable "lb_count" {
  type    = number
  default = 2
}

variable "lb_flavor" {
  type        = string
  default     = "plus-8-2"
  description = "Compute flavor to use for loadbalancers"
}

variable "master_count" {
  type    = number
  default = 3
}

variable "master_flavor" {
  type        = string
  default     = "plus-16-4"
  description = "Flavor to use for master nodes"
}

variable "infra_count" {
  type        = number
  default     = 4
  description = "Number of infra nodes"
}

variable "infra_flavor" {
  type        = string
  default     = "plus-16-4"
  description = "Flavor to use for infra nodes"
}

variable "infra_servers" {
  type        = list(string)
  default     = []
  description = "IP addresses of the infra nodes"
}

variable "worker_count" {
  type        = number
  default     = 3
  description = "Number of worker nodes"
}

variable "worker_flavor" {
  type        = string
  default     = "plus-16-4"
  description = "Flavor to use for worker nodes"
}

variable "default_volume_size_gb" {
  type        = number
  description = "Default boot volume size in GBs"
  default     = 100
}

variable "worker_volume_size_gb" {
  type        = number
  description = "Worker boot volume size in GBs"
  default     = 0
}

variable "additional_worker_groups" {
  type    = map(object({ flavor = string, count = number, volume_size_gb = optional(number) }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.additional_worker_groups :
      !contains(["worker", "master", "infra"], k) &&
      v.count >= 0 &&
      (v.volume_size_gb != null ? v.volume_size_gb >= 100 : true)
    ])
    // Cannot use any of the nicer string formatting options because
    // error_message validation is dumb, cf.
    // https://github.com/hashicorp/terraform/issues/24123
    error_message = "Your configuration of `additional_worker_groups` violates one of the following constraints:\n * The worker disk size cannot be smaller than 100GB.\n * Additional worker group names cannot be 'worker', 'master', or 'infra'.\n * The worker count cannot be less than 0."
  }
}

variable "image_slug" {
  type        = string
  description = "Image to use for nodes"
  default     = "custom:rhcos-4.9"
}

variable "lb_cloudscale_api_secret" {
  type = string
}

variable "hieradata_repo_user" {
  type = string
}

variable "control_vshn_net_token" {
  type = string
}

variable "team" {
  type        = string
  description = "Team to assign the load balancers to in Icinga. All lower case."
  default     = ""
}

variable "additional_lb_networks" {
  type        = list(string)
  description = "List of UUIDs of additional cloudscale.ch networks to attach"
  default     = []
}

variable "lb_enable_proxy_protocol" {
  type        = bool
  description = "Enable the PROXY protocol on the loadbalancers. WARNING: Connections will fail until you enable the same on the OpenShift router as well"
  default     = false
}

variable "use_existing_vips" {
  type        = bool
  description = "Use existing floating IPs for api_vip, router_vip and nat_vip. Manually set the reverse DNS info, so the correct data source is found."
  default     = false
}

variable "enable_api_vip" {
  type        = bool
  description = "Whether to configure a cloudscale floating IP for the API"
  default     = true
}

variable "enable_router_vip" {
  type        = bool
  description = "Whether to configure a cloudscale floating IP for the router"
  default     = true
}

variable "enable_nat_vip" {
  type        = bool
  description = "Whether to configure a cloudscale floating IP for the default gateway NAT"
  default     = true
}

variable "internal_vip" {
  type        = string
  description = "Custom internal floating IP for the API. Users must provide an IP that's within the final privnet CIDR."
  default     = ""
}

variable "internal_router_vip" {
  type        = string
  description = "Custom internal floating IP for the router. Users must provide an IP that's within the final privnet CIDR."
  default     = ""
}

variable "make_worker_adoptable_by_provider" {
  type        = bool
  description = "Whether to make the worker nodes adoptable by https://github.com/appuio/machine-api-provider-cloudscale"
  default     = false
}

variable "make_master_adoptable_by_provider" {
  type        = bool
  description = "Whether to make the master nodes adoptable by https://github.com/appuio/machine-api-provider-cloudscale"
  default     = false
}
