# -----------------------------------------------------------------------------
# File: /output.tf
# Description: Defines output variables for retrieving and displaying critical
#              information about the infrastructure, such as IP addresses.
#
# Author: Mats Loock <mats.loock@lnu.se>
# Date: 2024-10-24
#
# Notes:
# - Outputs are useful for accessing information post-deployment.
# - Grouping related outputs into a map can simplify referencing
#   and retrieval in other configurations or scripts.
# -----------------------------------------------------------------------------

# Output the hostnames, IP addresses of the jump host, load balancer, control
# plane nodes, and worker nodes in a structured format.
output "infrastructure_info" {
  description = "A list of objects containing the hostnames, IP addresses of the jump host, load balancer, control plane nodes, and worker nodes"
  value = concat(
    # List of objects containing the hostname, floating IPs and IPs of the jump host and load balancer.
    [
      {
        hostname = module.networks.jump_host.hostname
        floating_ip = module.launch_frontend_instances.jump_host.floating_ip
        ip = module.networks.jump_host.ip
      },
      {
        hostname = module.networks.load_balancer.hostname
        floating_ip = module.launch_frontend_instances.load_balancer.floating_ip
        ip = module.networks.load_balancer.ip
      }
    ],
    # List of objects containing the hostname and IP of the control plane nodes.
    [
      for node in module.networks.control_plane_nodes : {
        hostname = node.hostname
        ip = node.ip
      }
    ], 
    # List of objects containing the hostname and IP of the worker nodes.
    [
      for node in module.networks.worker_nodes : {
        hostname = node.hostname
        ip = node.ip
      }
    ]
  )
}
