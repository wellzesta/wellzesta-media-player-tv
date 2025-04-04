#!/bin/bash

# Add after shebang
declare LOG_PATH="/usr/share/wellzesta/updates/logs"
declare SERVICE_NAME="w-tv-startup.service"
declare CURRENT_USER
declare FIREFOX_CMD

# Function to handle logging
log_message() {

    # Create directory if it doesn't exist
    if ! sudo mkdir -p "$LOG_PATH"; then
        echo "Failed to create log directory: $LOG_PATH"
        exit 1
    fi

    # Get current timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Append message with timestamp to log file
    echo "[$timestamp] $1" | sudo tee -a "$LOG_PATH/deploy-startup-script-fix.log"
}

log_message ""
log_message "---------------------------------------------------------------------------------------------"
log_message "Starting deployment of Wellzesta TV startup script fix"
log_message "---------------------------------------------------------------------------------------------"

# Check if the script is being run as root
if [ "$EUID" -ne 0 ]; then
  log_message "This script must be run as root. Please try again using sudo."
  exec sudo bash "$0" "$@"
  exit
fi

# Explicit check for SUDO_USER
if [ -z "$SUDO_USER" ]; then
    CURRENT_USER="wellzesta"
    log_message "SUDO_USER is empty, using default user: $CURRENT_USER"
else
    CURRENT_USER="$SUDO_USER"
    log_message "Using SUDO_USER: $CURRENT_USER"
fi

log_message "Debug information:"
log_message "SUDO_USER=$SUDO_USER"
log_message "USER=$USER"
log_message "EUID=$EUID"
log_message "CURRENT_USER=$CURRENT_USER"

log_message "OS Name and Version"
os_info=$(cat /etc/os-release)
log_message "System Information: \n$os_info"

log_message ""
log_message "Checking for installed Firefox version..."

# Check if firefox-esr is installed
if command -v firefox-esr &>/dev/null; then
  FIREFOX_CMD="/usr/bin/firefox-esr"
  log_message "Firefox ESR found."
elif command -v firefox &>/dev/null; then
  FIREFOX_CMD="/usr/bin/firefox"
  log_message "Standard Firefox found."
else
  log_message "Neither Firefox ESR nor standard Firefox is installed. Please install one of them and rerun the script."
  exit 1
fi


log_message ""
log_message "Creating systemd service for Wellzesta TV startup using $FIREFOX_CMD..."

sudo bash -c "cat > /etc/systemd/system/$SERVICE_NAME" <<EOF
[Unit]
Description=Start Firefox-ESR on boot Running Wellzesta TV
After=graphical.target network.target

[Service]
ExecStart=$FIREFOX_CMD --kiosk --new-window "https://tv.wellzesta.com"
Type=simple
User=$CURRENT_USER
Environment=DISPLAY=:0
Environment=XAUTHORITY=/home/$CURRENT_USER/.Xauthority
RemainAfterExit=no

[Install]
WantedBy=graphical.target
EOF

# Verify service file creation
if [ -f "/etc/systemd/system/$SERVICE_NAME" ]; then
    log_message "Service file created successfully"
else
    log_message "Failed to create service file"
    exit 1
fi

# Reload systemd daemon
log_message "Reloading systemd daemon"
if ! sudo systemctl daemon-reload; then
    log_message "Failed to reload systemd daemon"
    exit 1
fi

# Enable and start the service
log_message "Enabling service: $SERVICE_NAME"
if sudo systemctl enable $SERVICE_NAME; then
    log_message "Service enabled successfully"
    if systemctl is-enabled "$SERVICE_NAME" &>/dev/null; then
        log_message "Service is enabled and will start on boot"
    else
        log_message "Warning: Service may not be properly enabled"
    fi
else
    log_message "Failed to enable service"
    exit 1
fi

log_message ""
log_message ""
log_message "Wellzesta TV startup service created with success!"
log_message "You're all set! Now your Wellzesta TV will automatically start on reboot"
log_message "If you ever need to close Firefox, just press Alt + F4."
log_message "Have a great day! :D"