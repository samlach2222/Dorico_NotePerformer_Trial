#################################
# Relaunch in admin mode if not #
#################################
if(-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process pwsh.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden  -File `"$PSCommandPath`""   # ⚠ REMOVE "-WindowStyle Hidden" TO SEE THE POWERSHELL WINDOW ⚠
    Exit
}

##################################
# Initialize NP and Dorico paths #
##################################
$npInstallPath = """C:\Program Files\Steinberg\Dorico5\NotePerformer"""
$doricoInstallPath = """C:\Program Files\Steinberg\Dorico5\Dorico5.exe"""

#######################################################
# Copy NPA (NotePerformer Assistant) to Dorico folder #
#######################################################
$doricoPath = $doricoInstallPath.Substring(0, $doricoInstallPath.LastIndexOf("\"))
$doricoPath = $doricoPath.Substring(1)
$npaPath = "./NPA (NotePerformer Assistant)"
Copy-Item -Path $npaPath -Destination $doricoPath -Recurse -Force

####################################################
# Change NPA $npInstallPath and $doricoInstallPath #
####################################################
$ScriptPath = $doricoPath + "\NPA (NotePerformer Assistant)\NotePerformer_Assistant.ps1"
# Search for "# /!\ CHANGE THIS WITH YOUR INSTALL FOLDER /!\" and replace the line with the new path
(Get-Content $ScriptPath) | ForEach-Object { $_ -replace ".* # /!\\ CHANGE THIS WITH YOUR NP INSTALL FOLDER /!\\", ('$npInstallPath = ' + $npInstallPath + " # /!\\ CHANGE THIS WITH YOUR NP INSTALL FOLDER /!\\") } | Set-Content $ScriptPath
(Get-Content $ScriptPath) | ForEach-Object { $_ -replace ".* # /!\\ CHANGE THIS WITH YOUR DORICO INSTALL FOLDER /!\\", ('$doricoInstallPath = ' + $doricoInstallPath + " # /!\\ CHANGE THIS WITH YOUR DORICO INSTALL FOLDER /!\\") } | Set-Content $ScriptPath

####################################
# Create a desktop shortcut to NPA #
####################################
$npaShortcutPath = "$env:USERPROFILE\Desktop\NPA (NotePerformer Assistant).lnk"
$targetPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$npaTargetPath = "$doricoPath\NPA (NotePerformer Assistant)\NotePerformer_Assistant.ps1"
$scriptToRun = "$npaTargetPath"

$npaStartIn = "C:\Windows\System32\WindowsPowerShell\v1.0"
# Get icon from Dorico5.exe
$iconPath = $doricoInstallPath
$iconPath = $iconPath.Substring(0, $iconPath.LastIndexOf("\"))
$iconPath = "$iconPath\Dorico5.exe"

# Create shortcut
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($npaShortcutPath)
$Shortcut.WorkingDirectory = """" + $npaStartIn + """"
$Shortcut.TargetPath = $targetPath
$Shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptToRun`""
$Shortcut.IconLocation = $iconPath
$Shortcut.Save()

#####################################################################
# COPY NPAR (NotePerformer Audio Recorder) TO %APPDATA% Dorico Path #
#####################################################################
$nparPath = "./NPAR (NotePerformer Audio Recorder)"
$npaAppDataPath = "$env:APPDATA\Steinberg\Dorico 5\Script Plug-ins"
# Copy all items inside $nparPath folder but not the folder itself
Copy-Item -Path "$nparPath\*" -Destination $npaAppDataPath -Recurse -Force