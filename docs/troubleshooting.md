```markdown
# Troubleshooting

## Printer appears idle but nothing prints

Check if the USB device node exists:

```bash
ls -l /dev/usb/lp0
```

If the file does not exist, try:

1. Unplug and replug the USB cable.
2. Power cycle the printer.
3. Check `dmesg | grep usb` for kernel messages.

## Permission denied when writing to /dev/usb/lp0

Check group ownership:

```bash
ls -l /dev/usb/lp0
```

If group is `root` instead of `lp`, add your user to the `lp` group:

```bash
sudo usermod -aG lp $USER
```

Log out and log back in for the change to take effect.

Alternatively, create a udev rule to set group ownership:

```bash
sudo nano /etc/udev/rules.d/50-hp-printer.rules
```

Add:

```
SUBSYSTEM=="usb", ATTRS{idVendor}=="03f0", ATTRS{idProduct}=="002a", GROUP="lp", MODE="0660"
```

Reload:

```bash
sudo udevadm control --reload-rules
```

## Firmware file not found

List available firmware files:

```bash
ls /usr/share/hplip/data/firmware/
```

If your model is not listed, install HPLIP proprietary plugin:

```bash
sudo hp-plugin -i
```

Choose option `d` to download from HP.

## Script runs but printer still does not print

Check crontab logs:

```bash
journalctl -b | grep -i cron | tail -20
```

Check CUPS error log:

```bash
sudo tail -50 /var/log/cups/error_log
```

Check printer queue:

```bash
lpstat -o
```

Cancel stuck jobs:

```bash
cancel -a PRINTER_NAME
```

## Printer prints after running lp from terminal but not from GUI

Verify:

1. Crontab entry exists:

```bash
crontab -l
```

2. Script is executable:

```bash
ls -l /usr/local/bin/hp-hostbased-firmware.sh
```

3. Script runs without errors:

```bash
sudo /usr/local/bin/hp-hostbased-firmware.sh
echo $?
```

Exit code `0` means success.

## After suspend/resume, printer stops working

Create a systemd service to re-upload firmware after resume:

```bash
sudo nano /etc/systemd/system/hp-hostbased-firmware-resume.service
```

Add:

```ini
[Unit]
Description=Reload HP firmware after resume
After=suspend.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/hp-hostbased-firmware.sh

[Install]
WantedBy=suspend.target
```

Enable:

```bash
sudo systemctl daemon-reload
sudo systemctl enable hp-hostbased-firmware-resume.service
```
```
