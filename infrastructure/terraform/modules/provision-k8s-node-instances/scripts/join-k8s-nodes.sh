#!/bin/bash

# -----------------------------------------------------------------------------
# Script name: join-k8s-nodes.sh
# Author: Mats Loock <mats.loock@lnu.se>
# Date: 2024-10-24
#
# Description:
# This script joins multiple nodes to a Kubernetes cluster by fetching control
# plane and worker node IPs from the /etc/hosts file. It sets up kubeconfig and
# deploys the pod network as part of the process.
# -----------------------------------------------------------------------------

# Fetch IP addresses for control-plane nodes and worker nodes, excluding the primary control plane
control_plane_ips=$(awk '/control-plane-/ {print $1}' /etc/hosts | sed -n '2,$p' | paste -sd "," -)
worker_ips=$(awk '/worker-/ {print $1}' /etc/hosts | paste -sd "," -)

# Check if worker IPs are available
if [[ -z "$worker_ips" ]]; then
    echo -e "\n[ERROR] ❌ Worker IPs must be specified.\n"
    exit 1
fi

# Display cluster configuration details
echo -e "\n------------------------------------------------------------"
echo "[INFO] Control Plane Node IPs :  $control_plane_ips"
echo "[INFO] Worker Node IPs        :  $worker_ips"
echo -e "------------------------------------------------------------\n"

# Fetch the join command from the primary control plane node
join_command=$(ssh -o StrictHostKeyChecking=no control-plane-1 "sudo kubeadm token create --print-join-command")

# Convert comma-separated lists into arrays for easy iteration
IFS=',' read -r -a control_plane_ips_array <<< "${control_plane_ips}"
IFS=',' read -r -a worker_ips_array <<< "${worker_ips}"

# Iterate over each control plane node and execute the join command
if [[ -n "$control_plane_ips" ]]; then
    # Generate certificate key on the primary control plane node
    certificate_key=$(ssh -o StrictHostKeyChecking=no ubuntu@control-plane-1 "sudo kubeadm init phase upload-certs --upload-certs 2>/dev/null | tail -n 1")
    
    if [[ -n "$certificate_key" ]]; then
        echo -e "\n[INFO] Certificate generated successfully"
        echo "--certificate-keys $certificate_key"
        
        for IP in "${control_plane_ips_array[@]}"; do
            echo "[INFO] Joining control-plane node $IP"
            
            # Execute join command on the control plane node via SSH
            ssh -o StrictHostKeyChecking=no ubuntu@"${IP}" "sudo ${join_command} --control-plane --certificate-key ${certificate_key}"
        done
    else
        echo -e "\n[ERROR] ❌Failed to generate certificate\n"
        exit 1
    fi
else
    echo "[WARNING] ⚠️ No control plane nodes found in the hosts file."
fi

# Iterate over each worker node and execute the join command
for IP in "${worker_ips_array[@]}"; do
    echo "[INFO] Joining worker node $IP"
    
    # Execute join command on the worker node via SSH
    ssh -o StrictHostKeyChecking=no ubuntu@"${IP}" "sudo ${join_command}"
    
    # Fetch the node name (hostname) of the worker node
    NODE_NAME=$(ssh ubuntu@"${IP}" "hostname")
    echo "[INFO] Labeling worker node $NODE_NAME as worker"
    
    # Apply label on the worker node
    kubectl label nodes "${NODE_NAME}" node-role.kubernetes.io/worker=""
done

echo -e "\n---------------------------------------------------------"
echo "[INFO] Node join process completed."
echo "[INFO] All nodes have attempted to join the Kubernetes cluster."
echo -e "---------------------------------------------------------\n"
