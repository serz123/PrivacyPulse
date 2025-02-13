# -----------------------------------------------------------------------------
# File: networks/output.tf
# Description: Specifies output variables to retrieve key identifiers and 
#              network properties post-deployment. Outputs include details 
#              about the jump host, load balancer, and Kubernetes nodes 
#              (control plane and worker nodes), facilitating integration 
#              and management operations by exposing essential network 
#              resources details.
#
# Author: Mats Loock <mats.loock@lnu.se>
# Date: 2024-10-24
#
# Usage:
# - Provides structured outputs for resource identifiers and attributes after 
#   applying the Terraform configuration.
# - Outputs are logically organized to support downstream automation, 
#   integration tasks, and operational clarity.
# - This file eliminates the need for dynamic hostname construction by using 
#   predefined naming conventions for clarity and simplicity.
# -----------------------------------------------------------------------------

# Output for the jump host details
output "jump_host" {
  description = "Details for the jump host including port ID and IP address"
  value = {
    port_id  = openstack_networking_port_v2.jump_host_port.id,
    ip       = openstack_networking_port_v2.jump_host_port.all_fixed_ips[0],
    hostname = "jump-host"
  }
}

# Output for the load balancer details
output "load_balancer" {
  description = "Details for the load balancer including port ID and IP address"
  value = {
    port_id  = openstack_networking_port_v2.load_balancer_port.id,
    ip       = openstack_networking_port_v2.load_balancer_port.all_fixed_ips[0],
    hostname = "load-balancer"
  }
}

# Output for the control plane nodes
output "control_plane_nodes" {
  description = "List of objects containing the IPs and hostnames of control plane nodes"
  value = [
    # Iterate over the list of ports for control plane nodes
    for i, port in slice(openstack_networking_port_v2.k8s_node_port, 0, var.k8s_node_count.control_plane) : {
      port_id  = port.id,
      # Conditionally extract the first fixed IP or raise an error if none exist
      ip       = length(port.all_fixed_ips) > 0 ? port.all_fixed_ips[0] : error(format("Error: IP address is not assigned to port ID %s.", port.id)),
      # Construct the hostname using a hardcoded base name and append an index if more than one control plane node exists
      hostname = format("control-plane%s", var.k8s_node_count.control_plane > 1 ? format("-%d", i + 1) : "")
    }
  ]
}

# Output for the worker nodes
output "worker_nodes" {
  description = "List of objects containing the IPs and hostnames of worker nodes"
  value = [
    # Iterate over the list of ports for worker nodes
    for i, port in slice(openstack_networking_port_v2.k8s_node_port, var.k8s_node_count.control_plane, length(openstack_networking_port_v2.k8s_node_port)) : {
      port_id  = port.id,
      # Conditionally extract the first fixed IP or raise an error if none exist
      ip       = length(port.all_fixed_ips) > 0 ? port.all_fixed_ips[0] : error(format("Error: IP address is not assigned to port ID %s.", port.id)),
      # Construct the hostname using a hardcoded base name and append an index if more than one worker node exists
      hostname = format("worker%s", var.k8s_node_count.worker > 1 ? format("-%d", i + 1) : "")
    }
  ]
}
