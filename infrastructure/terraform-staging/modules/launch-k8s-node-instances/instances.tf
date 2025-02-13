# -----------------------------------------------------------------------------
# File: instances.tf
# Description: Configures the deployment of the control plane and worker node 
#              instances, including network setup.
#
# Author: Mats Loock <mats.loock@lnu.se>
# Date: 2024-10-24
#
# Prerequisites:
# - Ensure network resources are provisioned and available.
#
# Usage:
# - Use this file to deploy and configure compute instances for K8s nodes.
# -----------------------------------------------------------------------------

# Creates a compute instance for the control plane nodes
resource "openstack_compute_instance_v2" "control_plane_nodes" {
  count             = length(var.control_plane_nodes)
  name              = "${var.k8s_node_base_names.control_plane}-${count.index + 1}"
  image_id          = data.openstack_images_image_v2.image.id
  flavor_id         = data.openstack_compute_flavor_v2.flavor.id
  key_pair          = var.key_pair_name
  availability_zone = "Education"
  user_data         = data.cloudinit_config.control_plane.rendered

  # Network configuration for the control plane nodes
  network {
    port = var.control_plane_nodes[count.index].port_id
  }
}

# Creates a compute instance for the worker nodes
resource "openstack_compute_instance_v2" "worker_nodes" {
  count             = length(var.worker_nodes)
  name              = "${var.k8s_node_base_names.worker}-${count.index + 1}"
  image_id          = data.openstack_images_image_v2.image.id
  flavor_id         = data.openstack_compute_flavor_v2.flavor.id
  key_pair          = var.key_pair_name
  availability_zone = "Education"
  user_data         = data.cloudinit_config.worker.rendered

  # Network configuration for the worker nodes
  network {
    port = var.worker_nodes[count.index].port_id
  }
}
