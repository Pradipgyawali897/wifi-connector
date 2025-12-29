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

# 3. Create Desktop Entry for Autostart
AUTOSTART_DIR="$HOME/.config/autostart"
DESKTOP_FILE="wifi-auto-login.desktop"
TARGET_DESKTOP_PATH="$AUTOSTART_DIR/$DESKTOP_FILE"

mkdir -p "$AUTOSTART_DIR"

echo "Creating autostart entry at $TARGET_DESKTOP_PATH..."

cat > "$TARGET_DESKTOP_PATH" <<EOL
[Desktop Entry]
Type=Application
Exec=bash "$SCRIPT_PATH"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Campus WiFi Auto-Login
Comment=Automatically logins to Campus WiFi or exits if on Home WiFi
EOL

chmod +x "$TARGET_DESKTOP_PATH"

echo -e "${GREEN}Installation Complete!${NC}"
echo "The script will now run automatically on login."
echo "To test it now, you can run: $SCRIPT_PATH"
