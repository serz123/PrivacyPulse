# -----------------------------------------------------------------------------
# File: provision-frontend-instances/jump-host.tf
# Description: Automates the provisioning and configuration of the jump host.
#              Ensures that cloud-init has completed on the jump host and
#              configures it by setting up necessary directories, SSH keys,
#              scripts, and system settings.
#
# Author: Mats Loock <mats.loock@lnu.se>
# Date: 2024-10-24
#
# Prerequisites:
# - Ensure that the jump host is provisioned and accessible via SSH.
# - Verify that cloud-init is installed and properly configured on the jump host.
#
# Usage:
# - Deploy this configuration using Terraform to automate the initial setup
#   and configuration of the jump host. It includes waiting for cloud-init
#   completion and executing setup scripts for SSH and environment configurations.
# -----------------------------------------------------------------------------

# Resource to wait for the jump host to be ready after cloud-init completion.
# This ensures the jump host is fully initialized before any further
# operations. Completion of cloud-init is essential for subsequent SSH 
# configurations and script setups on the jump host.
resource "null_resource" "wait_for_jump_host_ready" {
  # Trigger a rerun if the jump host's instance ID changes.
  triggers = {
    instance_id = var.jump_host.instance_id
  }

  # Local execution to verify cloud-init completion on the jump host.
  # Use bash to prevent need to set executable permissions on the script.
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "bash ${path.module}/../.shared-assets/scripts/check-for-cloud-init.sh ${var.jump_host.floating_ip} ${var.identity.primary_key_path}"
  }
}

# Resource to configure the jump host once it is ready post-cloud-init. 
# This includes setting up directories, installing scripts, and configuring 
# SSH key settings.
resource "null_resource" "configure_jump_host" {
  # Dependency on the jump host being ready before proceeding with configuration.
  depends_on = [
    null_resource.wait_for_jump_host_ready
  ]

  # Trigger reevaluation if the jump host instance ID changes.
  triggers = {
    jump_host_instance_id = var.jump_host.instance_id
  }

  # SSH connection setup to the jump host for executing configuration steps.
  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = var.jump_host.floating_ip
    private_key = var.identity.primary_private_key
    timeout     = "2m"
  }

  # Create necessary directories on the jump host.
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/ubuntu/bin",
    ]
  }

  # Transfer scripts to the jump host's bin directory.
  provisioner "file" {
    source      = "${path.module}/../.shared-assets/scripts/check-for-cloud-init.sh"
    destination = "/home/ubuntu/bin/check-for-cloud-init.sh"
  }

  # Execute setup commands to configure environment and SSH settings.
  provisioner "remote-exec" {
    inline = flatten([
      [
        # Convert line endings for compatibility (HACK: Windows to UNIX)
        "sed -i 's/\\r$//' /home/ubuntu/bin/*.sh",

        # Make scripts executable
        "chmod +x /home/ubuntu/bin/*",

        # Add SSH agent and add key commands to .bashrc
        "echo 'eval \"$(ssh-agent)\"' >> /home/ubuntu/.bashrc",
        "echo 'ssh-add' >> /home/ubuntu/.bashrc",

        # Ensure .ssh directory exists, write private key, set permissions
        "mkdir -p ~/.ssh",
        "echo '${var.identity.app_private_key}' > /home/ubuntu/.ssh/id_rsa",
        "chmod 600 /home/ubuntu/.ssh/id_rsa",

        # Set the hostname on the jump host for identification
        "sudo hostnamectl set-hostname ${var.jump_host.hostname}",
      ],
      # Update /etc/hosts for hostname-to-IP mapping
      [for host in var.hosts : <<-EOT
        sudo sed -i -e "/${host.ip}/d" -e "/${host.hostname}/d" /etc/hosts 2>&1
        echo '${host.ip} ${host.hostname}' | sudo tee -a /etc/hosts 2>&1
      EOT
      ]
    ])
  }
}
