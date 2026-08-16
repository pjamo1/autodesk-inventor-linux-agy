#!/usr/bin/env python3
"""
Wine Font Fixer & Symbol Font Installer for Autodesk Inventor
- Downloads Segoe MDL2 Assets, Segoe UI Symbol, and Marlett fonts.
- Registers them in the Wine registry for WPF window caption controls.
- Purges any \\??\\unix\\ font entries to prevent System.UriFormatException WPF crashes.
"""

import os
import sys
import urllib.request
import subprocess

FONTS_TO_DOWNLOAD = {
    "marlett.ttf": "https://github.com/iamdh4/marlett/raw/master/marlett.ttf",
    "segmdl2.ttf": "https://github.com/microsoft/PowerBI-CSharp/raw/master/submodules/UAPCommon/Resources/Fonts/segmdl2.ttf",
    "segoeui.ttf": "https://github.com/microsoft/PowerBI-CSharp/raw/master/submodules/UAPCommon/Resources/Fonts/segoeui.ttf",
    "segoeuib.ttf": "https://github.com/microsoft/PowerBI-CSharp/raw/master/submodules/UAPCommon/Resources/Fonts/segoeuib.ttf",
    "seguisym.ttf": "https://github.com/microsoft/PowerBI-CSharp/raw/master/submodules/UAPCommon/Resources/Fonts/seguisym.ttf",
}

def install_fonts(prefix_path):
    fonts_dir = os.path.join(prefix_path, "drive_c", "windows", "Fonts")
    os.makedirs(fonts_dir, exist_ok=True)

    print("[*] Downloading UI and symbol fonts...")
    for filename, url in FONTS_TO_DOWNLOAD.items():
        target = os.path.join(fonts_dir, filename)
        if not os.path.exists(target) or os.path.getsize(target) < 1024:
            try:
                print(f"    Downloading {filename}...")
                urllib.request.urlretrieve(url, target)
            except Exception as e:
                print(f"    [!] Failed to download {filename}: {e}")

    # Register fonts in Wine registry
    reg_content = """Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows NT\\CurrentVersion\\Fonts]
"Segoe UI (TrueType)"="segoeui.ttf"
"Segoe UI Bold (TrueType)"="segoeuib.ttf"
"Segoe UI Symbol (TrueType)"="seguisym.ttf"
"Segoe MDL2 Assets (TrueType)"="segmdl2.ttf"
"Marlett (TrueType)"="marlett.ttf"

[HKEY_CURRENT_USER\\Software\\Wine\\Fonts]
"External Fonts"=dword:00000000

[HKEY_LOCAL_MACHINE\\Software\\Wine\\Fonts]
"External Fonts"=dword:00000000
"""
    tmp_reg = "/tmp/inventor_fonts.reg"
    with open(tmp_reg, "w") as f:
        f.write(reg_content)

    env = os.environ.copy()
    env["WINEPREFIX"] = prefix_path
    subprocess.run(["wine", "regedit", tmp_reg], env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    # Purge \??\unix entries
    print("[*] Checking for and purging Linux host font paths from Wine registry...")
    try:
        out = subprocess.check_output(
            ["wine", "reg", "query", "HKLM\\Software\\Microsoft\\Windows NT\\CurrentVersion\\Fonts"],
            env=env, stderr=subprocess.DEVNULL
        ).decode("utf-8", errors="ignore")

        to_delete = []
        for line in out.splitlines():
            if "\\??\\unix\\" in line and "REG_SZ" in line:
                name = line.split("    REG_SZ    ")[0].strip()
                to_delete.append(name)

        if to_delete:
            print(f"    Purging {len(to_delete)} invalid unix font path entries...")
            with open("/tmp/del_unix_fonts.reg", "w") as f:
                f.write("Windows Registry Editor Version 5.00\n\n[HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows NT\\CurrentVersion\\Fonts]\n")
                for item in to_delete:
                    f.write(f"\"{item}\"=-\n")
            subprocess.run(["wine", "regedit", "/tmp/del_unix_fonts.reg"], env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except Exception as e:
        print(f"    [!] Error querying font registry: {e}")

    print("[+] Font configuration complete.")

if __name__ == "__main__":
    prefix = sys.argv[1] if len(sys.argv) > 1 else os.path.expanduser("~/.autodesk_inventor/wineprefix")
    install_fonts(prefix)
