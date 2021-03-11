variable "cluster_id" {
  type        = string
  description = "ID of the cluster"
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

variable "privnet_cidr" {
  default     = "172.18.200.0/24"
  description = "CIDR of the private net to use"
}

variable "bootstrap_count" {
  type    = number
  default = 0
}

variable "lb_count" {
  type    = number
  default = 2
}

variable "master_count" {
  type    = number
  default = 3
}

variable "infra_count" {
  type        = number
  default     = 3
  description = "Number of infra nodes"
}

variable "infra_flavor" {
  type        = string
  default     = "plus-16"
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
  default     = "plus-16"
  description = "Flavor to use for worker nodes"
}

variable "worker_volume_size_gb" {
  type        = number
  description = "Worker boot volume size in GBs"
  default     = 128
}

variable "image_slug" {
  type        = string
  description = "Image to use for nodes"
  default     = "custom:rhcos-4.7"
}
