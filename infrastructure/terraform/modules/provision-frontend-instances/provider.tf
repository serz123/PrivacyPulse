# -----------------------------------------------------------------------------
# File: provision-frontend-instances/provider.tf
# Description: Configures the OpenStack provider for Terraform, specifying
#              the necessary provider source to manage OpenStack resources
#              effectively within the infrastructure.
#
# Author: [Your Name] <your.email@example.com>
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

# Configure the OpenStack provider by specifying the provider source.
terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}
