# Creality K2 - Helper Script

A menu-driven helper script for the **Creality K2** (with or without CFS) on stock firmware, with patches for the **Phaetus DXC-2** extruder.

Fork of [sw3defy/Creality-Helper-Script-K2-Plus](https://github.com/sw3defy/Creality-Helper-Script-K2-Plus), itself adapted from the [Guilouz Creality Helper Script](https://github.com/Guilouz/Creality-Helper-Script). The [upstream wiki](https://sw3defy.github.io/Creality-Helper-Script-Wiki-K2-Plus/) is written for the K2 Plus but most of it applies.

## Installation

Connect to your K2 via SSH (`root`), then run:

```sh
python3 -c "import urllib.request; urllib.request.urlretrieve('https://github.com/Promotheux/Creality-Helper-Script-K2/archive/refs/heads/main.zip', '/tmp/helper.zip')"
python3 -c "import shutil; shutil.unpack_archive('/tmp/helper.zip', '/tmp/')"
mkdir -p /mnt/UDISK/helper-script
cp -r /tmp/Creality-Helper-Script-K2-main/* /mnt/UDISK/helper-script/
chmod +x /mnt/UDISK/helper-script/helper.sh
sh /mnt/UDISK/helper-script/helper.sh
```

## Features

| Option | Feature |
|--------|---------|
| 1 | Moonraker Extensions & Update Manager |
| 2 | Fans Control Macros |
| 3 | Useful Macros (START_PRINT / END_PRINT) |
| 4 | Save Z-Offset Macros |
| 5 | M600 Filament Change Support |
| 6 | DXC-2 patches (longer retract after cut; reapplied at boot after Creality updates) |
| 7 | CFS Box Guard (skips CFS commands with empty ADDR/NUM that crash Klipper with key171/key60) |
| 8 | KAMP: points to [KAMP-K2](https://github.com/grant0013/KAMP-K2) (upstream KAMP does not work on K2 stock firmware) |
| 9 | Improved Shapers Calibrations |
| 10 | Fluidd (install/update/repair - port 4408) |
| 11 | Mainsail (install/update/repair - port 4409) |
| 12 | CFS Panel for Mainsail (written for the K2 Plus, test on your K2) |
| 13 | Moonraker Timelapse |
| 14 | Camera Support for Fluidd and Mainsail (WebRTC via go2rtc) |
| 15 | HelixScreen (modern touchscreen UI) |
| 16 | OctoEverywhere |
| 17 | Mobileraker Companion |
| 18 | Entware Package Manager |
| 19 | Git Backup |

## Requirements

- Creality K2 or K2 Combo on stock firmware
- Root SSH access enabled
- SSH client (e.g. PuTTY on Windows)

## Discussions & Support

[Join the discussion](https://github.com/sw3defy/Creality-Helper-Script-Wiki-K2-Plus/discussions)

## Support the Project

<a href="https://buymeacoffee.com/sw3defy"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" height="40"></a>

<a href="https://ko-fi.com/sw3defy"><img src="https://ko-fi.com/img/githubbutton_sm.svg" height="40"></a>

## Credits

- [Guilouz](https://github.com/Guilouz) - Original Creality Helper Script for K1 Series
- [DnG-Crafts](https://github.com/DnG-Crafts/K2-Camera) - K2 camera WebRTC discovery
- [vsevolod-volkov](https://github.com/vsevolod-volkov/K2Plus-entware) - Entware on K2 Plus (wget shim solution)
- [AlexxIT/go2rtc](https://github.com/AlexxIT/go2rtc) - Stream conversion software
- [prestonbrown/HelixScreen](https://github.com/prestonbrown/helixscreen) - Modern touchscreen UI for Klipper
- [Klipper](https://www.klipper3d.org) - 3D printer firmware
- [Moonraker](https://moonraker.readthedocs.io) - API server
- [Fluidd](https://docs.fluidd.xyz) - Web interface
- [Mainsail](https://docs.mainsail.xyz) - Web interface
- [KAMP](https://github.com/kyleisah/Klipper-Adaptive-Meshing-Purging) / [KAMP-K2](https://github.com/grant0013/KAMP-K2) - Adaptive meshing
- [opoeta/k2-improvements](https://github.com/opoeta/k2-improvements) - CFS box guard
- [swilsonnc/K2-plus-cfs-panel](https://github.com/swilsonnc/K2-plus-cfs-panel) - CFS panel for Mainsail
- [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) - Wiki theme
