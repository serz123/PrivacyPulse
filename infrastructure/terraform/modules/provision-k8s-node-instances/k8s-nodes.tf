# -----------------------------------------------------------------------------
# File: provision-k8s-node-instances/k8s-nodes.tf
# Description: Automates the setup and configuration of Kubernetes nodes.
#              Includes steps to verify completion of cloud-init on all nodes,
#              configure the primary control plane node, and join additional
#              nodes to the cluster. Also updates the SSH known_hosts file on
#              the jump host as part of securing SSH communications.
#
# Author: Mats Loock <mats.loock@lnu.se>
# Date: 2024-11-05
#
# Prerequisites:
# - Ensure that network infrastructure is provisioned and nodes are
#   accessible via SSH.
# - Verify that cloud-init is installed and configured on all nodes.
#
# Usage:
# - Execute this configuration using Terraform to monitor and complete
#   the initial setup of Kubernetes nodes. This includes running cloud-init,
#   configuring the control plane, and joining worker nodes to the cluster.
# -----------------------------------------------------------------------------

# Resource to wait for cloud-init to complete on all Kubernetes nodes.
# Combines all control plane and worker nodes to monitor their initial
# setup readiness.
resource "null_resource" "wait_for_k8s_nodes_ready" {
  # Combine control plane and worker nodes into a map for iteration.
  for_each = merge(
    { for cp in var.control_plane_nodes : cp.hostname => cp.ip },
    { for w in var.worker_nodes : w.hostname => w.ip }
  )

  # Triggers to re-run the check when control plane or worker nodes'
  # instance IDs change.
  triggers = {
    control_plane_nodes = join(",", [for cp in var.control_plane_nodes : cp.instance_id]),
    worker_nodes        = join(",", [for w in var.worker_nodes : w.instance_id]),
  }

  # Configure SSH connection to the nodes via the jump host for secure
  # access.
  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = var.jump_host.floating_ip
    private_key = var.identity.primary_private_key
  }

  # Execute a script on each node to check for cloud-init completion.
  provisioner "remote-exec" {
    inline = [
      "echo '[INFO] Waiting for cloud-init to complete on ${each.key} (${each.value})...'",
      "bash ~/bin/check-for-cloud-init.sh ${each.value}"
    ]
  }
}

# Resource to configure the SSH known_hosts file on the jump host for all
# nodes. Ensures secure SSH connection configurations by managing host
# keys.
resource "null_resource" "configure_jump_host_ssh" {
  depends_on = [
    null_resource.wait_for_k8s_nodes_ready
  ]

  # Triggers reevaluation upon changes in instance IDs of involved hosts.
  triggers = {
    jump_host_instance_id = var.jump_host.instance_id,
    load_balancer_instance_id = var.load_balancer.instance_id,
    control_plane_nodes_ids = join(",", [for cp in var.control_plane_nodes : cp.instance_id]),
    worker_nodes_ids        = join(",", [for w in var.worker_nodes : w.instance_id]),
  }

  # Combine load balancer, control-plane and worker nodes into a single
  # map for SSH setup.
  for_each = merge(
    { (var.load_balancer.hostname) = var.load_balancer.ip },
    { for cp in var.control_plane_nodes : cp.hostname => cp.ip },
    { for w in var.worker_nodes : w.hostname => w.ip }
  )

  # SSH connection settings targeting the jump host to update known hosts.
  connection {
    type                = "ssh"
    user                = "ubuntu"
    private_key         = var.identity.primary_private_key
    agent               = true
    host                = var.jump_host.floating_ip
  }

  # Execute commands to update known_hosts files on the jump host.
  provisioner "remote-exec" {
    inline = [
      "echo '[INFO] Hashing host key for ${each.key} (IP: ${each.value})'",
      # Remove outdated entries and add current host keys for secure
      # connections.
      "ssh-keygen -f '~/.ssh/known_hosts' -R ${each.value} -q",
      "ssh-keyscan ${each.value} >> ~/.ssh/known_hosts 2>/dev/null",
    ]
  }
}

