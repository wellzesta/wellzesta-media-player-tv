#!/bin/bash

GIT_RAW_REPOSITORY="https://raw.githubusercontent.com/wellzesta/wellzesta-media-player-tv"
GIT_ASSETS_PATH="main/wmp-setup/assets/"

# Check if the script is being run as root
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root. Please try again using sudo."
  exec sudo bash "$0" "$@"
  exit
fi

echo "OS Name and Version"
cat /etc/os-release

echo "User: $SUDO_USER"

echo ""
echo "Checking for installed Firefox version..."

# Check if firefox-esr is installed
if command -v firefox-esr &>/dev/null; then
  FIREFOX_CMD="/usr/bin/firefox-esr"
  echo "Firefox ESR found."
elif command -v firefox &>/dev/null; then
  FIREFOX_CMD="/usr/bin/firefox"
  echo "Standard Firefox found."
else
  echo "Neither Firefox ESR nor standard Firefox is installed. Please install one of them and rerun the script."
  exit 1
fi


echo ""
echo "Creating systemd service for Wellzesta TV startup using $FIREFOX_CMD..."

SERVICE_NAME=w-tv-startup.service

cat <<EOF | sudo tee /etc/systemd/system/$SERVICE_NAME
[Unit]
Description=Start Firefox-ESR on boot Running Wellzesta TV
After=graphical.target network.target

[Service]
ExecStart=$FIREFOX_CMD --kiosk --new-window "https://tv.wellzesta.com"
Type=oneshot
User=$SUDO_USER
Environment=DISPLAY=:0
RemainAfterExit=no

[Install]
WantedBy=graphical.target
EOF

# Enable and start the service
sudo systemctl enable $SERVICE_NAME

sudo systemctl status w-tv-startup.service

echo ""
echo "Wellzesta TV startup service created with success!"
echo "You're all set! Sit back, relax, and let your Raspberry Pi do the magic. 😉 If you need to close Firefox, just hit Alt + F4!"
echo "Happy streaming! 🚀"