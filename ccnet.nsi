; Script generated by the HM NIS Edit Script Wizard.

; HM NIS Edit Wizard helper defines
!define PRODUCT_NAME "CruiseControl.NET"
!define PRODUCT_VERSION "0.9"
!define PRODUCT_PUBLISHER "ThoughtWorks"
!define PRODUCT_WEB_SITE "http://ccnet.thoughtworks.com/"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\ccnet.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"
!define PRODUCT_STARTMENU_REGVAL "NSIS:StartMenuDir"

; Plug-ins
!addplugindir install

; MUI 1.67 compatible ------
!include "MUI.nsh"

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "project\CCTray\App.ico"
!define MUI_UNICON "project\CCTray\App.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "install\install_logo.bmp"
!define MUI_HEADERIMAGE_RIGHT
!define MUI_COMPONENTSPAGE_SMALLDESC


; Welcome page
!insertmacro MUI_PAGE_WELCOME
; License page
!insertmacro MUI_PAGE_LICENSE "deployed\license.txt"
; Components page
!insertmacro MUI_PAGE_COMPONENTS
; Add service page
Page custom AdditionalConfiguration
; Directory page
!insertmacro MUI_PAGE_DIRECTORY
; Start menu page
var ICONS_GROUP
!define MUI_STARTMENUPAGE_NODISABLE
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "CruiseControl.NET"
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "${PRODUCT_STARTMENU_REGVAL}"
!insertmacro MUI_PAGE_STARTMENU Application $ICONS_GROUP
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
;Page custom InstallService InstallService
;Page custom CreateVirtualDirectory CreateVirtualDirectory
; Finish page
Var FinishMessage
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_WELCOMEFINISHPAGE_CUSTOMFUNCTION_INIT PrepareFinishPageMessage
!define MUI_FINISHPAGE_TEXT $FinishMessage
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "English"

; MUI end ------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "dist\${PRODUCT_NAME}-${PRODUCT_VERSION}-Setup.exe"
InstallDir "$PROGRAMFILES\CruiseControl.NET"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails show
ShowUnInstDetails show


Section "CruiseControl.NET Server" SEC01
  SetOutPath "$INSTDIR\server"
  SetOverwrite ifnewer
  File /r /x *.config "deployed\server\*"

  Call BackupAndExtractConfigFiles

  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  CreateDirectory "$SMPROGRAMS\$ICONS_GROUP"
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\CruiseControl.NET.lnk" "$INSTDIR\server\ccnet.exe"
  CreateShortCut "$DESKTOP\CruiseControl.NET.lnk" "$INSTDIR\server\ccnet.exe"
  !insertmacro MUI_STARTMENU_WRITE_END
  
  Call InstallService
SectionEnd

Section "Web Dashboard" SEC02
  SetOutPath "$INSTDIR\webdashboard"
  SetOverwrite ifnewer
  File /r "deployed\webdashboard\*"

  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  !insertmacro MUI_STARTMENU_WRITE_END
  
  Call CreateVirtualDirectory
SectionEnd

Section "CCTray" SEC03
  SetOutPath "$INSTDIR\CCTray"
  SetOverwrite ifnewer
  File "deployed\cctray\*"

  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  !insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

Section -AdditionalIcons
  SetOutPath $INSTDIR
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  WriteIniStr "$INSTDIR\${PRODUCT_NAME}.url" "InternetShortcut" "URL" "${PRODUCT_WEB_SITE}"
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Website.lnk" "$INSTDIR\${PRODUCT_NAME}.url"
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Uninstall.lnk" "$INSTDIR\uninst.exe"
  !insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

Section -Post
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\Server\ccnet.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\Server\ccnet.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd

; Section descriptions
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC01} "The core CruiseControl.NET server."
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC02} "The ASP.NET Web Dashboard for configuring and monitoring builds managed by CruiseControl.NET."
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC03} "The system tray applet for remotely monitoring and triggering builds managed by CruiseControl.NET."
!insertmacro MUI_FUNCTION_DESCRIPTION_END

; Installer functions
Function .onInit
  ;Extract InstallOptions INI files
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT_AS "install\AdditionalConfiguration.ini" "AdditionalConfiguration.ini"
FunctionEnd

LangString TEXT_IO_TITLE ${LANG_ENGLISH} "Additional Configuration"
LangString TEXT_IO_SUBTITLE ${LANG_ENGLISH} "Configure the Windows Service and IIS virtual directory for CruiseControl.NET."

Function AdditionalConfiguration
  !insertmacro MUI_HEADER_TEXT "$(TEXT_IO_TITLE)" "$(TEXT_IO_SUBTITLE)"
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "AdditionalConfiguration.ini"
FunctionEnd

