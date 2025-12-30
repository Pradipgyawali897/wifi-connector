#!/bin/bash

# Definition of colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Setting up WiFi Auto-Login Service...${NC}"

# Get the absolute path of the current directory
INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="$INSTALL_DIR/wifi_login.sh"

# 1. Make the main script executable
if [ -f "$SCRIPT_PATH" ]; then
    chmod +x "$SCRIPT_PATH"
    echo "Made $SCRIPT_PATH executable."
else
    echo -e "${RED}Error: wifi_login.sh not found in $INSTALL_DIR${NC}"
    exit 1
fi

# 2. Check for dependencies
echo "Checking dependencies..."
deps=("curl" "jq" "ping")
for cmd in "${deps[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "${RED}Missing dependency: $cmd${NC}"
        echo "Please install it (e.g., sudo apt install $cmd)"
        exit 1
    fi
done
echo "All dependencies found."

# 3. Setup Autostart
# We prefer Systemd User Service if available, as it provides better process management (restarts on failure).
# Fallback to XDG Autostart (.desktop) for other systems.

setup_systemd() {
    echo "Systemd detected. Installing as a user service..."
    SERVICE_DIR="$HOME/.config/systemd/user"
    mkdir -p "$SERVICE_DIR"
    
    SERVICE_FILE="$SERVICE_DIR/wifi-connector.service"
    
    cat > "$SERVICE_FILE" <<EOL
[Unit]
Description=WiFi Auto-Login Service
After=network.target network-online.target
Wants=network-online.target

[Service]
ExecStart=/bin/bash "$SCRIPT_PATH"
Environment="PATH=$PATH"
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal
WorkingDirectory=$INSTALL_DIR

[Install]
WantedBy=default.target
EOL

    # Reload systemd and enable service
    systemctl --user daemon-reload
    systemctl --user enable wifi-connector.service
    systemctl --user start wifi-connector.service
    
    echo -e "${GREEN}Systemd User Service installed and started!${NC}"
    echo "Check status with: systemctl --user status wifi-connector.service"
}

setup_xdg() {
    echo "Installing as XDG Autostart (Desktop Entry)..."
    AUTOSTART_DIR="$HOME/.config/autostart"
    DESKTOP_FILE="wifi-auto-login.desktop"
    TARGET_DESKTOP_PATH="$AUTOSTART_DIR/$DESKTOP_FILE"

    mkdir -p "$AUTOSTART_DIR"

    cat > "$TARGET_DESKTOP_PATH" <<EOL
[Desktop Entry]
Type=Application
Exec=/bin/bash -l -c "\"$SCRIPT_PATH\" >> \"$HOME/wifi-login.log\" 2>&1"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Campus WiFi Auto-Login
Comment=Automatically logins to Campus WiFi or exits if on Home WiFi
EOL

    chmod +x "$TARGET_DESKTOP_PATH"
    echo -e "${GREEN}XDG Autostart entry created!${NC}"
}

if command -v systemctl &> /dev/null; then
    # Check if we can talk to the user bus
    if systemctl --user list-units &> /dev/null; then
        setup_systemd
    else
        echo "Systemd found but user bus not accessible. Falling back to XDG Autostart."
        setup_xdg
    fi
else
    setup_xdg
fi
