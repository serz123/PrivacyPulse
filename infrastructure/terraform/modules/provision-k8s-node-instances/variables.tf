# -----------------------------------------------------------------------------
# File: provision-k8s-node-instances/variables.tf
# Description: Defines variables and local values for the module, managing
#              identity, network configurations, and instance details for jump
#              hosts, load balancers, and Kubernetes nodes. 
#              Facilitates consistent and flexible resource management.
#
# Author: Mats Loock <mats.loock@lnu.se>
# Date: 2024-11-05
#
# Prerequisites:
# - Ensure that the necessary network and identity configurations are available.
# - All variables specified must be provided to use this module effectively.
#
# Usage:
# - Use these configurations to define and access essential properties related 
#   to network and resource management in the wait_for_cloud_init module.
# -----------------------------------------------------------------------------

# Identity configuration, including keys for SSH access.
variable "identity" {
  description = "The identity configuration"
  type        = object({
    primary_private_key  = string
    app_private_key = string
  })
}

# Jump host configuration.
variable "jump_host" {
  description = "The jump host configuration"
  type        = object({
    instance_id = string
    floating_ip = string
  })
}

# Load balancer configuration.
variable "load_balancer" {
  description = "The load balancer configuration"
  type        = object({
    instance_id = string
    ip          = string
    hostname    = string
  })
}

# Control plane nodes configuration
variable "control_plane_nodes" {
  description = "Configuration list for control plane nodes"
  type = list(object({
    instance_id = string
    ip       = string
    hostname = string
  }))
}

# Worker nodes configuration
variable "worker_nodes" {
  description = "Configuration list for worker nodes"
  type = list(object({
    instance_id = string
    ip       = string
    hostname = string
  }))
}

variable "hosts" {
  description = "A list of all hosts to manage network configurations and host entries"
  type = list(object({
    ip       = string
    hostname = string
  }))
}
