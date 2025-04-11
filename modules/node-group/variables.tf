variable "role" {
  type        = string
  description = "Role of the nodes to be provisioned"
}

variable "stackit_project_id" {
  type        = string
  description = "ID of the STACKIT project in which to deploy the nodes"
}

variable "node_count" {
  type        = number
  description = "Number of nodes to provision"
}

variable "ssh_key_name" {
  type        = string
  description = "Name of the STACKIT SSH keypair to use"
}

variable "node_name_suffix" {
  type        = string
  description = "Suffix to use for node names"
}

variable "network_id" {
  type        = string
  description = "ID of the network in which to create the nodes"
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of Security Group IDs to attach to the nodes"
}

variable "region" {
  type        = string
  description = "Region where to deploy nodes"
}

variable "machine_type" {
  type        = string
  description = "Machine type to use for nodes"
  default     = "g2i.4"
}

variable "image_id" {
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

variable "cluster_id" {
  type        = string
  description = "ID of the cluster to which the nodes belong, used for rendering machines and  machine sets"
}
