variable "role" {
  type        = string
  description = "Role of the nodes to be provisioned"
}

variable "node_count" {
  type        = number
  description = "Number of nodes to provision"
}

variable "node_name_suffix" {
  type        = string
  description = "Suffix to use for node names"
}

variable "subnet_uuid" {
  type        = string
  description = "UUID of the subnet in which to create the nodes"
}

variable "region" {
  type        = string
  description = "Region where to deploy nodes"
}

variable "flavor_slug" {
  type        = string
  description = "Flavor to use for nodes"
  default     = "plus-16-4"
}

variable "image_slug" {
  type        = string
  description = "Image to use for nodes"
}

variable "volume_size_gb" {
  type        = number
  description = "Boot volume size in GBs"
  default     = 100
}

variable "ignition_ca" {
  type        = string
  description = "CA certificate of the ignition API"
}

variable "ignition_config" {
  type        = string
  default     = "worker"
  description = "Name of the ignition config to use for the nodes"
}

variable "api_int" {
  type        = string
  description = "Hostname of the internal API (to be used for the ignition endpoint)"
}
