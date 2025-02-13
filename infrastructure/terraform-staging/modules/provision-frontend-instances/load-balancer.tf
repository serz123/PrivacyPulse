# -----------------------------------------------------------------------------
# File: provision-frontend-instances/load-balancer.tf
# Description: Automates the setup and configuration of the load balancer.
#              Ensures that cloud-init has completed on the load balancer
#              and configures it with appropriate settings including hostname
#              and /etc/hosts entries through a jump host.
#
# Author: Mats Loock <mats.loock@lnu.se>
# Date: 2024-10-24
#
# Prerequisites:
# - Ensure that the load balancer is provisioned and accessible via SSH.
# - Verify that cloud-init is installed and properly configured on the load balancer.
#
# Usage:
# - Deploy this configuration using Terraform to automate the setup and 
#   configuration of the load balancer. It includes waiting for cloud-init
#   completion and executing setup commands for hostname and host entries.
# -----------------------------------------------------------------------------

# Resource to wait for the load balancer to be ready after cloud-init completion.
# This ensures the load balancer is fully initialized before any further
# configuration is performed. It relies on the presence of a configured 
# jump host to access the load balancer via SSH.
resource "null_resource" "wait_for_load_balancer_ready" {
  # Ensure the jump host is configured before waiting for load balancer readiness.
  depends_on = [
    null_resource.configure_jump_host
  ]

  # Trigger a rerun if the instance IDs of the load balancer or jump host change.
  triggers = {
    load_balancer_instance_id = var.load_balancer.instance_id,
    jump_host_instance_id     = var.jump_host.instance_id
  }

  # Configure SSH connection to the jump host.
  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = var.jump_host.floating_ip
    private_key = var.identity.primary_private_key
  }

  # Execute a script to check for cloud-init completion on the load balancer.
  provisioner "remote-exec" {
    inline = [
      "set -e",
      "echo '[INFO] Waiting for cloud-init to complete on load balancer (${var.load_balancer.ip})...'",
      "bash ~/bin/check-for-cloud-init.sh ${var.load_balancer.ip}",
    ]
  }
}

# Resource to configure the load balancer once it is ready post-cloud-init.
# This includes setting the hostname and updating /etc/hosts for accurate host
# resolution within the network.
resource "null_resource" "configure_load_balancer" {
  # Depends on load balancer readiness to proceed with configuration.
  depends_on = [
    null_resource.wait_for_load_balancer_ready
  ]

  # Trigger reevaluation if the instance ID changes, or if the hosts change.
  triggers = {
    load_balancer_instance_id = var.load_balancer.instance_id,
    jump_host_instance_id     = var.jump_host.instance_id,
    hosts_encoded             = jsonencode(var.hosts)
  }

  # SSH connection setup through the jump host to the load balancer.
  connection {
    type                = "ssh"
    user                = "ubuntu"
    private_key         = var.identity.app_private_key
    bastion_host        = var.jump_host.floating_ip
    bastion_private_key = var.identity.primary_private_key
    agent               = true
    host                = var.load_balancer.ip
  }

  # Execute commands to set hostname and manage /etc/hosts entries.
  provisioner "remote-exec" {
    inline = flatten([
      [
        # Set the hostname on the load balancer for proper identification.
        "sudo hostnamectl set-hostname ${var.load_balancer.hostname}"
      ],
      # Update /etc/hosts for clear hostname-to-IP mappings.
      [for host in var.hosts : <<-EOT
        sudo sed -i -e "/${host.ip}/d" -e "/${host.hostname}/d" /etc/hosts 2>&1
        echo '${host.ip} ${host.hostname}' | sudo tee -a /etc/hosts 2>&1
      EOT
      ]
    ])
  }
}
