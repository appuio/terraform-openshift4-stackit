variable "cluster_id" {
  type = string
}

variable "ignition_bootstrap" {
  type = string
  default = ""
}

variable "base_domain" {
  default = "ocp4-poc.appuio-beta.ch"
}

variable "region" {
  default = "rma1"
}

variable "ssh_keys" {
  type    = list(string)
  default = []
}

variable "privnet_cidr" {
  default = "172.18.200.0/24"
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

variable "worker_count" {
  type    = number
  default = 3
}

variable "router_servers" {
  type    = list(string)
  default = []
}
