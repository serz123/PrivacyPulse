#cloud-config
runcmd:
    # ---------------------------------------------------------
    # Clean up
    #

    # Inform that the system is performing clean-up to free up disk space
    - ["echo", "[INFO] Performing system clean-up"]

    # Clean up unneeded packages and their dependencies to free up disk space
    - apt-get autoremove -y

    # Clean up the local repository of downloaded package files
    - apt-get clean

# Message displayed upon completion of the cloud-init process
final_message: "[INFO] ✅ The system is finally up, after $UPTIME seconds"
