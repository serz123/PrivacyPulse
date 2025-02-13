# -----------------------------------------------------------------------------
# File: output.tf
# Description: Outputs configuration for collecting and exposing key details about 
#              deployed resources, such as instance IDs and IP addresses.
#
# Author: Mats Loock <mats.loock@lnu.se>
# Date: 2024-10-24
#
# Usage:
# - Provides essential details for further integration and monitoring tasks.
# -----------------------------------------------------------------------------

output "jump_host" {
  description = "Information about the jump host instance"
  value = {
    instance_id = openstack_compute_instance_v2.jump_host.id
    floating_ip = openstack_networking_floatingip_associate_v2.jump_host_floatingip_association.floating_ip
    ip          = openstack_compute_instance_v2.jump_host.access_ip_v4
  }
}

output "load_balancer" {
  description = "Information about the load balancer instance"
  value = {
    instance_id = openstack_compute_instance_v2.load_balancer.id
    floating_ip = openstack_networking_floatingip_associate_v2.load_balancer_floatingip_association.floating_ip
    ip          = openstack_compute_instance_v2.load_balancer.access_ip_v4
  }
}
