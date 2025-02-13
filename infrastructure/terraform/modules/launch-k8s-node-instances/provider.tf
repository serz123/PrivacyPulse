# -----------------------------------------------------------------------------
# File: provision-k8s-node-instances/provider-setup.tf
# Description: Configures the OpenStack provider for Terraform, specifying
#              the necessary provider source to manage OpenStack resources
#              effectively within the infrastructure.
#
# Author: Mats Loock <mats.loock@lnu.se>
# Date: 2024-10-24
#
# Prerequisites:
# - Ensure Terraform is installed and accessible from your command line environment.
# - Make sure you have access credentials for the OpenStack environment.
#
# Usage:
# - Use this configuration to initialize the OpenStack provider, which allows
#   Terraform to interface with OpenStack resources for infrastructure management.
# -----------------------------------------------------------------------------

terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}
