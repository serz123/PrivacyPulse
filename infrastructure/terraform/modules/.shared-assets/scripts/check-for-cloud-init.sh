#!/bin/bash

echo "[INFO] Starting check_for_cloud_init.sh script..."

# Check if the required number of arguments are provided
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 HOST_IP [IDENTITY_FILE]"
  exit 1
fi

# Set the IP address of the instance
HOST_IP=$1

# Check if an identity file is provided
if [ "$#" -ge 2 ]; then
  IDENTITY_OPTION="-i $2"
else
  IDENTITY_OPTION=""
fi

# Remove the host key for the specified IP address to avoid host key verification issues
ssh-keygen -f ~/.ssh/known_hosts -R $HOST_IP

# Wait for 10 seconds before starting the check
echo "[INFO] Beginning check for cloud-init completion for $HOST_IP..."

# Loop to check the cloud-init status every 30 seconds
for i in {1..30}; do
  echo "[INFO] Attempt $i of 30 to connect and verify cloud-init status for $HOST_IP..."

  # Wait for 30 seconds before trying
  sleep 30

   # Try to connect to the instance and check cloud-init status, capture both stderr and stdout
  raw_status=$(ssh -o StrictHostKeyChecking=no ${IDENTITY_OPTION} ubuntu@$HOST_IP "cloud-init status" 2>&1)
  ssh_exit_status=$?

  # Debug output for the raw SSH command response
  # echo "[DEBUG] 🐛 SSH exit status for $HOST_IP: $ssh_exit_status"
  # echo "[DEBUG] 🐛 Cloud-init status for $HOST_IP: $raw_status"

  # First, handle the SSH exit status
  if [[ $ssh_exit_status -ne 0 ]]; then
      # If SSH exit status is not 0, check for "Permission denied"
      if [[ $raw_status == *"Permission denied"* ]]; then
          echo "[ERROR] 🚫 Access denied when attempting to connect to $HOST_IP. Exiting script..."
          exit 1
      else
          echo "[WARNING] ⚠️ SSH connection failed for $HOST_IP. Will retry in 30 seconds..."
          ssh-keygen -f ~/.ssh/known_hosts -R $HOST_IP
      fi
  else
      # If SSH exit was successful, analyze raw_status for cloud-init outcomes
      if [[ $raw_status == *"status: done"* ]]; then
          echo "[INFO] 👉 Cloud-init process for $HOST_IP has completed."
          echo "[INFO] Exiting check_for_cloud_init.sh script..."
          sleep 30
          exit 0
      elif [[ $raw_status == *"status: running"* ]]; then
          echo "[INFO] Cloud-init process for $HOST_IP is still ongoing; please wait..."
      elif [[ $raw_status == *"status: error"* ]]; then
          # Determine prefix based on attempt number
          prefix="[INFO]"

          if [ "$i" -ge 15 ]; then
              prefix="[WARNING] ⚠️"
          fi

          echo "$prefix Temporary error detected in cloud-init status for $HOST_IP. Retrying..."
      else
          echo "[WARNING] ⚠️ Unexpected output for $HOST_IP: $raw_status. Will retry in 30 seconds..."
      fi
  fi
done

# If we reach this point, cloud-init did not complete successfully
echo "[ERROR] ❌ Timeout reached. Cloud-init did not complete successfully within the expected time frame."
exit 1
