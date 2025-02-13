#!/bin/bash

# -----------------------------------------------------------------------------
# Script: k8s-primary-control-plane-node-setup.sh.
# Author: Mats Loock <mats.loock@lnu.se>
# Date: 2024-10-24
#
# Description:
# This script automates the setup of the Kubernetes Control Plane with specific
# configuration, such as a pod network CIDR and a load balancer IP.
# -----------------------------------------------------------------------------

# Function to handle errors
handle_error() {
    local exit_status=$?
    local command="$BASH_COMMAND"

    echo "[❌Error] Command '$command' failed with exit status $exit_status."
}

# Trap to execute handle_error function on ERR
trap 'handle_error' ERR

# Exit script on error
set -e

# Configure kubectl for the ubuntu user on the jump host
echo "[INFO] Configuring kubectl for the ubuntu user on the jump host..."

# Create the .kube directory if it does not exist
mkdir -p /home/ubuntu/.kube

# Copy the kubeconfig file to the jump host
ssh ubuntu@control-plane-1 "sudo cp /etc/kubernetes/admin.conf /home/ubuntu/admin.conf && sudo chown ubuntu:ubuntu /home/ubuntu/admin.conf"
scp ubuntu@control-plane-1:/home/ubuntu/admin.conf /home/ubuntu/.kube/config
ssh ubuntu@control-plane-1 "rm /home/ubuntu/admin.conf"

# Change ownership of the kubeconfig file to ubuntu user
sudo chown ubuntu:ubuntu /home/ubuntu/.kube/config

echo "[INFO] Kubectl configured for the ubuntu user on the jump host."

# Setup the Pod Network with Calico
echo "[INFO] Applying Calico Pod Network from the jump host..."

# Apply Calico network configuration from the jump host
sudo -i -u ubuntu bash -c 'kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml'

echo "[INFO] Calico Pod Network applied successfully from the jump host."

echo "[INFO] Installing the Ingress Nginx Controller..."

# Add the Ingress Nginx Controller repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

# Update the Helm repositories
helm repo update

# Install the Ingress Nginx Controller
helm install nginx-ingress ingress-nginx/ingress-nginx --namespace kube-system
