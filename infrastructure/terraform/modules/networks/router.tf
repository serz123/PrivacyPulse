# -----------------------------------------------------------------------------
# File: router.tf
# Description: Manages routers and interfaces connecting subnets to external 
#              networks in OpenStack.
#
# Author: Mats Loock <mats.loock@lnu.se>
# Date: 2024-10-24
#
# Notes:
# - Routers are crucial for directing traffic between different networks.
# -----------------------------------------------------------------------------

resource "openstack_networking_router_v2" "router" {
  name                = local.router_name
  external_network_id = data.openstack_networking_network_v2.extnet.id
}

resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.subnet.id
}