Var ConfigBackedUp
Function BackupAndExtractConfigFiles
  SetOutPath "$INSTDIR\server"
  StrCpy $ConfigBackedUp "no"

  IfFileExists $INSTDIR\server\ccnet.exe.config 0 extractCCNetExeConfig
    DetailPrint "Backing up ccnet.exe.config to ccnet.exe.config.old..."
    Delete $INSTDIR\server\ccnet.exe.config.old
    Rename $INSTDIR\server\ccnet.exe.config $INSTDIR\server\ccnet.exe.config.old
    StrCpy $ConfigBackedUp "yes"
  extractCCNetExeConfig:
    File "deployed\server\ccnet.exe.config"

  IfFileExists $INSTDIR\server\ccservice.exe.config 0 extractCCServiceExeConfig
    DetailPrint "Backing up ccservice.exe.config to ccservice.exe.config.old..."
    Delete $INSTDIR\server\ccservice.exe.config.old
    Rename $INSTDIR\server\ccservice.exe.config $INSTDIR\server\ccservice.exe.config.old
    StrCpy $ConfigBackedUp "yes"
  extractCCServiceExeConfig:
    File "deployed\server\ccservice.exe.config"

  IfFileExists $INSTDIR\server\ccnet.config 0 extractCCNetConfig
    DetailPrint "Backing up ccnet.config to ccnet.config.old..."
    Delete $INSTDIR\server\ccnet.config.old
    Rename $INSTDIR\server\ccnet.config $INSTDIR\server\ccnet.config.old
    StrCpy $ConfigBackedUp "yes"
  extractCCNetConfig:
    File "deployed\server\ccnet.config"

FunctionEnd

Var InstallService
Function InstallService
  !insertmacro MUI_INSTALLOPTIONS_READ $InstallService "AdditionalConfiguration.ini" "Field 1" "State"
  StrCmp $InstallService "0" exit
    DetailPrint "Checking if ccservice is already installed..."
    nsSCM::QueryStatus /NOUNLOAD "CCService"
    Pop $0
    Pop $1
    StrCmp $0 "error" installService
      MessageBox MB_ICONINFORMATION|MB_OK \
      "There is already a service with the name 'CCService' installed. The CruiseControl.NET service will need to be installed manually."
      Return
    installService:
      DetailPrint "Installing ccservice..."
      nsSCM::Install /NOUNLOAD "CCService" "CruiseControl.NET Server" 16 3 "$INSTDIR\server\ccservice.exe" "" ""
      Return
  exit:
FunctionEnd

; Messages for virtual directory creation error messages
LangString ERROR_VDIR_CREATION_UNCONFIRMED ${LANG_ENGLISH} "The installer attempted to create the virtual directory for the CruiseControl.NET Web Dashboard but could not confirm its creation. Please check IIS after the installer has completed and manually create the virtual directory ."
LangString ERROR_VDIR_ALREADY_EXISTS ${LANG_ENGLISH} "A virtual directory called 'ccnet' already exists in the local IIS server's default web site. Please manually create a virtual directory for the CruiseControl.NET Web Dashboard after installation has completed."
LangString ERROR_VDIR_PATH_UNDEFINED ${LANG_ENGLISH} "The installation directory for the CruiseControl.NET Web Dashboard was not specified. Please manually create a virtual directory after installation has completed."
LangString ERROR_VDIR_TIMEOUT ${LANG_ENGLISH} "A timeout occurred during the creation of the virtual directory for the CruiseControl.NET Web Dashboard. Please manually create a virtual directory after installation has completed."
LangString ERROR_GENERAL ${LANG_ENGLISH} "An unspecified error occurred during the creation of the virtual directory for the CruiseControl.NET Web Dashboard. Please manually create a virtual directory after installation has completed."
LangString ERROR_EXEC ${LANG_ENGLISH} "Could not start the createCCNetVDir.vbs script. Please manually create a virtual directory for the CruiseControl.NET Web dashboard after installation has completed."

