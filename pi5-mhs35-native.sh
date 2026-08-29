#!/bin/bash
# pi5-mhs35-native.sh
# Native Wayland/KMS configuration for SPI displays on Raspberry PI 5. No fbcp, no legacy X11 drivers, uses built-in kernel overlays

if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root. Use sudo ./pi5-mhs35-native.sh"
    exit 1
fi

# On Raspberry Pi 5 (Bookworm OS), config.txt has moved to /boot/firmware/
CONFIG_FILE="/boot/firmware/config.txt"
BACKUP_FILE="/boot/firmware/config.txt.backup-$(date +%F-%T)"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: $CONFIG_FILE not found. Are you on Raspberry Pi OS Bookworm?"
    exit 1
fi

echo "Creating backup of config.txt at $BACKUP_FILE"
cp "$CONFIG_FILE" "$BACKUP_FILE"

echo "Enabling SPI interface..."
# Uncomment dtparam=spi=on if it's commented out
sed -i 's/^#dtparam=spi=on/dtparam=spi=on/' "$CONFIG_FILE"

# Add it if it doesn't exist
if ! grep -q "^dtparam=spi=on" "$CONFIG_FILE"; then
    echo "dtparam=spi=on" >> "$CONFIG_FILE"
fi

echo "Cleaning up any old conflicting overlays..."
sed -i '/^dtoverlay=piscreen/d' "$CONFIG_FILE"
sed -i '/^dtoverlay=tft35a/d' "$CONFIG_FILE"
sed -i '/^dtoverlay=mhs35/d' "$CONFIG_FILE"
sed -i '/^dtoverlay=ads7846/d' "$CONFIG_FILE"

echo "Applying native KMS device tree overlays..."
cat <<EOT >> "$CONFIG_FILE"

# --- MHS35 Native SPI Configuration ---
# Display overlay
dtoverlay=piscreen,speed=24000000,rotate=90
# Touchscreen calibration parameters (ads7846 built into piscreen)
# If touch axes are inverted, adjust swapxy or invertx/inverty here
dtparam=swapxy=1
dtparam=xmin=200
dtparam=xmax=3900
dtparam=ymin=200
dtparam=ymax=3900
# --------------------------------------
EOT

echo "Configuration applied successfully."
echo "Because the Pi 5 uses Wayland (Wayfire/labwc) instead of X11, old tools like xinput-calibrator will not work."
echo "Touch should work out of the box via the evdev kernel module."
echo ""
echo "Rebooting system in 5 seconds to apply changes..."
sleep 5
reboot
