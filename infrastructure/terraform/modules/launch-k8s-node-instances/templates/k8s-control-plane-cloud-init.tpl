#cloud-config

runcmd:
  # Prepare the Kubernetes build environment
  - |
    # Pull necessary container images for Kubernetes components in advance
    kubeadm config images pull --v=5

    # Install Helm package manager for Kubernetes
    # Download and add the Helm GPG key
    curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null
    
    # Add the Helm stable repository to Ubuntu's package sources
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
    
    # Update package lists for the new Helm repository
    apt-get update
    
    # Install Helm
    apt-get install -y helm