Var CreateVirtualDirectory
Var ErrorMessage
Function CreateVirtualDirectory
  !insertmacro MUI_INSTALLOPTIONS_READ $CreateVirtualDirectory "AdditionalConfiguration.ini" "Field 2" "State"
  StrCmp $CreateVirtualDirectory "0" exit
    SetOutPath $TEMP
    SetOverwrite on
    File "install\createCCNetVDir.vbs"
    DetailPrint "Creating IIS virtual directory..."
    nsExec::ExecToLog /TIMEOUT=60000 '"$SYSDIR\cscript.exe" "$TEMP\createCCNetVDir.vbs" "$INSTDIR\webdashboard"'
    Pop $0
    StrCmp $0 "4" errorcode4
    StrCmp $0 "3" errorcode3
    StrCmp $0 "2" errorcode2
    StrCmp $0 "1" errorcode1
    StrCmp $0 "timeout" errorTimeout
    StrCmp $0 "error" errorExec
    Goto writeRegistryString
    errorcode4:
      StrCpy $ErrorMessage $(ERROR_VDIR_CREATION_UNCONFIRMED)
      Goto showError
    errorcode3:
      StrCpy $ErrorMessage $(ERROR_VDIR_ALREADY_EXISTS)
      Goto showError
    errorcode2:
      StrCpy $ErrorMessage $(ERROR_VDIR_PATH_UNDEFINED)
      Goto showError
    errorcode1:
      StrCpy $ErrorMessage $(ERROR_GENERAL)
      Goto showError
    errorTimeout:
      StrCpy $ErrorMessage $(ERROR_VDIR_TIMEOUT)
      Goto showError
    errorExec:
      StrCpy $ErrorMessage $(ERROR_EXEC)
    showError:
      MessageBox MB_ICONEXCLAMATION|MB_OK $ErrorMessage
      WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "CCNetVDir" 0
      Goto exit
    writeRegistryString:
      WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "CCNetVDir" $CreateVirtualDirectory
  exit:
FunctionEnd

Var MessageDetail
Function PrepareFinishPageMessage
  StrCmp $ConfigBackedUp "yes" 0 prepMessage
    StrCpy $MessageDetail "Your existing configuration files have been backed up to ccnet.config.old, ccnet.exe.config.old, ccservice.exe.config.old.\r\n"
prepMessage:
  StrCpy $FinishMessage "$(^Name) has been installed on your computer.\r\n\r\n$MessageDetail\r\nClick Finish to close this wizard."
FunctionEnd

Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) was successfully removed from your computer."
FunctionEnd

Function un.onInit
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to completely remove $(^Name) and all of its components? (THIS COULD DELETE ALL CONFIGURATION FILES AND BUILD ARTIFACTS!!)" IDYES +2
  Abort
FunctionEnd

Section Uninstall
  Call un.InstallService
  Call un.RemoveVirtualDirectory
  !insertmacro MUI_STARTMENU_GETFOLDER "Application" $ICONS_GROUP

  Delete "$SMPROGRAMS\$ICONS_GROUP\Uninstall.lnk"
  Delete "$SMPROGRAMS\$ICONS_GROUP\Website.lnk"
  Delete "$DESKTOP\CruiseControl.NET.lnk"
  Delete "$SMPROGRAMS\$ICONS_GROUP\CruiseControl.NET.lnk"

  RMDir "$SMPROGRAMS\$ICONS_GROUP"
  RMDir /r "$INSTDIR"

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  SetAutoClose true
SectionEnd

Function un.InstallService
  nsSCM::QueryStatus /NOUNLOAD "CCService"
  Pop $0
  Pop $1
  StrCmp $0 "error" exit
    DetailPrint "Stopping the CruiseControl.NET service..."
    nsSCM::Stop /NOUNLOAD "CCService"
    DetailPrint "Removing the CruiseControl.NET service..."
    nsSCM::Remove /NOUNLOAD "CCService"
    Pop $0
    Strcmp $0 "success" exit
      MessageBox MB_ICONEXCLAMATION|MB_OK "The CruiseControl.NET service could not be removed."
  exit:
    DetailPrint "CruiseControl.NET service successfully removed."
FunctionEnd

Var RemoveVDir
Function un.RemoveVirtualDirectory
  ReadRegStr $RemoveVDir ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "CCNetVDir"
  StrCmp $RemoveVDir "0" skipRemoveVDir
    SetOutPath $TEMP
    SetOverwrite on
    File "install\removeCCNetVDir.vbs"
    DetailPrint "Removing IIS virtual directory..."
    nsExec::ExecToLog /TIMEOUT=60000 '"$SYSDIR\cscript.exe" "$TEMP\removeCCNetVDir.vbs" "$INSTDIR\webdashboard"'
    Pop $0
    StrCmp $0 "0" exit
      MessageBox MB_ICONINFORMATION|MB_OK "Could not remove the virtual directory due to a general error. Please remove the virtual directory manually."
    Goto exit
  skipRemoveVDir:
    DetailPrint "The CruiseControl.NET virtual directory has not been installed."
  exit:
FunctionEnd