```bash
# HP Host-Based Firmware Loader for Linux

A workaround for HP host-based printers that require firmware to be uploaded on every boot in Linux.

## Supported Printers

Host-based HP printers (also known as GDI printers) lack permanent firmware storage and rely on the host OS to upload firmware before printing.

Known models:

- HP LaserJet P1006
- HP LaserJet P1007
- HP LaserJet P1008
- HP LaserJet P1009
- HP LaserJet Professional P1102
- HP LaserJet Professional P1102w
- HP LaserJet P1505
- HP LaserJet Professional P1566
- HP LaserJet 1018
- HP LaserJet 1020

> Not for modern HP printers (M400, M500, Enterprise series, etc.). Those have permanent firmware and work out of the box with HPLIP.

## The Problem

These printers have no permanent memory for firmware. Every time they are powered on, the firmware must be uploaded from the host computer.

On Windows, HP's background service handles this automatically. On Linux, CUPS/HPLIP does not upload firmware unless a print job is sent from the terminal (`lp` or `echo`).

Result: The printer appears idle and enabled, but nothing prints from GUI applications.

## The Solution

Two small additions:

1. A script that sends firmware to `/dev/usb/lp0`.
2. A crontab entry that runs it 15 seconds after boot.

Optionally, a udev rule to re-send firmware when the printer is plugged in or powered on.

## Installation

### 1. Create the firmware script

```bash
sudo nano /usr/local/bin/hp-hostbased-firmware.sh
```

Paste the contents of `scripts/hp-hostbased-firmware.sh`.

Make it executable:

```bash
sudo chmod +x /usr/local/bin/hp-hostbased-firmware.sh
```

### 2. Add crontab entry

```bash
crontab -e
```

Add this line:

```bash
@reboot sleep 15 && /usr/local/bin/hp-hostbased-firmware.sh
```

### 3. Optional: Add udev rule

Find your printer's Vendor/Product ID:

```bash
lsusb
```

Example output:

```
Bus 001 Device 032: ID 03f0:002a HP, Inc LaserJet P1102
```

Create the rule:

```bash
sudo nano /etc/udev/rules.d/51-printer.rules
```

Add (replace `03f0` and `002a` with your IDs):

```
SUBSYSTEM=="usb", ATTRS{idVendor}=="03f0", ATTRS{idProduct}=="002a", RUN+="/usr/local/bin/hp-hostbased-firmware.sh"
```

Reload:

```bash
sudo udevadm control --reload-rules
```

## Testing

1. Reboot the laptop.
2. Wait 20 seconds.
3. Print from Chrome or any GUI app. No terminal command needed.

If it does not work, check logs:

```bash
journalctl -b | grep -i "hp-hostbased" | tail -20
```

## How It Works

The script uploads the firmware file from HPLIP's data directory to the printer's USB device node. This mimics what HP's Windows driver does automatically in the background.

No drivers, PPD files, or CUPS settings are modified.

## Configuration

The script auto-detects the firmware file from `/usr/share/hplip/data/firmware/`. If your model uses a different firmware filename, edit the script and change:

```bash
FIRMWARE="/usr/share/hplip/data/firmware/hp_laserjet_professional_p1102.fw"
```

To find available firmware files for your model:

```bash
ls /usr/share/hplip/data/firmware/ | grep -i YOUR_MODEL
```

## Disclaimer

- This is a community workaround, not an official HP solution.
- Firmware path may change with future HPLIP updates.
- Use at your own risk.

## License

MIT
EOF
```# HP Host-Based Firmware Loader for Linux

A workaround for HP host-based printers that require firmware to be uploaded on every boot in Linux.

## Supported Printers

Host-based HP printers (also known as GDI printers) lack permanent firmware storage and rely on the host OS to upload firmware before printing.

Known models:

- HP LaserJet P1006
- HP LaserJet P1007
- HP LaserJet P1008
- HP LaserJet P1009
- HP LaserJet Professional P1102
- HP LaserJet Professional P1102w
- HP LaserJet P1505
- HP LaserJet Professional P1566
- HP LaserJet 1018
- HP LaserJet 1020

> Not for modern HP printers (M400, M500, Enterprise series, etc.). Those have permanent firmware and work out of the box with HPLIP.

## The Problem

These printers have no permanent memory for firmware. Every time they are powered on, the firmware must be uploaded from the host computer.

On Windows, HP's background service handles this automatically. On Linux, CUPS/HPLIP does not upload firmware unless a print job is sent from the terminal (
