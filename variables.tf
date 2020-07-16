variable "cluster_name" {
  type = string
}

variable "api_eip" {
  type = string
}

variable "base_domain" {
  default = "ocp4-poc.appuio-beta.ch"
}

variable "ssh_keys" {
  type = list(string)
  default = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFLCH/nL+U0/JCP7yA0dBFXVuD3tb4rSOr+etoK/KoOG srueg@iMac",
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJrwISQA3ZXaZaH4ThhYJxVpoinYghd/RUzpKRPRjWhU srueg@xps"
  ]
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

variable "ignition_template" {
  default = "./templates/ignition.tmpl"
}

variable "router_servers" {
  type    = list(string)
  default = []
}
