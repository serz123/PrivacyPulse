# -----------------------------------------------------------------------------
# File: data.tf
# Description: Retrieves necessary data from existing OpenStack resources, such as 
#              network and security configurations, to integrate with new infrastructure.
#
# Author: Mats Loock <mats.loock@lnu.se>
# Date: 2024-10-24
#
# Prerequisites:
# - Ensure the network and security group exist in OpenStack.
#
# Usage:
# - This file is used by other Terraform configurations to leverage existing 
#   resources in OpenStack.
# -----------------------------------------------------------------------------

# Retrieve details for a specific external network
# This data source fetches the network details using the name stored in 'local.external_network_name'
data "openstack_networking_network_v2" "extnet" {
  name = local.external_network_name  # External network name defined in local values
}

# Retrieve details for the default security group
# This data source acquires the ID and details of the default security group, used for managing security rules
data "openstack_networking_secgroup_v2" "secgroup_default" {
  name = "default"  # Name of the default security group
}
