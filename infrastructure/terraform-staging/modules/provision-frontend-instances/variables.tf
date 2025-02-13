# -----------------------------------------------------------------------------
# File: provision-frontend-instances/variables.tf
# Description: Defines variables and local values for the wait_for_cloud_init
#              module, managing identity, network configurations, and instance
#              details for jump hosts, load balancers, and Kubernetes nodes.
#
# Author: [Your Name] <your.email@example.com>
# Date: 2024-10-24
#
# Prerequisites:
# - Ensure that the necessary network and identity configurations are available.
# - All variables specified must be provided to use this module effectively.
#
# Usage:
# - Use these configurations to define and access essential properties related
#   to network and resource management in the wait_for_cloud_init module.
# -----------------------------------------------------------------------------

# Identity configuration, including paths and keys for SSH access.
variable "identity" {
  description = "The identity configuration"
  type = object({
    primary_key_path     = string
    primary_private_key  = string
    app_private_key = string
  })
}

# Jump host configuration, containing its instance ID and floating IP address.
variable "jump_host" {
  description = "The jump host configuration"
  type = object({
    instance_id = string
    floating_ip = string
    hostname    = string
  })
}

# Load balancer configuration, which includes its instance ID.
variable "load_balancer" {
  description = "The load balancer configuration"
  type = object({
    instance_id = string
    ip          = string
    hostname    = string
  })
}

variable "hosts" {
  description = "A list of all hosts to manage network configurations and host entries"
  type = list(object({
    ip       = string
    hostname = string
  }))
}
