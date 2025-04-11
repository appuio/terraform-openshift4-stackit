locals {
  cluster_name          = var.cluster_name != "" ? var.cluster_name : var.cluster_id
  node_name_suffix      = "${local.cluster_name}.${var.base_domain}"
  create_privnet_subnet = var.network_id == "" ? 1 : 0
  subnet_uuid           = var.network_id == "" ? stackit_network.privnet[0].network_id : var.network_id
  privnet_cidr          = var.privnet_cidr
  worker_volume_size_gb = var.worker_volume_size_gb == 0 ? var.default_volume_size_gb : var.worker_volume_size_gb
  ssh_key_name          = var.existing_keypair != "" ? var.existing_keypair : stackit_key_pair.admin[0].name
}

resource "stackit_network" "privnet" {
  count              = local.create_privnet_subnet
  project_id         = var.stackit_project_id
  name               = "privnet-${var.cluster_id}"
  ipv4_prefix        = local.privnet_cidr
  ipv4_prefix_length = tonumber(split("/", local.privnet_cidr)[1])
  ipv4_nameservers   = ["1.1.1.1", "8.8.8.8", "9.9.9.9"]
  routed             = true
}

resource "stackit_key_pair" "admin" {
  count      = var.existing_keypair != "" ? 0 : 1
  name       = "${var.cluster_id}-admin"
  public_key = var.ssh_key
}

resource "stackit_security_group" "cluster_sg" {
  project_id = var.stackit_project_id
  name       = "cluster-sg-${var.cluster_id}"
}

resource "stackit_security_group_rule" "cluster_sg_rule" {
  project_id               = var.stackit_project_id
  security_group_id        = stackit_security_group.cluster_sg.security_group_id
  direction                = "ingress"
  remote_security_group_id = stackit_security_group.cluster_sg.security_group_id
}
