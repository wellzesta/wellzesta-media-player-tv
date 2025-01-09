#!/bin/bash
echo "Preparing Wellzesta Media Player"

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

echo ""

echo "Checking current keyboard layout..."
current_layout=$(setxkbmap -query | grep layout | awk '{print $2}')
if [ "$current_layout" != "us" ]; then
  echo "Current layout is $current_layout. Setting keyboard layout to US..."
  setxkbmap us
else
  echo "Keyboard layout is already set to US."
fi


# make script stops in case of error.
set -e

echo ""
echo "Updating apt repositories..."
apt-get update -y

echo ""
echo "Installing packages"
apt-get install -y firefox-esr


echo ""
echo "Installing Wellzesta theme"
cd /usr/share
mkdir wellzesta && cd $_
wget -q --show-progress $GIT_RAW_REPOSITORY/$GIT_ASSETS_PATH/wellzesta_wallpaper.jpg -O ./wellzesta_wallpaper.jpg
wget -q --show-progress $GIT_RAW_REPOSITORY/$GIT_ASSETS_PATH/wellzesta_vis_icon.png -O ./wellzesta_vis_icon.png
wget -q --show-progress $GIT_RAW_REPOSITORY/$GIT_ASSETS_PATH/wellzesta_active_icon.png -O ./wellzesta_active_icon.png
wget -q --show-progress $GIT_RAW_REPOSITORY/$GIT_ASSETS_PATH/Wellzesta%20TV -O '~/Desktop/Wellzesta TV'
wget -q --show-progress $GIT_RAW_REPOSITORY/$GIT_ASSETS_PATH/Wellzesta%20Active -O '~/Desktop/Wellzesta Active'

export DISPLAY=:0.0
pcmanfm --set-wallpaper ./wellzesta_wallpaper.jpg

echo ""
echo "Creating systemd service for Wellzesat TV startup using Firefox..."

cat <<EOF | sudo tee /etc/systemd/system/wellzesta-tv-startup.service
[Unit]
Description=Start Firefox-ESR on boot Running Wellzesta TV
After=network.target

[Service]
ExecStart=/usr/bin/firefox-esr --kiosk --new-window "http://tv.wellzesta.com"
Restart=always
User=$USER
Environment=DISPLAY=:0

[Install]
WantedBy=graphical.target
EOF

# Enable and start the service
sudo systemctl enable firefox-startup.service
sudo systemctl start firefox-startup.service

echo ""
echo "Firefox startup service created and started."
