# Autodesk Licensing Service on Linux

Autodesk applications (Inventor, Fusion 360, AutoCAD, Revit) use the **Autodesk Desktop Licensing Service (`AdskLicensingService.exe`)** to authenticate accounts, educational licenses, and commercial single-user subscriptions.

---

## 1. How Licensing Operates

1. Under Windows, `AdskLicensingService.exe` runs as a continuous NT Service.
2. In Wine, Windows service daemons do not auto-start at boot. Therefore, `launch_inventor.sh` checks if the process is running and automatically starts it in the background before launching `Inventor.exe`:
   ```bash
   LIC_EXE="C:\\Program Files (x86)\\Common Files\\Autodesk Shared\\AdskLicensing\\Current\\AdskLicensingService\\AdskLicensingService.exe"
   if ! pgrep -f "AdskLicensingService.exe" > /dev/null 2>&1; then
       wine "$LIC_EXE" > /dev/null 2>&1 &
       sleep 2
   fi
   ```

---

## 2. Checking Licensing Status & Logs

Autodesk writes detailed licensing verification logs to:
```
$WINEPREFIX/drive_c/users/$USER/AppData/Local/Autodesk/Inventor <YEAR>/Logs/
```

Key log indicator for successful authorization:
```
info.authorized = true
info.state = STATE_ACTIVATED
```

---

## 3. Registering the Product Feature Code

If Inventor starts but reports "License not found", register the product key manually using `AdskLicensingInstHelper.exe`:

```bash
wine "C:\\Program Files (x86)\\Common Files\\Autodesk Shared\\AdskLicensing\\Current\\helper\\AdskLicensingInstHelper.exe" list
```
