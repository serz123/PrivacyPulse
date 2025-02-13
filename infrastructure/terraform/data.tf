# -----------------------------------------------------------------------------
# File: data.tf
# Description: This file contains data sources and resource definitions for
#              retrieving essential information from OpenStack and creating 
#              necessary resources for authentication and networking.
#
# Author: Mats Loock <mats.loock@lnu.se>
# Date: 2024-10-24
#
# Prerequisites:
# - Ensure OpenStack credentials are properly set.
#
# Usage:
# - This configuration is utilized by the main Terraform setup to provision
#   and manage networking resources.
# -----------------------------------------------------------------------------

# Retrieve information about the specified external network using its name
# This data source fetches details about the external network defined by the variable 'external_network_name'
data "openstack_networking_network_v2" "extnet" {
  name = var.external_network_name
}

# Retrieve the ID of the default security group in OpenStack
# This data source obtains the default security group, which can be used to manage security rules for instances
data "openstack_networking_secgroup_v2" "secgroup_default" {
  name = "default"
}

# Generate an RSA SSH key pair using 4096 bits
# This resource generates a secure SSH key pair that can be used for server authentication
resource "tls_private_key" "app_private_key" {
  algorithm = "RSA"  # RSA algorithm is chosen, which is common for SSH keys
  rsa_bits  = 4096   # Using 4096 bits for enhanced security
}

# Create an OpenStack key pair using the public key from the generated RSA key pair
# This resource uploads the generated public key to OpenStack, allowing instances to be accessed using SSH
resource "openstack_compute_keypair_v2" "app_keypair" {
  name       = "app_keypair"
  public_key = replace(tls_private_key.app_private_key.public_key_openssh, "\n", "")  # Format the public key for use in OpenStack
}
