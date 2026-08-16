#!/usr/bin/env python3
"""
Autodesk ADIX Package Extractor for Linux / Wine
Extracts all .adix (MSIX/VFS zip archives) from Autodesk installation media into target Wine directories.
"""

import os
import sys
import zipfile
import urllib.parse
import argparse

VFS_MAPPINGS = {
    "VFS/ProgramFilesX64": "Program Files",
    "VFS/ProgramFilesCommonX64": "Program Files/Common Files",
    "VFS/Common AppData": "ProgramData",
    "VFS/Common Documents": "users/Public/Documents",
    "VFS/Fonts": "windows/Fonts",
    "VFS/SystemX64": "windows/system32",
}

def extract_packages(installer_dir, prefix_root):
    drive_c = os.path.join(prefix_root, "drive_c")
    if not os.path.exists(drive_c):
        print(f"Error: Target drive_c directory not found at: {drive_c}")
        sys.exit(1)

    adix_files = []
    for root, _, files in os.walk(installer_dir):
        for f in files:
            if f.lower().endswith(".adix"):
                adix_files.append(os.path.join(root, f))

    if not adix_files:
        print(f"No .adix packages found in: {installer_dir}")
        sys.exit(1)

    print(f"Found {len(adix_files)} ADIX packages to extract.\n")
    total_extracted = 0

    for pkg_path in sorted(adix_files):
        pkg_name = os.path.basename(pkg_path)
        print(f"[*] Extracting package: {pkg_name}")
        try:
            with zipfile.ZipFile(pkg_path, 'r') as zf:
                for member in zf.infolist():
                    decoded_path = urllib.parse.unquote(member.filename)
                    for vfs_key, rel_target in VFS_MAPPINGS.items():
                        if decoded_path.startswith(vfs_key + "/"):
                            sub_path = decoded_path[len(vfs_key) + 1:]
                            dest = os.path.join(drive_c, rel_target, sub_path)
                            if member.is_dir():
                                os.makedirs(dest, exist_ok=True)
                            else:
                                os.makedirs(os.path.dirname(dest), exist_ok=True)
                                with zf.open(member) as src, open(dest, "wb") as dst:
                                    dst.write(src.read())
                                total_extracted += 1
        except Exception as e:
            print(f"    [!] Error extracting {pkg_name}: {e}")

    print(f"\n[+] Successfully extracted {total_extracted} files into {drive_c}")

def main():
    parser = argparse.ArgumentParser(description="Extract Autodesk ADIX installer packages into a Wine prefix.")
    parser.add_argument("installer_dir", help="Path to Autodesk installer directory containing .adix packages")
    parser.add_argument("--prefix", default=os.path.expanduser("~/.autodesk_inventor/wineprefix"),
                        help="Path to target WINEPREFIX (default: ~/.autodesk_inventor/wineprefix)")
    args = parser.parse_args()

    extract_packages(args.installer_dir, args.prefix)

if __name__ == "__main__":
    main()
