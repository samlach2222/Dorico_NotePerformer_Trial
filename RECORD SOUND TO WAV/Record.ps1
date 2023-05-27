# ------------------------------------
# This script is used to record the audio output of a specific application.
# It uses the ApplicationLoopbackAudio-Sample from Microsoft.
# ------------------------------------
# Author: 	Samlach22
# Date: 	2023-05-27
# Version: 	1.0
# ------------------------------------
# Usage: 	.\Record.ps1
# ------------------------------------
# Please choose AudioEngine :
# 1. VSTAudioEngine5
$AppProcessId = Get-Process -Name "VSTAudioEngine5" | Select -expand ID
# 2. Finale
#$AppProcessId = Get-Process -Name "Finale" | Select -expand ID
# 3. Sibelius
#$AppProcessId = Get-Process -Name "Sibelius" | Select -expand ID
# ------------------------------------

# Define ps1 script path and change directory
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $ScriptPath

# Execute applicationloopbackaudio-sample with start-process
Invoke-Expression "cmd.exe /c ApplicationLoopback.exe $AppProcessId includetree Audio.wav"

# add  [System.Windows.Forms.SaveFileDialog]
Add-Type -AssemblyName System.Windows.Forms

# Ask user the name of the file and the file location with WIndow dialog
$FileLocation = New-Object System.Windows.Forms.SaveFileDialog -Property @{
    InitialDirectory = [Environment]::GetFolderPath('Desktop')
    Filter = 'Waveform Audio File (*.wav)|*.wav'
}
$null = $FileLocation.ShowDialog()

# Copy the file to the location chosen by the user
Copy-Item -Path "$ScriptPath\Audio.wav" -Destination $FileLocation.FileName

# Delete the file
Remove-Item -Path "$ScriptPath\Audio.wav"

# Exit the script
Exit