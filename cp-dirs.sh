#!/bin/bash

# Validate IP address
if [ -z "$IP_ADDRESS" ]; then
    echo "Error: IP_ADDRESS environment variable is not set"
    exit 1
fi

# Function to check SSH connection
check_connection() {
    if ! ssh -p 8022 -q root@$IP_ADDRESS exit; then
        echo "Error: Cannot connect to $IP_ADDRESS"
        exit 1
    fi
}

# Function to copy termux files
copy_termux_files() {
    echo "Copying Termux files..."
    if sudo scp -P 8022 -r ~/mobhos/data/data/com.termux/files root@$IP_ADDRESS:/data/data/com.termux/; then
        echo "Termux files copied successfully"
    else
        echo "Error: Failed to copy Termux files"
        exit 1
    fi
}

# Function to copy web files
copy_web_files() {
    echo "Copying web files..."
    if sudo scp -P 8022 -r $APK_LOCAL_PATH root@$IP_ADDRESS:$APK_DESTINATION_PATH; then
        echo "Web files copied successfully"
    else
        echo "Error: Failed to copy web files"
        exit 1
    fi
}

# Main execution
check_connection
copy_termux_files
copy_web_files

echo "All files copied successfully"
exit 0
