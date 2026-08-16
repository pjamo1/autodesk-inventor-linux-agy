#!/bin/bash
set -e

PREFIX="${1:-$HOME/.autodesk_inventor/wineprefix}"
export WINEPREFIX="$PREFIX"
export WINEARCH=win64

echo "=========================================="
echo " Setting up Wine Prefix: $WINEPREFIX"
echo "=========================================="

mkdir -p "$WINEPREFIX"
wineboot -u

echo "[*] Installing Windows runtimes via winetricks..."
winetricks -q vcrun2022 dxvk msxml6

echo "[*] Installing Microsoft .NET Desktop Runtime (x64)..."
DOTNET_INSTALLER="/tmp/windowsdesktop-runtime-win-x64.exe"
if [ ! -f "$DOTNET_INSTALLER" ]; then
    curl -L -o "$DOTNET_INSTALLER" "https://aka.ms/dotnet/8.0/windowsdesktop-runtime-win-x64.exe"
fi
wine "$DOTNET_INSTALLER" /install /quiet /norestart || true

echo "[*] Configuring Wine X11 Driver window settings..."
wine reg add "HKCU\\Software\\Wine\\X11 Driver" /v "Decorated" /t REG_SZ /d "Y" /f
wine reg add "HKCU\\Software\\Wine\\X11 Driver" /v "Managed" /t REG_SZ /d "Y" /f

echo "[*] Configuring Edge WebView2 keys..."
wine reg add "HKLM\\Software\\WOW6432Node\\Microsoft\\EdgeUpdate\\Clients\\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" /v "name" /t REG_SZ /d "Microsoft Edge WebView2 Runtime" /f
wine reg add "HKLM\\Software\\Microsoft\\EdgeUpdate\\Clients\\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" /v "name" /t REG_SZ /d "Microsoft Edge WebView2 Runtime" /f

echo "[+] Prefix initialization complete."
