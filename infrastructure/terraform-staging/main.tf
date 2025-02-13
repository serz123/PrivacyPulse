# ----------------------------------------------------------------------------
# File: main.tf
# Description: Terraform setup for network and compute resources,
#              managing dependencies effectively.
#
# Author: Mats Loock <mats.loock@lnu.se>
# Date: 2024-10-24
#
# Prerequisites:
# - Ensure module paths are correct.
# - Ensure you set the corerct values for variables in `terraform.tfvars`.
#
# Usage:
# - Run `terraform init` and `terraform apply` to deploy infrastructure.
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Module: networks
# Sets up network components, including subnets for infrastructure.
# ----------------------------------------------------------------------------
module "networks" {
  source = "./modules/networks"

  # Number of instances to support within the network.
  k8s_node_count = {
    control_plane: 4,
    worker: 4
  }

  # CIDR range for the network.
  subnet_cidr = var.subnet_cidr
}

# ----------------------------------------------------------------------------
# Module: launch_frontend_instances
# Deploys frontend instances and configures network connections.
# ----------------------------------------------------------------------------
module "launch_frontend_instances" {
  source = "./modules/launch-frontend-instances"

  # Ensure correct resource instantiation order.
  depends_on = [
    module.networks,
  ]

  # Instance configuration with image details.
  image_name = var.image_name

  # Jump host instance specifics.
  jump_host = {
    key_pair_name = var.primary_key_pair_name
    name = "jump-host"
    port_id = module.networks.jump_host.port_id
  }

  # Load balancer instance specifics.
  load_balancer = {
    key_pair_name = openstack_compute_keypair_v2.app_keypair.name
    name = "load-balancer"
    port_id = module.networks.load_balancer.port_id
    
    # HAProxy backend server specifics.
    haproxy_backend_servers = [
      for node in module.networks.control_plane_nodes : {
        ip = node.ip
        hostname = node.hostname
      }
    ]
  }
}

# ----------------------------------------------------------------------------
# Module: provision_frontend_instances
# Ensures cloud-init completion for frontend instances before applying
# specific configurations tailored to the jump host and the load balancer.
# ----------------------------------------------------------------------------
module "provision_frontend_instances" {
  source = "./modules/provision-frontend-instances"

  # Maintain provisioning order.
  depends_on = [
    module.launch_frontend_instances,
    tls_private_key.app_private_key
  ]

  # SSH key configurations.
  identity = {
    primary_key_path = var.primary_key_path
    primary_private_key = local.primary_private_key
    app_private_key = tls_private_key.app_private_key.private_key_pem
  }

  # Jump host configurations.
  jump_host = {
    instance_id = module.launch_frontend_instances.jump_host.instance_id
    floating_ip = module.launch_frontend_instances.jump_host.floating_ip
    hostname = module.networks.jump_host.hostname
  }

  # Load balancer configurations.
  load_balancer = {
    instance_id = module.launch_frontend_instances.load_balancer.instance_id
    ip = module.launch_frontend_instances.load_balancer.ip
    hostname = module.networks.load_balancer.hostname
  }

  # Hosts to manage /etc/host.
  hosts = flatten([
    [{
      ip = module.launch_frontend_instances.jump_host.ip
      hostname = module.networks.jump_host.hostname
    }],
    [{
      ip = module.launch_frontend_instances.load_balancer.ip
      hostname = module.networks.load_balancer.hostname
    }],
    [for node in module.networks.control_plane_nodes : {
      ip = node.ip
      hostname = node.hostname
    }],
    [for node in module.networks.worker_nodes : {
      ip = node.ip
      hostname = node.hostname
    }]
  ])
}

# ----------------------------------------------------------------------------
# Module: launch_k8s_node_instances
# Deploys instances for Kubernetes control plane nodes and worker nodes.
# ----------------------------------------------------------------------------
module "launch_k8s_node_instances" {
  source = "./modules/launch-k8s-node-instances"

