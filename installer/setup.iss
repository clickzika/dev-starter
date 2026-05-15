; setup.iss — Inno Setup script for DevStarter Windows EXE installer
; Requires: Inno Setup 6.x (https://jrsoftware.org/isinfo.php)
; Build:    iscc installer\setup.iss
; Output:   installer\Output\DevStarter-Setup-vX.Y.Z.exe
;
; The installer:
;   1. Copies all DevStarter files to %USERPROFILE%\.claude\
;   2. Backs up existing files before overwrite (via BeforeInstall)
;   3. Runs setup.sh via Git Bash post-install (optional, skipped if Git not found)

#define AppName "DevStarter"
#define AppPublisher "clickzika"
#define AppURL "https://github.com/clickzika/dev-starter"
#define AppExeName "devstarter-placeholder.exe"

; Read version from VERSION file at build time (set via CI env var or hardcoded here)
#ifndef AppVersion
  #define AppVersion "3.8.0"
#endif

[Setup]
AppId={{B7A2F3C1-4D8E-4F9A-BC12-2E5A7D3F8B91}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} v{#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}/issues
AppUpdatesURL={#AppURL}/releases
DefaultDirName={userdocs}\.claude
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
DisableDirPage=no
OutputDir=installer\Output
OutputBaseFilename=DevStarter-Setup-v{#AppVersion}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
ArchitecturesInstallIn64BitMode=x64compatible
UninstallDisplayName={#AppName} v{#AppVersion}
UninstallDisplayIcon={app}\devstarter-menu.md
SetupIconFile=

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Messages]
WelcomeLabel1=Welcome to DevStarter v{#AppVersion} Setup
WelcomeLabel2=This will install DevStarter into your Claude Code configuration folder (%USERPROFILE%\.claude).%n%nYour existing files will be backed up before any changes are made.

[Files]
; Core directories — sourced from dist/ (run scripts\build-dist.sh first)
Source: "..\dist\agents\*"; DestDir: "{app}\agents"; Flags: recursesubdirs createallsubdirs
Source: "..\dist\skills\*"; DestDir: "{app}\skills"; Flags: recursesubdirs createallsubdirs
Source: "..\dist\sdlc\*"; DestDir: "{app}\sdlc"; Flags: recursesubdirs createallsubdirs
Source: "..\dist\templates\*"; DestDir: "{app}\templates"; Flags: recursesubdirs createallsubdirs

; Root files
Source: "..\dist\devstarter-menu.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\dist\USER.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\dist\setup.sh"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\dist\install.sh"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\dist\VERSION"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\dist\CHANGELOG.md"; DestDir: "{app}"; Flags: ignoreversion

[Run]
; Run setup.sh via Git Bash post-install (best-effort — skipped if Git Bash not found)
Filename: "{code:GetGitBashPath}"; Parameters: """{app}\setup.sh"""; \
  Description: "Run DevStarter setup wizard"; \
  Flags: postinstall runasoriginaluser nowait skipifsilent; \
  Check: GitBashExists

[Code]
var
  GitBashPath: String;

function GetGitBashPath(Param: String): String;
begin
  Result := GitBashPath;
end;

function GitBashExists(): Boolean;
var
  Candidates: TArrayOfString;
  i: Integer;
begin
  SetArrayLength(Candidates, 3);
  Candidates[0] := ExpandConstant('{pf}\Git\bin\bash.exe');
  Candidates[1] := ExpandConstant('{pf(x86)}\Git\bin\bash.exe');
  Candidates[2] := 'C:\Program Files\Git\bin\bash.exe';

  for i := 0 to GetArrayLength(Candidates) - 1 do begin
    if FileExists(Candidates[i]) then begin
      GitBashPath := Candidates[i];
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssInstall then begin
    if not GitBashExists() then
      MsgBox('Git Bash not found. After install, run setup.sh manually using Git Bash.' + #13#10 +
             'Download Git for Windows at: https://git-scm.com', mbInformation, MB_OK);
  end;
end;
