# -----------------------------------------------------------------------------
# File: variables.tf
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
  default     = "c1-r1-d10"  # Default flavor setting
}

# Defines the image name for generic servers
variable "image_name" {
  description = "Server image"
  type        = string
  default     = "Ubuntu server 22.04.4"  # Default image to use
}

# Configuration for the jump host
variable "jump_host" {
  description = "The jump host configuration"
  type        = object({
    key_pair_name = string  # SSH key pair for jump host access
    name = string  # Name of the jump host server
    port_id = string  # Port ID for SSH access
  })
}

# Configuration for the load balancer
variable "load_balancer" {
  description = "The load balancer configuration"
  type        = object({
    key_pair_name = string  # SSH key pair for load balancer access
    name = string  # Name of the jump load balancer server
    port_id = string  # Port ID for SSH access
    haproxy_backend_servers = list(object({ # List of backend servers for HAProxy
      ip = string  # IP address associated with the port
      hostname = string  # Hostname for the control plane node
    }))
  })
}

locals {
  # Cloud-init configuration for the jump host
  jump_host_cloud_init = templatefile("${path.module}/templates/jump-host-cloud-init.tpl", {})

  # Cloud-init configuration for the load balancer using HAProxy
  load_balancer_cloud_init = templatefile("${path.module}/templates/load-balancer-cloud-init.haproxy.tpl", {
    haproxy_backend_servers = join("\n            ", [
      for node in var.load_balancer.haproxy_backend_servers :
      "server ${node.hostname} ${node.ip}:6443 check"
    ])

    # TODO: Now a string is passed with the backend servers to the template.
    # But I wolud like to pass a list of objects instead. Then I could use the
    # template something like this:
    #   %{ for node in haproxy_backend_servers ~}
    #   server ${node.hostname} ${node.ip}:6443 check
    #   %{ endfor ~}
  })

  # Cloud-init configuration for clean-up processes
  cloud_init_clean_up = templatefile("${path.module}/../.shared-assets/templates/cloud-init-clean-up.tpl", {})
}
