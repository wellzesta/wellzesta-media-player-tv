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

echo "User: $SUDO_USER"

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
apt-get install -y feh


echo ""
echo "Installing Wellzesta theme"
cd /usr/share
mkdir -p wellzesta
cd wellzesta
wget -q --show-progress $GIT_RAW_REPOSITORY/$GIT_ASSETS_PATH/wellzesta_wallpaper.jpg -O ./wellzesta_wallpaper.jpg
wget -q --show-progress $GIT_RAW_REPOSITORY/$GIT_ASSETS_PATH/wellzesta_vis_icon.png -O ./wellzesta_vis_icon.png
wget -q --show-progress $GIT_RAW_REPOSITORY/$GIT_ASSETS_PATH/wellzesta_active_icon.png -O ./wellzesta_active_icon.png
wget -q --show-progress $GIT_RAW_REPOSITORY/$GIT_ASSETS_PATH/Wellzesta_Active -O ./Wellzesta_Active
wget -q --show-progress $GIT_RAW_REPOSITORY/$GIT_ASSETS_PATH/Wellzesta_TV.desktop -O ./Wellzesta_TV.desktop

sudo -u $SUDO_USER cp "Wellzesta_TV.desktop" "/home/$SUDO_USER/Desktop/Wellzesta TV.desktop"
sudo -u $SUDO_USER cp "Wellzesta_Active" "/home/$SUDO_USER/Desktop/Wellzesta Active"
# echo "Installing wallpaper"
# echo "Display: $DISPLAY"
# sudo -u $SUDO_USER \
#     DISPLAY=$DISPLAY \
#     XAUTHORITY=$XAUTHORITY \
#     DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
#     pcmanfm --set-wallpaper ./wellzesta_wallpaper.jpg

# Go to user home directory before continue.
cd ~

echo ""
echo "Creating systemd service for Wellzesta TV startup using Firefox..."

SERVICE_NAME=w-tv-startup.service

cat <<EOF | sudo tee /etc/systemd/system/$SERVICE_NAME
[Unit]
Description=Start Firefox-ESR on boot Running Wellzesta TV
After=graphical.target network.target

[Service]
ExecStart=/usr/bin/firefox-esr --kiosk --new-window "http://tv.wellzesta.com"
Type=oneshot
User=$SUDO_USER
Environment=DISPLAY=:0
RemainAfterExit=no

[Install]
WantedBy=graphical.target
EOF

# Enable and start the service
sudo systemctl enable $SERVICE_NAME

# read -p "Do you want to open Wellzesta TV now? You can also launch it later using the desktop shortcut (y/n): " answer

# if [[ "$answer" == [sS] ]]; then
#     sudo systemctl start $SERVICE_NAME
#     echo "Wellzesta TV initialized."
# else
#     echo "You can also launch it later using the desktop shortcut"
# fi

echo ""
echo "Finished Wellzesta TV setup."
