#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export WINEPREFIX="${WINEPREFIX:-$HOME/.autodesk_inventor/wineprefix}"
export WINEARCH=win64

echo "========================================================="
echo "   Autodesk Inventor on Linux - Installation Wizard"
echo "========================================================="
echo "Target Prefix: $WINEPREFIX"
echo ""

# Check dependencies
for CMD in wine winetricks python3 curl; do
    if ! command -v "$CMD" &> /dev/null; then
        echo "[!] Error: Required tool '$CMD' is not installed."
        exit 1
    fi
done

# Step 1: Prefix Setup
echo ">>> Step 1/4: Initializing Wine prefix and runtimes..."
bash "$SCRIPT_DIR/scripts/setup_prefix.sh" "$WINEPREFIX"

# Step 2: Fonts & WPF Fixes
echo ""
echo ">>> Step 2/4: Applying font fixes and UI symbol icons..."
python3 "$SCRIPT_DIR/scripts/fix_fonts.py" "$WINEPREFIX"

# Step 3: Payload extraction / Binary source
echo ""
echo ">>> Step 3/4: Autodesk Inventor Binaries"
echo "Please choose how you want to provide Autodesk Inventor:"
echo "  1) Extract from downloaded installer folder (containing .adix packages)"
echo "  2) Copy files from an existing Windows installation drive / folder"
echo "  3) Skip binary installation (already installed or will copy manually)"
read -p "Select option [1-3]: " CHOICE

case "$CHOICE" in
    1)
        read -p "Enter full path to extracted Autodesk installer directory: " INSTALLER_DIR
        if [ -d "$INSTALLER_DIR" ]; then
            python3 "$SCRIPT_DIR/extract_adix.py" "$INSTALLER_DIR" --prefix "$WINEPREFIX"
        else
            echo "[!] Directory not found. Please extract .adix files manually later."
        fi
        ;;
    2)
        read -p "Enter path to Windows drive / root directory (e.g. /mnt/windows): " WIN_DIR
        if [ -d "$WIN_DIR" ]; then
            echo "[*] Copying Program Files..."
            mkdir -p "$WINEPREFIX/drive_c/Program Files" "$WINEPREFIX/drive_c/ProgramData" "$WINEPREFIX/drive_c/Program Files (x86)/Common Files/Autodesk Shared"
            cp -ru "$WIN_DIR/Program Files/Autodesk" "$WINEPREFIX/drive_c/Program Files/" 2>/dev/null || true
            cp -ru "$WIN_DIR/Program Files/Common Files/Autodesk Shared" "$WINEPREFIX/drive_c/Program Files/Common Files/" 2>/dev/null || true
            cp -ru "$WIN_DIR/Program Files (x86)/Common Files/Autodesk Shared/AdskLicensing" "$WINEPREFIX/drive_c/Program Files (x86)/Common Files/Autodesk Shared/" 2>/dev/null || true
            cp -ru "$WIN_DIR/ProgramData/Autodesk" "$WINEPREFIX/drive_c/ProgramData/" 2>/dev/null || true
            echo "[+] Copy complete."
        else
            echo "[!] Directory not found."
        fi
        ;;
    3)
        echo "[*] Skipping binary copy."
        ;;
    *)
        echo "[*] Invalid choice, skipping binary installation."
        ;;
esac

# Step 4: Install native d3dcompiler_47 into system32 if found
echo ""
echo ">>> Step 4/4: Configuring Direct3D shader compiler..."
for YEAR in 2027 2026 2025 2024; do
    D3D_SRC="$WINEPREFIX/drive_c/Program Files/Autodesk/Inventor $YEAR/Bin/d3dcompiler_47.dll"
    if [ -f "$D3D_SRC" ]; then
        echo "[*] Installing native d3dcompiler_47.dll into Wine system32..."
        cp -u "$D3D_SRC" "$WINEPREFIX/drive_c/windows/system32/d3dcompiler_47.dll"
        break
    fi
done

# Install Desktop Shortcut
mkdir -p "$HOME/.local/share/applications"
sed "s|\$SCRIPT_DIR|$SCRIPT_DIR|g" "$SCRIPT_DIR/assets/autodesk-inventor.desktop" > "$HOME/.local/share/applications/autodesk-inventor.desktop"
chmod +x "$HOME/.local/share/applications/autodesk-inventor.desktop"

echo ""
echo "========================================================="
echo "   Installation and Configuration Complete!"
echo "========================================================="
echo "You can launch Inventor anytime using:"
echo "  $SCRIPT_DIR/launch_inventor.sh"
echo "or via your application launcher."