# Resource to setup and configure each Kubernetes node's system settings.
# Includes hostname setting and updating /etc/hosts for correct IP
# mappings.
resource "null_resource" "setup_k8s_node_configuration" {
  # Combine control plane and worker nodes into a map for configuration.
  for_each = merge(
    { for cp in var.control_plane_nodes : cp.hostname => cp.ip },
    { for w in var.worker_nodes : w.hostname => w.ip }
  )

  # Dependency ensures SSH configuration is complete before node setup.
  depends_on = [
    null_resource.configure_jump_host_ssh
  ]

  # Triggers setup re-run if related instance IDs change.
  triggers = {
    load_balancer_instance_id = var.load_balancer.instance_id,
    jump_host_instance_id = var.jump_host.instance_id,
    control_plane_node_ids = join(",", [for node in var.control_plane_nodes : node.instance_id]),
    worker_plane_node_ids = join(",", [for node in var.worker_nodes : node.instance_id]),
  }

  # SSH connection configuration through the jump host to each K8s node.
  connection {
    type                = "ssh"
    user                = "ubuntu"
    private_key         = var.identity.app_private_key
    bastion_host        = var.jump_host.floating_ip
    bastion_private_key = var.identity.primary_private_key
    agent               = true
    host                = each.value
  }

  # Execute configuration commands remotely on each node.
  provisioner "remote-exec" {
    inline = flatten([
      [
        # Set the system hostname on the node for clear identity.
        "sudo hostnamectl set-hostname ${each.key}",
      ],
      # Update /etc/hosts for reliable hostname-to-IP mappings.
      [for host in var.hosts : <<-EOT
        sudo sed -i -e "/${host.ip}/d" -e "/${host.hostname}/d" /etc/hosts 2>&1
        echo '${host.ip} ${host.hostname}' | sudo tee -a /etc/hosts 2>&1
      EOT
      ]
    ])
  }
}

# Resource to initialize the Kubernetes control plane using kubeadm.
# Ensures primary control plane node setup is correctly executed.
resource "null_resource" "setup_k8s_control_plane" {
  depends_on = [
    null_resource.setup_k8s_node_configuration
  ]

  # List of triggers to ensure re-execution if important instance IDs
  # update.
  triggers = {
    load_balancer_instance_id = var.load_balancer.instance_id,
    control_plane_instance_id = var.control_plane_nodes[0].instance_id,
  }

  # SSH connection details to access the primary control plane node.
  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = var.jump_host.floating_ip
    private_key = var.identity.primary_private_key
  }

  # Run the setup script on the control plane, defined in a template.
  provisioner "remote-exec" {
    inline = [
      # "${local.k8s_primary_control_plane_node_setup_script}",
      "echo '[INFO] Initializing Kubernetes Control Plane with the load balancer IP: ${var.load_balancer.ip}...'",
      "ssh -o StrictHostKeyChecking=no ubuntu@control-plane-1 'sudo kubeadm init --pod-network-cidr 172.29.0.0/16 --upload-certs --control-plane-endpoint ${var.load_balancer.ip}:6443'",
      "echo '[INFO] Kubeadm initialization succeeded.'"
    ]
  }
}

# Resource to join worker and control plane nodes to the Kubernetes
# cluster. Executes the join script on the appropriate nodes to complete
# setup.
resource "null_resource" "join_k8s_nodes_to_cluster" {
  depends_on = [
    null_resource.setup_k8s_control_plane
  ]

  # Triggers for re-running the join process if instance identifiers
  # change.
  triggers = {
    control_plane_nodes_ids = join(",", [for cp in var.control_plane_nodes : cp.instance_id]),
    worker_nodes_ids        = join(",", [for w in var.worker_nodes : w.instance_id]),
  }

  # SSH connection configuration to access the nodes via the jump host.
  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = var.jump_host.floating_ip
    private_key = var.identity.primary_private_key
  }

  # Execute the join script to integrate nodes into the Kubernetes
  # cluster.
  provisioner "remote-exec" {
    inline = [
      "${file("${path.module}/scripts/join-k8s-nodes.sh")}"
    ]
  }
}

# Resource to initialize the Kubernetes control plane using kubeadm.
# Ensures primary control plane node setup is correctly executed.
resource "null_resource" "jump_host_k8s_setup" {
  depends_on = [
    null_resource.join_k8s_nodes_to_cluster
  ]

  # List of triggers to ensure re-execution if important instance IDs
  # update.
  triggers = {
    jump_host_instance_id = var.jump_host.instance_id,
    control_plane_nodes_ids = join(",", [for cp in var.control_plane_nodes : cp.instance_id]),
    worker_nodes_ids        = join(",", [for w in var.worker_nodes : w.instance_id]),
  }

  # SSH connection details to access the primary control plane node.
  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = var.jump_host.floating_ip
    private_key = var.identity.primary_private_key
  }

  # Run the setup script on the control plane, defined in a template.
  provisioner "remote-exec" {
    inline = [
      "${file("${path.module}/scripts/jump-host-k8s-setup.sh")}"
    ]
  }
}
