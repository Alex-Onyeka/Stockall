; -------------------------
; Stockall Inno Setup Script
; -------------------------

[Setup]
; Basic app info shown in installer
AppName=Stockall
AppVersion=1.0.1
AppPublisher=Stockall Solutions           ; change this to your org/person
AppContact=alexonyekasm@gmail.com                    ; optional contact email
AppSupportURL=https://stockallapp.com ; optional

; Where to install by default. {pf} = "Program Files" (x86 or x64 depending on installer)
; Use {autopf} for correct program files (x86 vs x64) automatically.
DefaultDirName={autopf}\Stockall

; Start Menu group
DefaultGroupName=Stockall

; Where compiled installer exe will be placed (relative or absolute)
OutputDir=output
OutputBaseFilename=StockallDesktop

; Compression settings (good defaults)
Compression=lzma
SolidCompression=yes

; Determines privilege level needed. "admin" copies to Program Files (default).
; If you prefer per-user installs (no admin), set to "lowest" and change DefaultDirName accordingly.
PrivilegesRequired=admin

; Language: installer will default to English; you can add translations later.

[Files]
; Copy everything from the Release folder into the install dir.
; If you saved this script in your project root, this relative path will work.
Source: "C:\MAIN FLUTTER\stockall\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion
Source: "C:\MAIN FLUTTER\stockall\installer\output\VCRUNTIME140_1.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\MAIN FLUTTER\stockall\installer\output\comctl32.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\MAIN FLUTTER\stockall\installer\output\msvcp140.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\MAIN FLUTTER\stockall\installer\output\msvcp140_1.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\MAIN FLUTTER\stockall\installer\output\ucrtbase.dll"; DestDir: "{app}"; Flags: ignoreversion

; Notes on Flags:
; - recursesubdirs : include subfolders (like data/)
; - createallsubdirs: recreate the folder structure under {app}
; - ignoreversion: ignore file version checks

[Icons]
; Create a Start Menu shortcut
Name: "{group}\Stockall"; Filename: "{app}\Stockall.exe"

; Optionally create a desktop shortcut. User can deselect if AddToDesktop task is added.
Name: "{commondesktop}\Stockall"; Filename: "{app}\Stockall.exe"

[Run]
; Option to launch the app after install (shows a checkbox at end of installer)
Filename: "{app}\Stockall.exe"; Description: "Launch Stockall"; Flags: nowait postinstall skipifsilent
