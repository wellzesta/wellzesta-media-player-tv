# wellzesta-media-player-tv

This repository contains scripts and configurations required to set up and manage the **Wellzesta Media Player** for TV devices.

## Directory Structure

### `wmp-setup/`
The `wmp-setup` folder contains essential assets and additional scripts used during the setup process of the Wellzesta Media Player. This includes:

- Images used for branding purposes.
- Auxiliary configuration files for the media player.
- Any other resources necessary for the system setup.

### `wmp-setup.sh`
The `wmp-setup.sh` script automates the installation and configuration of the **Wellzesta Media Player**. It performs the following tasks:

1. Updates the package manager (`apt`) and installs necessary dependencies, including `firefox-esr`.
2. Sets the keyboard layout to **US** if it’s not already configured.
3. Creates directories required by the media player to store assets.
4. Downloads necessary branding assets (such as images) from a specified GitHub repository.
5. Sets up a **systemd service** to automatically start Firefox in **kiosk mode** on a specific URL during system boot.
6. Ensures the media player is ready to run after the script finishes.