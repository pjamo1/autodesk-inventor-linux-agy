# Autodesk Inventor on Linux (via Wine & DXVK)

Automated scripts, patches, and instructions to install, activate, and run **Autodesk Inventor** (2024–2027) on Linux with hardware acceleration and full functionality.

---

## Features & Workarounds Included

- **Automated ADIX Package Extraction**: Bypasses Autodesk ODIS installer failure under Wine (`0x80070005: Access Denied`).
- **Autodesk Licensing Daemon Integration**: Automatically starts `AdskLicensingService.exe` in the background to handle single sign-on and educational/commercial license verification.
- **Hardware-Accelerated 3D Viewport**: Direct3D 11 to Vulkan translation via **DXVK**, tuned for smooth sketch/part modeling on Intel, AMD, and NVIDIA GPUs.
- **Native HLSL Shader Compiler**: Includes overrides for native Microsoft `d3dcompiler_47.dll` to prevent shader reflection stubs.
- **WPF Ribbon Startup Crash Fix**: Automatically patches Wine font registry entries to avoid `System.UriFormatException`.
- **Title Bar Caption Buttons Fix**: Automatically installs and registers Segoe MDL2 Assets and Marlett fonts for Minimize, Maximize, and Close buttons.
- **WebView2 Home Dashboard Support**: Passes sandbox compatibility flags for embedded Chromium.

---

## Requirements

- **Linux Distribution**: Ubuntu 22.04+, Fedora 38+, Arch Linux, Debian 12+, openSUSE, etc.
- **Wine**: Wine 9.x / 10.x / 11.x (Wine-Staging recommended).
- **Vulkan Driver**: Vulkan-capable graphics driver (`mesa-vulkan-drivers` / `vulkan-radeon` / `nvidia-driver`).
- **Tools**: `winetricks`, `python3`, `curl`, `tar`.

---

## Quick Start (Automated Installation)

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/Autodesk-Inventor-on-Linux.git
cd Autodesk-Inventor-on-Linux
chmod +x *.sh scripts/*.sh
```

### 2. Run the Installer
```bash
./install.sh
```

The script will:
1. Initialize a clean 64-bit Wine prefix at `~/.autodesk_inventor/wineprefix`.
2. Install required Windows runtimes (`vcrun2022`, `dxvk`, `msxml6`, `.NET Desktop Runtime`).
3. Download and register UI symbol fonts (`segmdl2.ttf`, `marlett.ttf`, `segoeui.ttf`).
4. Apply font registry patches to prevent WPF ribbon crashes.
5. Prompt you to either:
   - Provide the path to your extracted Autodesk installer folder (to unpack `.adix` archives).
   - Or copy binaries from an existing Windows installation.
6. Install the desktop launcher shortcut and `launch_inventor.sh`.

---

## Launching Autodesk Inventor

Launch from your desktop application menu or via terminal:
```bash
./launch_inventor.sh
```

---

## Documentation

- [Detailed Installation Guide](docs/INSTALLATION.md)
- [Graphics & DXVK Performance Tuning](docs/GRAPHICS_TUNING.md)
- [Autodesk Licensing Service Setup](docs/LICENSING.md)
- [Troubleshooting & FAQ](docs/TROUBLESHOOTING.md)

---

## Contributing

Pull requests, tested graphics tweaks, and compatibility reports across different Linux distributions and Wine versions are welcome!

## License

This project is licensed under the [MIT License](LICENSE). Autodesk and Autodesk Inventor are registered trademarks of Autodesk, Inc.
