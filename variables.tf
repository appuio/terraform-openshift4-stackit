variable "cluster_id" {
  type        = string
  description = "Project Syn ID of the cluster"
}

variable "stackit_project_id" {
  type        = string
  description = "STACKIT Project ID in which to provision resources"
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

variable "network_id" {
  type        = string
  description = "ID of a STACKIT network to re-use for the cluster. If left empty, a new network is created."
  default     = ""
}

variable "ssh_key" {
  type        = string
  description = "SSH key to add to nodes"
}

variable "existing_keypair" {
  type        = string
  description = "Existing STACKIT SSH keypair ID (if empty, a new one is created)"
  default     = ""
}

variable "privnet_cidr" {
  default     = "172.18.200.0/24"
  description = "CIDR for the private network."
}

variable "bootstrap_count" {
  type    = number
  default = 0
}

variable "master_count" {
  type    = number
  default = 3
}

variable "master_type" {
  type        = string
  default     = "g2i.4"
  description = "Flavor to use for master nodes"
}

variable "infra_count" {
  type        = number
  default     = 4
  description = "Number of infra nodes"
}

variable "infra_type" {
  type        = string
  default     = "g2i.4"
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

variable "worker_type" {
  type        = string
  default     = "g2i.4"
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

variable "image_id" {
  type        = string
  description = "Image to use for nodes"
}

variable "lb_enable_proxy_protocol" {
  type        = bool
  description = "Enable the PROXY protocol on the loadbalancers. WARNING: Connections will fail until you enable the same on the OpenShift router as well"
  default     = false
}
