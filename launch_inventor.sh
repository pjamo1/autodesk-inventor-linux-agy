#!/bin/bash
set -e

# Default Prefix Path (can be overridden via environment)
export WINEPREFIX="${WINEPREFIX:-$HOME/.autodesk_inventor/wineprefix}"
export WINEARCH=win64

# Locate Wine and Wineloader
WINE_BIN="${WINE_BIN:-wine}"

if ! command -v "$WINE_BIN" &> /dev/null; then
    echo "Error: Wine binary '$WINE_BIN' not found in PATH."
    exit 1
fi

# DLL Overrides: DXVK + Native Shader Compiler + Builtin MSXML6
export WINEDLLOVERRIDES="mshtml=;msxml6=b,n;d3dcompiler_47,d3dcompiler_43=n,b;d3d11,dxgi,d3d10core,d3d9,d3d8=n,b"

# Hardware Acceleration & GPU Optimizations
export DXVK_HUD="${DXVK_HUD:-0}"
export DXVK_STATE_CACHE=1
export DXVK_LOG_LEVEL=none

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/dxvk.conf" ]; then
    export DXVK_CONFIG_FILE="$SCRIPT_DIR/dxvk.conf"
fi

# Driver & Multi-threading Optimizations
export MESA_VK_DEVICE_SELECT_FORCE_DEFAULT_DEVICE=1
export mesa_glthread=true
export __GL_THREADED_OPTIMIZATIONS=1

# Chromium / WebView2 flags for Home Screen / Dashboard
export WEBVIEW2_ADDITIONAL_BROWSER_ARGUMENTS="--no-sandbox --disable-gpu-sandbox --disable-features=RendererCodeIntegrity --disable-gpu-compositing --in-process-gpu --disable-features=AudioServiceOutOfProcess"

LIC_EXE="C:\\Program Files (x86)\\Common Files\\Autodesk Shared\\AdskLicensing\\Current\\AdskLicensingService\\AdskLicensingService.exe"

# Start Autodesk Desktop Licensing Service if not already active
if ! pgrep -f "AdskLicensingService.exe" > /dev/null 2>&1; then
    echo "[*] Starting Autodesk Desktop Licensing Service..."
    "$WINE_BIN" "$LIC_EXE" > /dev/null 2>&1 &
    sleep 2
fi

# Locate Inventor.exe (support 2024, 2025, 2026, 2027)
INVENTOR_EXE=""
for YEAR in 2027 2026 2025 2024; do
    C_PATH="$WINEPREFIX/drive_c/Program Files/Autodesk/Inventor $YEAR/Bin/Inventor.exe"
    if [ -f "$C_PATH" ]; then
        INVENTOR_EXE="C:\\Program Files\\Autodesk\\Inventor $YEAR\\Bin\\Inventor.exe"
        break
    fi
done

if [ -z "$INVENTOR_EXE" ]; then
    echo "Error: Could not locate Inventor.exe in '$WINEPREFIX/drive_c/Program Files/Autodesk/'"
    exit 1
fi

echo "[*] Launching Autodesk Inventor ($INVENTOR_EXE)..."
exec "$WINE_BIN" "$INVENTOR_EXE" "$@"
