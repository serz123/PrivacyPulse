#cloud-config
package_update: true
package_upgrade: true

# Set locale and timezone
timezone: "Europe/Stockholm"

packages:
  - apt-transport-https
  - ca-certificates
  - curl
  - nano

# write_files:
#   # Handling writing Kubernetes APT keyrings
#   - path: /etc/apt/keyrings/kubernetes-apt-keyring.gpg
#     permissions: '0644'
#     content: |
#       `curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | gpg --dearmor`

#   # Handling writing Helm's GPG key
#   - path: /usr/share/keyrings/helm.gpg
#     permissions: '0644'
#     content: |
#       `curl https://baltocdn.com/helm/signing.asc | gpg --dearmor`

runcmd:
  - |
    echo "[INFO] Installing Kubectl and Helm..."

    # Add Kubernetes GPG key and repository
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | gpg --yes --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list > /dev/null

    # Add Kubernetes repository and install kubectl
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list

    # Download and add the Helm GPG key
    curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null

    # Add Helm repository and install Helm
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list

    apt-get update

    # Install both kubectl and helm in one go
    apt-get install -y kubectl helm

    # Verify installation
    if command -v kubectl && command -v helm; then
      echo "[INFO] Kubernetes and Helm installation successful."
    else
      echo "[ERROR] Installation failed. Reboot aborted."
      exit 1
    fi

    # Reboot the machine to ensure all changes take effect only if installation is successful
    echo -e "\n[INFO] Rebooting the machine to apply all changes...\n"
    reboot

