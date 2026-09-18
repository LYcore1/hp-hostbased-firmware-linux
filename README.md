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

On Windows, HP's background service handles this automatically. On Linux, CUPS/HPLIP does not upload firmware unless a print job is sent from the terminal (
