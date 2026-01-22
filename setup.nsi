# define name of installer
OutFile "aluminum-windows-x86_64.exe"
 
Name "Aluminum"
InstallDir "$PROGRAMFILES\${NAME}"
RequestExecutionLevel admin
 
# start default section
Section
 
    # set the installation directory as the destination for the following actions
    SetOutPath $INSTDIR
 
    # create the uninstaller
    WriteUninstaller "$INSTDIR\uninstall.exe"
 
    # create a shortcut
    CreateShortcut "$SMPROGRAMS\aluminum.lnk" "$INSTDIR\uninstall.exe"
SectionEnd
 
# uninstaller section start
Section "uninstall"
 
    # Remove the link from the start menu
    Delete "$SMPROGRAMS\aluminum.lnk"
 
    # Delete the uninstaller
    Delete $INSTDIR\uninstaller.exe
 
    RMDir $INSTDIR
# uninstaller section end
SectionEnd