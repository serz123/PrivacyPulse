# -----------------------------------------------------------------------------
# File: network.tf
# Description: Handles creation and configuration of network and subnet resources
#              within OpenStack.
#
# Author: Mats Loock <mats.loock@lnu.se>
# Date: 2024-10-24
#
# Notes:
# - Ensure network and subnet configurations meet your infrastructure needs.
# -----------------------------------------------------------------------------

resource "openstack_networking_network_v2" "network" {
  name = local.network_name
}

resource "openstack_networking_subnet_v2" "subnet" {
  name       = local.subnet_name
  network_id = openstack_networking_network_v2.network.id
  cidr       = local.subnet_cidr
  ip_version = 4
}
