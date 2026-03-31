!include "MUI2.nsh"
!include "nsDialogs.nsh"
!include "LogicLib.nsh"

Name "pioasm"

!ifndef VERSION
  !define VERSION "dev"
!endif

!ifndef SUFFIX
  !define SUFFIX "unknown"
!endif

OutFile "${BUILD_ROOT}\bin\pico-sdk-tools-${VERSION}-${SUFFIX}.exe"

RequestExecutionLevel admin

Var InstallScope
Var RadioUser
Var RadioAll

InstallDir "$LOCALAPPDATA\Programs\pico-tools\pioasm"

Function .onInit
  SetRegView 64

  ReadRegStr $R0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\pioasm" "UninstallString"
  ${If} $R0 == ""
    ReadRegStr $R0 HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\pioasm" "UninstallString"
  ${EndIf}
  ${If} $R0 != ""
    MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
      "An existing installation of pioasm was found and will be removed before continuing." \
      IDOK do_uninstall IDCANCEL cancel

  do_uninstall:
    ExecWait '$R0 /S'
    Sleep 500
  ${EndIf}

  cancel:
FunctionEnd

!insertmacro MUI_PAGE_WELCOME

Page custom SelectScope SelectScopeLeave

!define MUI_PAGE_CUSTOMFUNCTION_PRE SetInstallDir
!insertmacro MUI_PAGE_DIRECTORY

!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_LANGUAGE "English"

Function SelectScope
  nsDialogs::Create 1018
  Pop $0

  ${NSD_CreateLabel} 0 0 100% 12u "Install for:"
  Pop $1

  ${NSD_CreateRadioButton} 0 20u 100% 12u "Current user only"
  Pop $RadioUser

  ${NSD_CreateRadioButton} 0 40u 100% 12u "All users"
  Pop $RadioAll

  ${NSD_Check} $RadioUser

  nsDialogs::Show
FunctionEnd

Function SelectScopeLeave
  ${NSD_GetState} $RadioAll $InstallScope
FunctionEnd

Function SetInstallDir
  ${If} $InstallScope == 1
    StrCpy $INSTDIR "$PROGRAMFILES64\pico-tools\pioasm"
  ${Else}
    StrCpy $INSTDIR "$LOCALAPPDATA\Programs\pico-tools\pioasm"
  ${EndIf}
FunctionEnd

Section "Install"

  SetRegView 64

  ${If} $InstallScope == 1
    SetShellVarContext all
    EnVar::SetHKLM
  ${Else}
    SetShellVarContext current
    EnVar::SetHKCU
  ${EndIf}

  SetOutPath "$INSTDIR"

  File /r "${BUILD_ROOT}\build\pico-sdk-tools\ucrt64\pioasm\*"

  ClearErrors
  EnVar::AddValue "PATH" "$INSTDIR"
  Pop $0

  SendMessage ${HWND_BROADCAST} ${WM_SETTINGCHANGE} 0 "STR:Environment"

  WriteUninstaller "$INSTDIR\uninstall.exe"

  ${If} $InstallScope == 1
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\pioasm" \
      "DisplayName" "pioasm"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\pioasm" \
      "UninstallString" "$INSTDIR\uninstall.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\pioasm" \
      "DisplayVersion" "${VERSION}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\pioasm" \
      "InstallLocation" "$INSTDIR"
  ${Else}
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\pioasm" \
      "DisplayName" "pioasm"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\pioasm" \
      "UninstallString" "$INSTDIR\uninstall.exe"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\pioasm" \
      "DisplayVersion" "${VERSION}"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\pioasm" \
      "InstallLocation" "$INSTDIR"
  ${EndIf}

SectionEnd

Section "Uninstall"

  SetRegView 64

  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\pioasm"
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\pioasm"

  ClearErrors
  EnVar::SetHKLM
  EnVar::DeleteValue "PATH" "$INSTDIR"
  Pop $0

  ClearErrors
  EnVar::SetHKCU
  EnVar::DeleteValue "PATH" "$INSTDIR"
  Pop $0

  SendMessage ${HWND_BROADCAST} ${WM_SETTINGCHANGE} 0 "STR:Environment"

  RMDir /r "$INSTDIR"

SectionEnd
