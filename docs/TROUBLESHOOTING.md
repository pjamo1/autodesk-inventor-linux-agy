# Troubleshooting & Frequently Asked Questions

### 1. Inventor hangs on the splash screen / Loading screen
**Cause**: The licensing daemon `AdskLicensingService.exe` is not running.
**Fix**: Ensure you launch using `launch_inventor.sh` or start `AdskLicensingService.exe` in the background first.

---

### 2. Startup crash with `System.UriFormatException`
**Cause**: WPF's `PhysicalFontFamily` encounters Wine's NT device Unix font paths (`\??\unix\usr\share\fonts\...`) in the registry.
**Fix**: Run `python3 scripts/fix_fonts.py "$WINEPREFIX"` to remove unix font entries and disable external font scanning.

---

### 3. Blank / Gray 3D Viewport when drawing
**Cause**: Wine's default `wined3d` OpenGL translator cannot present D3D11 swapchains inside child windows.
**Fix**: Install DXVK (`winetricks dxvk`) and verify `d3d11,dxgi=n,b` is active in `WINEDLLOVERRIDES`.

---

### 4. Window controls (Minimize, Maximize, Close) are missing / transparent
**Cause**: Missing Microsoft caption symbol fonts (`segmdl2.ttf`, `marlett.ttf`).
**Fix**: Run `python3 scripts/fix_fonts.py "$WINEPREFIX"`.

---

### 5. Home Dashboard / Start tab doesn't load
**Cause**: Embedded Microsoft Edge WebView2 (Chromium) sandbox restriction.
**Fix**: `launch_inventor.sh` automatically supplies `--no-sandbox --disable-gpu-sandbox` via `WEBVIEW2_ADDITIONAL_BROWSER_ARGUMENTS`.

---

### 6. Low frame rates or high CPU usage during modeling
**Cause**: Wine builtin `d3dcompiler_47.dll` stub active instead of Microsoft's native shader compiler.
**Fix**: Copy `d3dcompiler_47.dll` from Inventor's `Bin` directory into `drive_c/windows/system32/` and ensure `d3dcompiler_47=n,b` is set.
