# -----------------------------------------------------------------------------
# File: variables.tf
# Description: Contains variable definitions and local values to drive the 
#              network configuration and ensure scalability and reusability.
#
# Author: Mats Loock <mats.loock@lnu.se>
# Date: 2024-10-24
#
# Notes:
# - Default values are provided for ease of configuration.
# -----------------------------------------------------------------------------

# Variables related to network configuration

# Define the name of the external network
variable "external_network_name" {
  description = "External network name"
  type        = string
  default     = "public"  # Default to 'public' if not specified
}

# Define the CIDR range for the network
variable "subnet_cidr" {
  description = "CIDR range for the network"
  type = string
}

# Define the number of K8s nodes to create ports for
variable "k8s_node_count" {
  description = "Number of K8s nodes"
  type        = object({
    control_plane = number  # Number of control plane nodes
    worker = number  # Number of worker nodes
  })
  default = {
    control_plane = 4  # Default to 1 control plane port
    worker = 4  # Default to 1 worker port
  }
}

# Locals related to network configuration
# These local values help construct names and manage configurations for network resources.
locals {
  # External network name
  external_network_name = var.external_network_name

  # CIDR range for the network
  subnet_cidr = var.subnet_cidr 

  # Names for network resources
  network_name = "app-network"
  subnet_name  = "app-subnet"
  port_name    = "k8s-node-port"
  router_name  = "router"
  
  # Calculate the total number of K8s node ports to create
  k8s_node_port_count = var.k8s_node_count.control_plane + var.k8s_node_count.worker
}
