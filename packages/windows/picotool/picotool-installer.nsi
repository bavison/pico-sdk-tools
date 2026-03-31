!include "MUI2.nsh"
!include "nsDialogs.nsh"
!include "LogicLib.nsh"

Name "picotool"

!ifndef VERSION
  !define VERSION "dev"
!endif

!ifndef SUFFIX
  !define SUFFIX "unknown"
!endif

OutFile "${BUILD_ROOT}\bin\picotool-${VERSION}-${SUFFIX}.exe"

RequestExecutionLevel admin

Var InstallScope
Var RadioUser
Var RadioAll

InstallDir "$LOCALAPPDATA\Programs\pico-tools\picotool"

Function .onInit
  SetRegView 64
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
    StrCpy $INSTDIR "$PROGRAMFILES64\pico-tools\picotool"
  ${Else}
    StrCpy $INSTDIR "$LOCALAPPDATA\Programs\pico-tools\picotool"
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

  File /r "${BUILD_ROOT}\build\picotool-install\ucrt64\picotool\*"

  ClearErrors
  EnVar::AddValue "PATH" "$INSTDIR"
  Pop $0

  SendMessage ${HWND_BROADCAST} ${WM_SETTINGCHANGE} 0 "STR:Environment"

  WriteUninstaller "$INSTDIR\uninstall.exe"

  ${If} $InstallScope == 1
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\picotool" \
      "DisplayName" "picotool"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\picotool" \
      "UninstallString" "$INSTDIR\uninstall.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\picotool" \
      "DisplayVersion" "${VERSION}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\picotool" \
      "InstallLocation" "$INSTDIR"
  ${Else}
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\picotool" \
      "DisplayName" "picotool"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\picotool" \
      "UninstallString" "$INSTDIR\uninstall.exe"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\picotool" \
      "DisplayVersion" "${VERSION}"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\picotool" \
      "InstallLocation" "$INSTDIR"
  ${EndIf}

SectionEnd

Section "Uninstall"

  SetRegView 64

  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\picotool"
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\picotool"

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
