# -----------------------------------------------------------------------------
# File: ports.tf
# Description: Sets up port resources configured for various security and access
#              rules in the OpenStack environment.
#
# Author: Mats Loock <mats.loock@lnu.se>
# Date: 2024-10-24
#
# Notes:
# - Port configurations must align with security and access control policies.
# -----------------------------------------------------------------------------

resource "openstack_networking_port_v2" "jump_host_port" {
  name               = "jump-host-port"
  network_id         = openstack_networking_network_v2.network.id
  admin_state_up     = "true"
  security_group_ids = [
    data.openstack_networking_secgroup_v2.secgroup_default.id,
    openstack_networking_secgroup_v2.sg_internal_network.id,
    openstack_networking_secgroup_v2.sg_ssh_access.id,
  ]
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet.id
  }
}

resource "openstack_networking_port_v2" "load_balancer_port" {
  name               = "load-balancer-port"
  network_id         = openstack_networking_network_v2.network.id
  admin_state_up     = "true"
  security_group_ids = [
    data.openstack_networking_secgroup_v2.secgroup_default.id,
    openstack_networking_secgroup_v2.sg_internal_network.id,
    openstack_networking_secgroup_v2.sg_http_https_access.id,
  ]
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet.id
  }
}

resource "openstack_networking_port_v2" "k8s_node_port" {
  count              = local.k8s_node_port_count
  name               = "${local.port_name}-${count.index + 1}"
  network_id         = openstack_networking_network_v2.network.id
  admin_state_up     = "true"
  security_group_ids = [
    data.openstack_networking_secgroup_v2.secgroup_default.id,
    openstack_networking_secgroup_v2.sg_internal_network.id
  ]
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet.id
  }
}
