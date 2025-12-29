# WiFi Auto-Login Service

A lightweight, automated Bash script to log in to captive portals (specifically Cyberoam/Sophos style gateways) on Linux systems. It runs silently in the background at startup, handling network detection, credential rotation, and connection verification.

## Features

*   **Network Detection**: Automatically detects if you are on the specific Campus WiFi (10.100.x.x) or an external network (Home WiFi).
*   **Auto-Login**: Rotates through a list of credentials until a successful login is achieved.
*   **Reconnection Logic**: Retries logins if the connection drops.
*   **Smart Exit**: Does not interfere if you are already connected to another internet source.
*   **Startup Integration**: integrating with your desktop environment's autostart mechanism.

## Prerequisites

The script requires standard Linux utilities:
*   `bash`
*   `curl`
*   `jq` (for JSON processing)
*   `ping` (from `iputils-ping` or similar)

## Installation

1.  **Clone the repository**.
    ```bash
    git clone https://github.com/Pradipgyawali897/wifi-connector.git
    cd wifi-connector
    ```

2.  **Configure** your settings.
    Copy the example config and edit it with your credentials:
    ```bash
    cp config.env.example config.env
    nano config.env
    ```

3.  **Run the Installer**.
    This script automatically detects your system type (Systemd vs Standard XDG) and installs the service accordingly for maximum compatibility.
    ```bash
    bash install.sh
    ```
    *   **Systemd Systems** (Ubuntu, Mint, Arch, Fedora, etc.): Installs a user-level background service (`wifi-connector.service`).
    *   **Others**: Adds a startup entry to your Desktop Environment.

## Configuration

The `config.env` file holds your secrets.
*   **GATEWAY_IP**: The IP used to detect the captive portal network.
*   **BASE_URL**: The login endpoint.
*   **CREDENTIALS**: Array of `username:password` strings.

## Usage

*   **Automatic**: The script runs in the background on login/boot.
*   **Manual**: Run `./wifi_login.sh` in a terminal.
*   **Logs (Systemd)**: If installed via systemd, view logs with:
    ```bash
    journalctl --user -u wifi-connector -f
    ```

## Customization

Modify `wifi_login.sh` to change specific logic about how the login request is formatted if your captive portal differs from the standard form.
