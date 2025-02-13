#cloud-config
timezone: "Europe/Stockholm"

write_files:
  # Create /etc/modules-load.d/k8s.conf to ensure necessary kernel modules are loaded on boot
  - path: /etc/modules-load.d/k8s.conf
    content: |
      overlay
      br_netfilter

  # Create /etc/sysctl.d/kubernetes.conf to apply sysctl settings for Kubernetes networking
  - path: /etc/sysctl.d/kubernetes.conf
    content: |
      net.bridge.bridge-nf-call-iptables  = 1
      net.bridge.bridge-nf-call-ip6tables = 1
      net.ipv4.ip_forward                 = 1

runcmd:
 - |
    # Define a cleanup function
    cleanup() {
        echo "[ERROR] ❌ An error occurred. Cleaning up..."
        # Add any cleanup commands you need here
        # For example, ensuring that services are stopped, temporary files are removed, etc.
    }

    # Set the trap to catch ERR signal and cleanup
    trap cleanup ERR

    # Disable SWAP
    swapoff -a
    sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

    # Load necessary kernel modules
    modprobe overlay
    modprobe br_netfilter

    # Apply sysctl settings for Kubernetes networking
    sysctl --system

    # Update package lists
    apt-get update

    # Upgrade any existing packages to the latest version
    apt-get upgrade -y

    # Install essential packages for repository access, updates, and more
    apt-get install -y apt-transport-https ca-certificates curl gpg locales socat software-properties-common

    # # Ensure the system's default locale is set to US English with UTF-8 encoding by updating the locale settings,
    # # generating necessary locale data, and applying the configuration across the system.
    # echo 'LANG=en_US.utf8' | tee /etc/default/locale
    # locale-gen en_US.utf8
    # update-locale LANG=en_US.utf8
    
    # Add Docker GPG key and repository
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --yes --dearmor -o /etc/apt/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    apt-get update

    # Install containerd
    apt-get install -y containerd.io

    # Configure containerd to use systemd as cgroup driver
    containerd config default | tee /etc/containerd/config.toml
    sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

    # Reload systemd daemon and restart containerd to apply proxy settings
    systemctl daemon-reload
    systemctl restart containerd
    systemctl enable containerd

    # Wait for containerd to be fully up with timeout
    attempt_counter=0
    max_attempts=15
    until systemctl is-active --quiet containerd; do
        if [ $${attempt_counter} -eq $${max_attempts} ]; then
          echo "[ERROR] ❌ Failed to start containerd after $${max_attempts} tries."
          exit 1
        fi
        attempt_counter=$((attempt_counter+1))
        echo "[INFO] Waiting for containerd to start... (Attempt $${attempt_counter}/$${max_attempts})"
        sleep 2
    done

    # Add Kubernetes GPG key and repository
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | gpg --yes --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list > /dev/null

    apt-get update -y

    # Install Kubernetes packages
    apt-get install -y kubelet kubeadm kubectl
    apt-mark hold kubelet kubeadm kubectl

    # Pull necessary container images for Kubernetes components in advance
    kubeadm config images pull --v=5

    # Enable and start the kubelet service
    systemctl enable --now kubelet

    # # Check if reboot is required and reboot if so
    # if [ -f /var/run/reboot-required ]; then
    #     shutdown -r now "Rebooting to apply updates"
    # fi
    
    # Reboot the machine to ensure all changes take effect
    echo -e "\n[INFO] Rebooting the machine to apply all changes...\n"
    reboot