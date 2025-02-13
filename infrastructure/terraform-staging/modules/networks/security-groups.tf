# -----------------------------------------------------------------------------
# File: networks/security-groups.tf
# Description: Configures security groups and rules to manage access and traffic
#              flow within the OpenStack environment.
#
# Author: Mats Loock <mats.loock@lnu.se>
# Date: 2024-10-24
#
# Notes:
# - Modify rules per security requirements for different environments.
# -----------------------------------------------------------------------------

resource "openstack_networking_secgroup_v2" "sg_ssh_access" {
  name        = "sg_ssh_access"
  description = "Allow SSH traffic on port 22"
}

resource "openstack_networking_secgroup_rule_v2" "sg_rule_ssh_ingress" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sg_ssh_access.id
}

resource "openstack_networking_secgroup_v2" "sg_http_https_access" {
  name        = "sg_http-https-access"
  description = "Allow HTTP and HTTPS traffic on ports 80 and 443"
}

resource "openstack_networking_secgroup_rule_v2" "sg_rule_http_https_ingress" {
  for_each = toset(["80", "443"])

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = each.value
  port_range_max    = each.value
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sg_http_https_access.id
}

resource "openstack_networking_secgroup_v2" "sg_internal_network" {
  name        = "sg_internal-network"
  description = "Security group for the internal network"
}

resource "openstack_networking_secgroup_rule_v2" "sg_rule_internal_ssh_ingress" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = openstack_networking_subnet_v2.subnet.cidr
  security_group_id = openstack_networking_secgroup_v2.sg_internal_network.id
}

resource "openstack_networking_secgroup_rule_v2" "sg_rule_internal_tcp_ingress" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = local.subnet_cidr
  security_group_id = openstack_networking_secgroup_v2.sg_internal_network.id
}