  # Link to gateway provisioning.
  depends_on = [
    module.provision_frontend_instances,
  ]

  # Image details for internal nodes.
  image_name = var.image_name

  # Key pair for K8s nodes.
  key_pair_name = openstack_compute_keypair_v2.app_keypair.name

  # Base names for K8s nodes.
  k8s_node_base_names = {
    control_plane: "control-plane",
    worker: "worker"
  }

  # Control plane node configurations.
  control_plane_nodes = [
    for node in module.networks.control_plane_nodes : {
      port_id = node.port_id
      ip = node.ip
    }
  ]

  # Worker node configurations.
  worker_nodes = [
    for node in module.networks.worker_nodes : {
      port_id = node.port_id
      ip = node.ip
    }
  ]
}

# ----------------------------------------------------------------------------
# Module: provision_k8s_node_instances
# Ensures cloud-init completion for K8s node instances before applying
# specific configurations tailored to the control plane and worker nodes.
# ----------------------------------------------------------------------------
module "provision_k8s_node_instances" {
  source = "./modules/provision-k8s-node-instances"

  # Establish order with internal instances module.
  depends_on = [
    module.launch_k8s_node_instances,
  ]

  # SSH access configurations.
  identity = {
    primary_private_key = local.primary_private_key
    app_private_key = tls_private_key.app_private_key.private_key_pem
  }

  jump_host = {
    instance_id = module.launch_frontend_instances.jump_host.instance_id
    floating_ip = module.launch_frontend_instances.jump_host.floating_ip
  }

  load_balancer = {
    instance_id = module.launch_frontend_instances.load_balancer.instance_id
    ip = module.launch_frontend_instances.load_balancer.ip
    hostname = module.networks.load_balancer.hostname
  }

  control_plane_nodes = [
    for idx in range(length(module.networks.control_plane_nodes)) : {
      instance_id = module.launch_k8s_node_instances.control_plane_nodes[idx].instance_id
      ip          = module.launch_k8s_node_instances.control_plane_nodes[idx].ip
      hostname    = module.networks.control_plane_nodes[idx].hostname
    }
  ]

  worker_nodes = [
    for idx in range(length(module.networks.worker_nodes)) : {
      instance_id = module.launch_k8s_node_instances.worker_nodes[idx].instance_id
      ip          = module.launch_k8s_node_instances.worker_nodes[idx].ip
      hostname    = module.networks.worker_nodes[idx].hostname
    }
  ]

    # Hosts to manage /etc/host.
  hosts = flatten([
    [{
      ip = module.launch_frontend_instances.jump_host.ip
      hostname = module.networks.jump_host.hostname
    }],
    [{
      ip = module.launch_frontend_instances.load_balancer.ip
      hostname = module.networks.load_balancer.hostname
    }],
    [for node in module.networks.control_plane_nodes : {
      ip = node.ip
      hostname = node.hostname
    }],
    [for node in module.networks.worker_nodes : {
      ip = node.ip
      hostname = node.hostname
    }]
  ])
}

# ----------------------------------------------------------------------------
# Resource: check_k8s_nodes
# Verifies Kubernetes node status and readiness.
# ----------------------------------------------------------------------------
resource "null_resource" "check_k8s_nodes" {
  depends_on = [
    module.provision_k8s_node_instances,
  ]

  # Connection using SSH through bastion host.
  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = module.launch_frontend_instances.jump_host.floating_ip
    private_key = local.primary_private_key
  }

  # Execute commands to check node status.
  provisioner "remote-exec" {
    inline = [
      "echo '[INFO] Waiting for Kubernetes nodes to be ready...'",
      "sleep 30",
      "echo '----------------------------------------------------------'",
      "echo ' 🟡 Kubernetes Nodes'",
      "echo '----------------------------------------------------------'",
      "kubectl get nodes",
      "echo '----------------------------------------------------------'",
    ]
  }
}
