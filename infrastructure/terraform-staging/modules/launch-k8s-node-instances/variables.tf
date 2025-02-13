# -----------------------------------------------------------------------------
# File: create-k8s-node-instances/variables.tf
# Description: Defines variables and local values for instance configuration, 
#              providing flexibility and customizability for deployments.
#
# Author: Mats Loock <mats.loock@lnu.se>
# Date: 2024-10-24
#
# Notes:
# - Adjust variable defaults as needed to match environment specifications.
# -----------------------------------------------------------------------------

# Variables related to instances

# Defines the flavor for generic servers
variable "flavor_name" {
  description = "Server flavor"
  type        = string
  default     = "c2-r2-d20"
}

# Defines the image name for generic servers
variable "image_name" {
  description = "Server image"
  type        = string
  default     = "Ubuntu server 22.04.4"
}

# SSH key pair for Kubernetes nodes
variable "key_pair_name" {
  description = "SSH key pair for Kubernetes nodes"
  type        = string
}

variable "k8s_node_base_names" {
  description = "Base names for Kubernetes server nodes"
  type = object({
    control_plane = string
    worker        = string
  })
}

# Control plane nodes configuration
variable "control_plane_nodes" {
  description = "Configuration list for control plane nodes"
  type = list(object({
    port_id  = string
    ip       = string
  }))
}

# Worker nodes configuration
variable "worker_nodes" {
  description = "Configuration list for worker nodes"
  type = list(object({
    port_id  = string
    ip       = string
  }))
}

locals {
  # Cloud-init configuration for Kubernetes nodes
  k8s_node_cloud_init          = templatefile("${path.module}/templates/k8s-node-cloud-init.tpl", {})
  
  # Aditional cloud-init configuration part for the control plane
  k8s_control_plane_cloud_init = templatefile("${path.module}/templates/k8s-control-plane-cloud-init.tpl", {})

  # Cloud-init configuration for clean-up processes
  cloud_init_clean_up          = templatefile("${path.module}/../.shared-assets/templates/cloud-init-clean-up.tpl", {})
}
