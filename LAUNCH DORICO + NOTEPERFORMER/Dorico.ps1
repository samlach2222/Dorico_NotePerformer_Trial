# Author : Samlach22
# Description : Install NotePerformer trials each time the trials are out
# Version : 2.0
# Date : 2023-05-27
# Usage : Run the script with PowerShell 7
# Requirements : 
# - NotePerformer install path and Dorico install path must be changed
# - NotePerformer path must have "Dorico" in it

# -------------------------------
# | Env Variables and Functions |
# -------------------------------

# relaunch in admin mode if not
if(-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process pwsh.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Exit
}

$url = "https://www.noteperformer.com/DownloadNotePerformerTrial4.php?platform=PC"
$npInstallPath = "PATH_TO_NOTE_PERFORMER_INSTALL_FOLDER\NotePerformer" # /!\ CHANG THIS WITH YOUR INSTALL FOLDER /!\
$doricoInstallPath = "PATH_TO_DORICO_INSTALL_FOLDER\Dorico4.exe" # /!\ CHANG THIS WITH YOUR INSTALL FOLDER -> Can be Dorico5.exe too /!\


if (Test-Path "$npInstallPath\installDate.txt") { # Check if install date file exists
    # check if install date is lower than 30 days
    $installDate = Get-Content -Path "$npInstallPath\installDate.txt" # Get install date
    $installDate = [DateTime]$installDate
    $today = Get-Date
    $today = [DateTime]$today
    $days = ($today - $installDate).Days
    if ($days -lt 30) { # If install date is lower than 30 days, launch Dorico and exit
        $timeUnitlReinstall = 30 - $days
        Write-Output "------------------------------------------"
        Write-Output "| Launch Dorico ($timeUnitlReinstall days until reinstall) |"
        Write-Output "------------------------------------------"
        Start-Process -FilePath $doricoInstallPath 
        timeout 5
        exit
    }
}

# if install date is higher than 30 days or date file don't exists, uninstall NotePerformer and install the new trial

Write-Output "-------------------------------------"
Write-Output "| /!\ NOTEPERFORMER IS OUTDATED /!\ |"
Write-Output "-------------------------------------"

Write-Output "---------------------------------"
Write-Output "| Uninstall NotePerformer Trial |"
Write-Output "---------------------------------"

if (Test-Path $npInstallPath) { # Check if NotePerformer is installed
    Write-Output "NotePerformer is already installed"
    Write-Output "Uninstalling NotePerformer"
    Start-Process -FilePath "$npInstallPath\Uninstall NotePerformer.exe" -ArgumentList "/S" -Wait
    Write-Output "NotePerformer uninstalled"
}

Write-Output "--------------------------------"
Write-Output "| Download NotePerformer Trial |"
Write-Output "--------------------------------"

$download = Invoke-WebRequest -Uri $url
$content = [System.Net.Mime.ContentDisposition]::new($download.Headers["Content-Disposition"])
$fileName = $content.FileName
Write-Host "$fileName Downloaded"

$file = [System.IO.FileStream]::new($fileName, [System.IO.FileMode]::Create)

$file.Write($download.Content, 0, $download.RawContentLength)
$file.Close()

Write-Output "-------------------------------"
Write-Output "| Install NotePerformer Trial |"
Write-Output "-------------------------------"

Start-Process -FilePath $fileName -ArgumentList "/S /D=$npInstallPath" -Wait # Install NotePerformer to a specific folder
Write-Output "NotePerformer installed"
Get-ChildItem -Path . -Filter $fileName -Recurse | Remove-Item -Force -Recurse # delete the setup file
# Store install date
$installDate = Get-Date
$installDate = $installDate.ToString("yyyy-MM-dd")
Set-Content -Path "$npInstallPath\installDate.txt" -Value $installDate

Write-Output "-----------------"
Write-Output "| Launch Dorico |"
Write-Output "-----------------"

Start-Process -FilePath $doricoInstallPath

timeout 5