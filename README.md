This updated script works on its own because it abandons the legacy fbcp compilation process and instead relies purely on the native tools and kernel modules already present in Debian Trixie (13) + Raspberry Pi OS.

* `Standard Linux Utilities: The script exclusively uses built-in shell commands (sed, grep, cat, cp) to safely parse, backup, and modify system configuration files.`

* `Native Kernel Overlays: Instead of downloading external drivers, it calls the piscreen device tree overlay. This overlay is pre-packaged within the standard Raspberry Pi OS kernel and handles both the SPI display output and the XPT2046 touch input natively.`

* `Wayland/KMS Integration: By utilizing the modern KMS graphics stack, it completely bypasses the need for X11-specific packages like xserver-xorg-input-evdev and xinput-calibrator, relying entirely on the built-in evdev kernel module to handle touch events out of the box.`

* `The only environmental prerequisites for the script to function are that it must be run with root privileges (sudo) and executed on a modern Raspberry Pi OS architecture (like Bookworm) where the boot configuration file is located at /boot/firmware/config.txt.`
