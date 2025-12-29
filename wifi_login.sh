#!/bin/bash

# ==============================================================================
# WiFi Auto-Login Script for https://10.100.1.1:8090/httpclient.html
# ==============================================================================

# Get the directory where the script is stored
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.env"

# Load Configuration
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Error: Configuration file not found at $CONFIG_FILE"
    exit 1
fi

# Check Dependencies
for cmd in curl jq ping; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: Required command '$cmd' is not installed."
        sudo apt install $cmd -y 2>/dev/null || echo "Please install $cmd manually."
        exit 1
    fi
done

echo "[$(date)] WiFi Login Service Started."

# ==============================================================================
# PHASE 1: Network Detection Loop
# Wait for a connection to be established (either Home or Campus)
# ==============================================================================
echo "Waiting for network connection..."

while true; do
    # 1. Check for Internet (e.g. Home WiFi)
    # If we can reach Google DNS, we are already online. No need to login.
    # We assume "Other Network" = Internet Access is working.
    if ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
        echo "Internet connection detected (Home/Other WiFi). Exiting."
        exit 0
    fi

    # 2. Check for Campus Gateway
    # If we can reach 10.100.1.1, we are on the Campus WiFi (but likely offline).
    if ping -c 1 -W 2 "$GATEWAY_IP" >/dev/null 2>&1; then
        echo "Campus Gateway ($GATEWAY_IP) detected. Proceeding to login..."
        break
    fi

    # 3. Not connected to anything yet. Wait.
    echo "No network detected. Retrying in 5 seconds..."
    sleep 5
done

# ==============================================================================
# PHASE 2: Login Loop
# Iterate through credentials until connected
# ==============================================================================

while true; do
    # Verify we still need internet (double check)
    if ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
        echo "Internet Access Verified. Login successful or not needed."
        exit 0
    fi

    echo "Starting Credential Rotation..."
    LOGIN_SUCCESS=false

    for cred in "${CREDENTIALS[@]}"; do
        # Split "user:pass" string
        IFS=":" read -r username password <<< "$cred"
        
        echo "Trying user: $username"
        
        # Send Login Request
        # Common Cyberoam/Sophos fields: mode=191 (login), username, password
        response=$(curl -k -s -d "mode=191&username=$(echo "$username" | jq -sRr @uri)&password=$(echo "$password" | jq -sRr @uri)" "$BASE_URL")
        
        # Check Response for "Limit Exceeded"
        if echo "$response" | grep -iqE "limit exceeded|maximum login|already signed in"; then
            echo " -> Limit exceeded for $username. Skipping."
            continue
        fi

        # Check if login worked by verifying internet
        sleep 1
        if ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
            echo " -> Success! Internet is active."
            LOGIN_SUCCESS=true
            break
        fi
        
        # Optional: Add small delay between attempts so simply wrong passwords don't hammer the server
        echo " -> Failed. Trying next..."
        sleep 1
    done

    if [ "$LOGIN_SUCCESS" = true ]; then
        # Send a final notification (optional, visible if run in terminal)
        echo "Connected to Campus WiFi."
        exit 0
    else
        echo "All credentials exceeded or failed. Retrying entire list in 10 seconds..."
        sleep 10
    fi
done
