#!/bin/bash
# HP Host-Based Firmware Loader for Linux
# https://github.com/Lycore1/hp-hostbased-firmware-linux

FIRMWARE_DIR="/usr/share/hplip/data/firmware"
DEVICE="/dev/usb/lp0"

# Auto-detect firmware file
FIRMWARE=$(ls "$FIRMWARE_DIR"/*.fw 2>/dev/null | head -n 1)

if [ -z "$FIRMWARE" ]; then
    FIRMWARE=$(ls "$FIRMWARE_DIR"/*.fw.gz 2>/dev/null | head -n 1)
    if [ -n "$FIRMWARE" ]; then
        USE_GZ=1
    fi
fi

# Wait up to 30 seconds for the device to appear
for i in $(seq 1 15); do
    if [ -c "$DEVICE" ]; then
        break
    fi
    sleep 2
done

if [ ! -c "$DEVICE" ]; then
    echo "Device not found: $DEVICE" >&2
    exit 1
fi

if [ -z "$FIRMWARE" ]; then
    echo "No firmware file found in $FIRMWARE_DIR" >&2
    exit 1
fi

if [ "$USE_GZ" = "1" ]; then
    zcat "$FIRMWARE" > "$DEVICE"
else
    cat "$FIRMWARE" > "$DEVICE"
fi

exit 0
