# Step-by-Step Manual Installation Guide

This document explains the manual installation process for Autodesk Inventor on Linux without the interactive wizard.

---

## 1. Environment Preparation

Ensure you have Wine (Wine-Staging 9+ recommended), Winetricks, Vulkan libraries, and Python 3 installed.

```bash
export WINEPREFIX="$HOME/.autodesk_inventor/wineprefix"
export WINEARCH=win64
mkdir -p "$WINEPREFIX"
wineboot -u
```

## 2. Core Dependencies

```bash
winetricks -q vcrun2022 dxvk msxml6

# Install .NET Desktop Runtime (x64)
curl -L -o /tmp/windowsdesktop-runtime.exe "https://aka.ms/dotnet/8.0/windowsdesktop-runtime-win-x64.exe"
wine /tmp/windowsdesktop-runtime.exe /install /quiet /norestart
```

## 3. Extracting Installer Payload

> **Warning**: Do NOT run Autodesk's `Setup.exe`. ODIS fails under Wine with error `0x80070005: Access Denied` due to Windows AppX container limitations.

Run `extract_adix.py` against your downloaded Autodesk installer folder:

```bash
python3 extract_adix.py /path/to/extracted/installer/ --prefix "$WINEPREFIX"
```

## 4. UI Fonts & Registry Fixes

Run the font setup script to install caption glyphs and clean unix font paths:

```bash
python3 scripts/fix_fonts.py "$WINEPREFIX"
```

## 5. Native Direct3D Shader Compiler

Copy the native Microsoft `d3dcompiler_47.dll` from Inventor's `Bin` directory into Wine's `system32`:

```bash
cp "$WINEPREFIX/drive_c/Program Files/Autodesk/Inventor 2027/Bin/d3dcompiler_47.dll" "$WINEPREFIX/drive_c/windows/system32/"
```

## 6. Launching

Run `launch_inventor.sh` to start the background licensing daemon and launch the CAD application.
