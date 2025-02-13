# -----------------------------------------------------------------------------
# File: data.tf
# Description: Defines data sources to retrieve essential information from OpenStack, 
#              such as image and flavor IDs, as well as managing cloud-init templates.
#
# Author: Mats Loock <mats.loock@lnu.se>
# Date: 2024-10-24
#
# Prerequisites:
# - OpenStack access credentials must be configured.
#
# Usage:
# - This file is part of the pre-deployment process to gather IDs and templates 
#   needed by other Terraform configurations.
# -----------------------------------------------------------------------------

# Retrieve the ID of the specified image
# This data source fetches the most recent version of the image specified by 'image_name'
data "openstack_images_image_v2" "image" {
  name        = var.image_name  # Image name specified as a variable
  most_recent = true  # Ensures the most recent image is selected
}

# Retrieve the ID of the specified flavor
# This data source gets the flavor by name, defining the hardware profile for instances
data "openstack_compute_flavor_v2" "flavor" {
  name = var.flavor_name  # Flavor name specified as a variable
}

# Generate cloud-init configuration specifically for the jump host instance
# This uses the rendered templates to define multi-part MIME cloud-init configuration
data "cloudinit_config" "jump_host" {
  gzip          = false  # Configuration is not gzipped
  base64_encode = true   # Encodes the final configuration in base64

  part {
    content_type = "text/cloud-config"  # Type for the main cloud-config content
    content = local.jump_host_cloud_init  # Content for the jump host cloud-init configuration
    merge_type = "list(append)+dict(recurse_array)+str()"  # Merge strategy for parts
  }

  part {
    content_type = "text/cloud-config"
    content = local.cloud_init_clean_up
    merge_type = "list(append)+dict(recurse_array)+str()"
  }
}

# Generate cloud-init configuration specifically for the load balancer instance
# Configuration using HAProxy settings and general clean-up processes
data "cloudinit_config" "load_balancer" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = local.load_balancer_cloud_init
    merge_type = "list(append)+dict(recurse_array)+str()"
  }

  part {
    content_type = "text/cloud-config"
    content = local.cloud_init_clean_up
    merge_type = "list(append)+dict(recurse_array)+str()"
  }
}
