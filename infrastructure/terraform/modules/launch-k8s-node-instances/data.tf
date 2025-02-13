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

# Generate cloud-init configuration specifically for Kubernetes nodes
# This configuration includes the main cloud-init template, additional Kubernetes node settings,
# and general clean-up processes
data "cloudinit_config" "control_plane" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = local.k8s_node_cloud_init
    merge_type = "list(append)+dict(recurse_array)+str()"
  }

  # part {
  #   content_type = "text/cloud-config"
  #   content = local.k8s_control_plane_cloud_init
  #   merge_type = "list(append)+dict(recurse_array)+str()"
  # }

  part {
    content_type = "text/cloud-config"
    content = local.cloud_init_clean_up
    merge_type = "list(append)+dict(recurse_array)+str()"
  }
}

# Generate cloud-init configuration specifically for worker nodes
# This configuration includes the main cloud-init template for Kubernetes nodes and general clean-up processes
data "cloudinit_config" "worker" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = local.k8s_node_cloud_init
    merge_type = "list(append)+dict(recurse_array)+str()"
  }

  part {
    content_type = "text/cloud-config"
    content = local.cloud_init_clean_up
    merge_type = "list(append)+dict(recurse_array)+str()"
  }
}
