#cloud-config
package_update: true
package_upgrade: true
# package_reboot_if_required: true

packages:
    - haproxy
    - nano

locale: "en_US.utf8"
timezone: "Europe/Stockholm"

write_files:
    # Write the HAProxy configuration file
    - path: /etc/haproxy/haproxy.cfg
      content: |
        global
            # Logging configuration
            log /dev/log local0
            log /dev/log local1 notice

            # Set the working directory and security settings
            chroot /var/lib/haproxy
            stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
            stats timeout 30s
            user haproxy
            group haproxy
            daemon

            # Explicitly specify SSL ciphers
            ssl-default-bind-ciphers HIGH:!aNULL:!MD5
            ssl-default-server-ciphers HIGH:!aNULL:!MD5

        defaults
            # Default logging and timeout settings
            log global
            option httplog
            option dontlognull
            timeout connect 5000
            timeout client  50000
            timeout server  50000

            # Default error files
            errorfile 400 /etc/haproxy/errors/400.http
            errorfile 403 /etc/haproxy/errors/403.http
            errorfile 408 /etc/haproxy/errors/408.http
            errorfile 500 /etc/haproxy/errors/500.http
            errorfile 502 /etc/haproxy/errors/502.http
            errorfile 503 /etc/haproxy/errors/503.http
            errorfile 504 /etc/haproxy/errors/504.http

        frontend http-in
            # The mode is HTTP since the frontend is an HTTP service
            mode http

            # Bind to port 80 for HTTP
            bind *:80

            # Redirect all HTTP traffic to HTTPS
            redirect scheme https code 301 if !{ ssl_fc }

        frontend https-in
            # The mode is HTTP since the frontend is an HTTP service
            mode http

            # Bind to port 443 for HTTPS with the SSL certificate
            bind *:443 ssl crt /etc/haproxy/ssl/haproxy.pem

            # Use the control plane nodes backend for HTTPS traffic
            default_backend ingress-controller-backend

        backend ingress-controller-backend
            # The mode is HTTP since the Ingress Controller is an HTTP service
            mode http

            # Load balance traffic to the Ingress Controller
            balance roundrobin

            # Direct traffic to the Ingress Controller
        #     server ingress-controller-worker-1 192.168.98.11:30289 check
        #     server ingress-controller-worker-2 192.168.98.6:30289 check
        #     server ingress-controller-worker-3 192.168.98.9:30289 check
        #     server ingress-controller-worker-4 192.168.98.4:30289 check

        frontend k8s-api
            # Bind to port 6443 for Kubernetes API
            bind *:6443

            # The option tcplog logs the client IP and port
            option tcplog

            # Use the control plane nodes backend
            default_backend control-plane-nodes

        backend control-plane-nodes
            # Load balancing strategy
            balance leastconn
            
            # Perform SSL checks on the backend nodes
            option ssl-hello-chk

            # Control plane node(s) with IP and port, check parameter ensures health checks
            # Add additional control plane nodes as needed
            # server <hostname> <ip>:6443 check
            ${haproxy_backend_servers}

runcmd:
  - |
    set -e

    # Create the directory for the SSL files if it doesn't exist
    mkdir -p /etc/haproxy/ssl

    # Generate a new RSA private key
    openssl genrsa -out /etc/haproxy/ssl/haproxy.key 2048

    # TODO: Replace the self-signed certificate with a certificate issued by a trusted Certificate Authority (CA).
    #       Self-signed certificates can cause trust issues with clients and are not recommended for production environments.

    # Generate a Certificate Signing Request (CSR) using the private key
    openssl req -new -key /etc/haproxy/ssl/haproxy.key -out /etc/haproxy/ssl/haproxy.csr -subj '/C=SE/ST=Kalmar County/L=Kalmar/O=Linneaus University/CN=www.lnu.se OU=2DV013 - Cloud Native Applications'

    # Generate a self-signed certificate using the CSR and private key from the previous steps
    # The certificate is valid for 365 days and is saved to /etc/haproxy/ssl/haproxy.crt
    openssl x509 -req -days 365 -in /etc/haproxy/ssl/haproxy.csr -signkey /etc/haproxy/ssl/haproxy.key -out /etc/haproxy/ssl/haproxy.crt

    # Combine the certificate and private key into one pem file as required by HAProxy
    cat /etc/haproxy/ssl/haproxy.crt /etc/haproxy/ssl/haproxy.key > /etc/haproxy/ssl/haproxy.pem

    # Enable HAProxy to start on boot
    systemctl enable haproxy

    # Restart HAProxy service
    # echo -e "\n[INFO] Sleeping for 10 seconds before restarting HAProxy service...\n"
    # sleep 10
    # systemctl restart haproxy

    # Reboot the machine to ensure all changes take effect
    echo -e "\n[INFO] Rebooting the machine to apply all changes...\n"
    reboot