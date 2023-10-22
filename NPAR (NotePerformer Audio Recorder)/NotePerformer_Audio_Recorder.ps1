# Author: Samlach22
# Date: 21/10/2023
# Version: 1.0
# Description: Audio Recorder for NotePerfomer using PS Core and FFmpeg. 
# It will record the audio output of your computer and save it to a MP3 file. It will also adjust the gain of the audio file to make it listenable.

# PARAMS :
param($bypassStart = $false)

# FUNCTIONS : 
function MeasureAudioGain {
    param (
        [string]$OutputFile
    )
    $OutputFile = $OutputFile -replace "'", "''"
    $command = "& '$ffmpegLocation' -i '$OutputFile' -af 'volumedetect' -f null /dev/null 2>&1"
    $output = Invoke-Expression -Command $command
    # Extract the gain value from the FFmpeg output.
    $gain = $output | Select-String 'max_volume: ([\d.-]+) dB' | ForEach-Object { $_.Matches[0].Groups[1].Value }
    return $gain
}

function InstallFfmpeg {
    # check if ffmpeg command is available
    $ffmpeg = Get-Command ffmpeg -ErrorAction SilentlyContinue
    If ($ffmpeg -ne $null) {
        return
    }
    # check if ffmpeg is in /ffmpeg
    $ffmpeg = Get-Command "$PSScriptRoot\ffmpeg\ffmpeg.exe" -ErrorAction SilentlyContinue
    If ($ffmpeg -ne $null) {
        return
    }

    Write-Host "FFmpeg is not installed, installing it now..."
    # Download FFmpeg
    # Download latest FFmpeg nightly archive
    Invoke-WebRequest -Uri "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip" -OutFile "$PSScriptRoot\ffmpeg-release-essentials.zip"
    # Extract the archive
    Expand-Archive -Path "$PSScriptRoot\ffmpeg-release-essentials.zip" -DestinationPath "$PSScriptRoot\ffmpeg"
    # get bin folder inside ffmpeg\***\
    $ffmpegPath = Get-ChildItem -Path "$PSScriptRoot\ffmpeg" -Filter "bin" -Recurse -Directory | Select-Object -First 1
    $ffmpegPath = $ffmpegPath.FullName
    # copy ffmpeg.exe, ffplay.exe, ffprobe.exe to /ffmpeg
    Copy-Item -Path "$ffmpegPath\ffmpeg.exe" -Destination "$PSScriptRoot\ffmpeg"
    Copy-Item -Path "$ffmpegPath\ffplay.exe" -Destination "$PSScriptRoot\ffmpeg"
    Copy-Item -Path "$ffmpegPath\ffprobe.exe" -Destination "$PSScriptRoot\ffmpeg"
    # Delete the archive
    Remove-Item "$PSScriptRoot\ffmpeg-release-essentials.zip"
    # Delete all folders in ffmpeg\
    Get-ChildItem -Path "$PSScriptRoot\ffmpeg" -Recurse -Directory | Remove-Item -Recurse -Force > $null
}

# MAIN :
# Load PSCore.dll and create a new instance of the LoopbackRecorder class
Add-Type -Path "PSCore.dll" # TODO : ERROR IN POWERSHELL.EXE BUT NOT IN PWSH.EXE
$Recording = [PSCore.LoopbackRecorder]

# Open explorer select file
Add-Type -AssemblyName System.Windows.Forms
$saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog -Property @{
    Filter = 'MP3 (*.mp3)|*.mp3'
    InitialDirectory = [Environment]::GetFolderPath('Desktop')
    Title = 'Select the output audio file'
}

$result = $saveFileDialog.ShowDialog()

if ($result -ne 'OK') {
    Write-Host 'No output file selected'
    exit
}

# Verify if ffmpeg is installed
InstallFfmpeg
# Check if ffmpeg is located in /ffmpeg
$ffmpegLocation = Get-Command "$PSScriptRoot\ffmpeg\ffmpeg.exe" -ErrorAction SilentlyContinue
If ($ffmpegLocation -eq $null) {
    $ffmpegLocation = "ffmpeg"
} else {
    $ffmpegLocation = "$PSScriptRoot\ffmpeg\ffmpeg.exe"
}
Write-Host "FFmpeg path: $ffmpegLocation"

$OutputFile = $saveFileDialog.FileName
Write-Host "Output file: $OutputFile"

    Write-Host "---------------------------------"
    Write-Host "| Note Performer Audio Recorder |"
    Write-Host "|--------------------------------"
    Write-Host "|                               |"
if ($bypassStart) {
    Write-Host "| Press 'e' to stop recording   |"
} else {
    Write-Host "| Press 's' to start recording  |"
    Write-Host "| Press 'e' to stop recording   |"
}
    Write-Host "|                               |"
    Write-Host "---------------------------------"
    Write-Host ""

$recordingFlag = $false

if ($bypassStart) {
    $pipe = New-Object IO.Pipes.NamedPipeClientStream('.', 'npar', 'In')
    $pipe.Connect()

    $recordingFlag = $true
    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    Write-Host "Recording started"
    $Recording::StartRecording($OutputFile, 320000)
}

while ($true) {
    if ([System.Console]::KeyAvailable) {
        $key = [System.Console]::ReadKey($true).KeyChar

        if ($key -eq 's' -and -not $recordingFlag) {
            $timer = [System.Diagnostics.Stopwatch]::StartNew()
            Write-Host "Recording started"
            $Recording::StartRecording($OutputFile, 320000)
            $recordingFlag = $true
        }
        elseif ($key -eq 'e' -and $recordingFlag) {
            $Recording::StopRecording()
            Write-Host "Recording stopped"
            break
        }
    }
    # Display the recording time in the same line each time
    if ($recordingFlag) {
        Write-Host -NoNewline "`r" $timer.Elapsed.ToString("hh\:mm\:ss\.fff")
    }
}

# Use FFmpeg to measure the audio gain.
$gain = MeasureAudioGain $OutputFile
Write-Host "Base gain of $OutputFile : $gain dB"

# Use FFmpeg to ajust the audio gain.
If ($gain -ne $null -and $gain -ne 0) {
    $OutputFile = $OutputFile -replace "'", "''"
    $gain = 0 - $gain
    $tempFile = $OutputFile -replace ".mp3", "_temp.mp3"
    $command = "& '$ffmpegLocation' -nostats -loglevel 0 -i '$OutputFile' -af 'volume=$gain dB' -y '$tempFile'"
    $output = Invoke-Expression -Command $command

    # Delete the original file and rename the temp file.
    Remove-Item $OutputFile
    Rename-Item $tempFile $OutputFile

    # Extract the gain value from the FFmpeg output.
    $gain = MeasureAudioGain $OutputFile
    Write-Host "New gain of $OutputFile : $gain dB"

    # Wait for user input before exiting.
    Write-Host "File saved to $OutputFile, press any key to exit"
    $Host.UI.RawUI.ReadKey('IncludeKeyDown,NoEcho') | Out-Null
} else {
    Write-Host "No sound detected, no gain adjustment and no file"
}
Pause