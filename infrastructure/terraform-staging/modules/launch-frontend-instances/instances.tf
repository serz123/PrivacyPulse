# -----------------------------------------------------------------------------
# File: launch-fronted-instances/instances.tf
# Description: Configures the deployment of the jump host and load balancer 
#              instances, including network setup and floating IP associations.
#
# Author: Mats Loock <mats.loock@lnu.se>
# Date: 2024-10-24
#
# Prerequisites:
# - Ensure network resources are provisioned and available.
#
# Usage:
# - Use this file to deploy and configure compute instances for gateway roles.
# -----------------------------------------------------------------------------

# Creates a compute instance for the jump host
resource "openstack_compute_instance_v2" "jump_host" {
  name              = var.jump_host.name
  image_id          = data.openstack_images_image_v2.image.id
  flavor_id         = data.openstack_compute_flavor_v2.flavor.id
  key_pair          = var.jump_host.key_pair_name
  availability_zone = "Education"
  user_data         = data.cloudinit_config.jump_host.rendered

  # Network configuration for the jump host
  network {
    port = var.jump_host.port_id
  }
}

# Allocates a floating IP for the jump host
resource "openstack_networking_floatingip_v2" "jump_host_floatingip" {
  pool = "public"  # Pool from which the floating IP is allocated
}

# Associates the floating IP with the jump host's port
resource "openstack_networking_floatingip_associate_v2" "jump_host_floatingip_association" {
  floating_ip = openstack_networking_floatingip_v2.jump_host_floatingip.address
  port_id     = var.jump_host.port_id
}

# Creates a compute instance for the load balancer
resource "openstack_compute_instance_v2" "load_balancer" {
  name              = var.load_balancer.name
  image_id          = data.openstack_images_image_v2.image.id
  flavor_id         = data.openstack_compute_flavor_v2.flavor.id
  key_pair          = var.load_balancer.key_pair_name
  availability_zone = "Education"
  user_data         = data.cloudinit_config.load_balancer.rendered

  # Network configuration for the load balancer
  network {
    port = var.load_balancer.port_id
  }

}

# Allocates a floating IP for the load balancer
resource "openstack_networking_floatingip_v2" "load_balancer_floatingip" {
  pool = "public"  # Pool from which the floating IP is allocated
}

# Associates the floating IP with the load balancer's port
resource "openstack_networking_floatingip_associate_v2" "load_balancer_floatingip_association" {
  floating_ip = openstack_networking_floatingip_v2.load_balancer_floatingip.address
  port_id     = var.load_balancer.port_id
}
