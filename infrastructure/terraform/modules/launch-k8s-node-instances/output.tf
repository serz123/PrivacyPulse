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

output "control_plane_nodes" {
  description = "Information about the control plane node instances"
  value = [
    for i in range(length(openstack_compute_instance_v2.control_plane_nodes)) : {
      instance_id = openstack_compute_instance_v2.control_plane_nodes[i].id
      ip = openstack_compute_instance_v2.control_plane_nodes[i].access_ip_v4
    }
  ]
}

output "worker_nodes" {
  description = "Information about the worker node instances"
  value = [
    for i in range(length(openstack_compute_instance_v2.worker_nodes)) : {
      instance_id = openstack_compute_instance_v2.worker_nodes[i].id
      ip = openstack_compute_instance_v2.worker_nodes[i].access_ip_v4
    }
  ]
}
