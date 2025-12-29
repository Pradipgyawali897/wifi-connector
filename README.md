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

1.  **Clone or Download** this repository.
    ```bash
    git clone <repo_url>
    cd wifiConnector
    ```

2.  **Configure** your settings.
    Edit `config.env` to add your credentials and update the Gateway URL if necessary.
    ```bash
    nano config.env
    ```

3.  **Run the Installer**.
    This will set up permissions and add the script to your system's startup apps.
    ```bash
    bash install.sh
    ```

## Usage

Once installed, the script runs automatically when you log in.

To run it manually for testing:
```bash
./wifi_login.sh
```

## Structure

*   `wifi_login.sh`: The main logic script.
*   `config.env`: User configuration (ignored by git, template provided).
*   `install.sh`: Setup script for the local machine.

## Customization

Modify `wifi_login.sh` to change specific logic about how the login request is formatted if your captive portal differs from the standard form.
