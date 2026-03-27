#ifndef AppVersion
  #define AppVersion "1.0.0"
#endif

[Setup]
; Unikátne ID aplikácie - nemeňte ho po prvom vydaní!
AppId={{5F8B854A-12E6-4FF7-91B6-8C379D96E14B}
AppName=Vyjadrenia
AppVersion={#AppVersion}
AppPublisher=Martin Dvorsky
DefaultDirName={autopf}\Vyjadrenia
DisableProgramGroupPage=yes
; Metadata pre samotný inštalátor (.exe súbor)
VersionInfoCompany=Martin Dvorsky
VersionInfoCopyright=Copyright (C) 2025 Martin Dvorsky
VersionInfoDescription=Inštalátor aplikácie Vyjadrenia
; Kde sa vygeneruje výsledný .exe inštalátor
OutputDir=dist
OutputBaseFilename=Vyjadrenia_Installer
Compression=lzma
SolidCompression=yes
WizardStyle=modern
; Auto-update bez zbytočného pýtania:
SetupLogging=yes
DisableReadyPage=yes
DisableWelcomePage=yes

[Languages]
Name: "slovak"; MessagesFile: "compiler:Languages\Slovak.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "build\windows\x64\runner\Release\vyjadrenia.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; POZNÁMKA: "Flags: ignoreversion" zabezpečí, že pri aktualizácii inštalátor bez problémov prepíše existujúce staré súbory.

[Icons]
Name: "{autoprograms}\Vyjadrenia"; Filename: "{app}\vyjadrenia.exe"
Name: "{autodesktop}\Vyjadrenia"; Filename: "{app}\vyjadrenia.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\vyjadrenia.exe"; Description: "{cm:LaunchProgram,Vyjadrenia}"; Flags: nowait postinstall skipifsilent

[InstallDelete]
; Vymaže predchádzajúce staré nepotrebné súbory
Type: filesandordirs; Name: "{app}\data"
