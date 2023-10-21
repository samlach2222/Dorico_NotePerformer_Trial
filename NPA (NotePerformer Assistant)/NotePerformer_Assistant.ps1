# Author : Samlach22
# Description : Install NotePerformer trials each time the trials are out
# Version : 1.3
# Date : 2023-07-21
# Usage : Run the script with PowerShell 7
# Requirements : 
# - NotePerformer install path and Dorico install path must be changed
# - NotePerformer path must have "Dorico" in it

# relaunch in admin mode if not
if(-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process pwsh.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden  -File `"$PSCommandPath`""   # ⚠ REMOVE "-WindowStyle Hidden" TO SEE THE POWERSHELL WINDOW ⚠
    Exit
}

# ------------------------------- #
# | Env Variables and Functions | #
# ------------------------------- #
$url = "https://www.noteperformer.com/DownloadNotePerformerTrial5.php?platform=PC"
$npInstallPath = "PATH_TO_NOTE_PERFORMER_INSTALL_FOLDER\NotePerformer" # /!\ CHANGE THIS WITH YOUR INSTALL FOLDER /!\
$doricoInstallPath = "PATH_TO_DORICO_INSTALL_FOLDER\Dorico5.exe" # /!\ CHANGE THIS WITH YOUR INSTALL FOLDER -> Can be Dorico5.exe too /!\

# ---------------------------- #
# | Function to Reinstall NP | #
# ---------------------------- #
function ReinstallNotePerformer() {
    if (Test-Path $npInstallPath) { # Check if NotePerformer is installed
        Start-Process -FilePath "$npInstallPath\Uninstall NotePerformer.exe" -ArgumentList "/S" -Wait
    }
    $download = Invoke-WebRequest -Uri $url
    $content = [System.Net.Mime.ContentDisposition]::new($download.Headers["Content-Disposition"])
    $fileName = $content.FileName
    Write-Host "$fileName Downloaded"

    $file = [System.IO.FileStream]::new($fileName, [System.IO.FileMode]::Create)

    $file.Write($download.Content, 0, $download.RawContentLength)
    $file.Close()

    Start-Process -FilePath $fileName -ArgumentList "/S /D=$npInstallPath" -Wait # Install NotePerformer to a specific folder
    Get-ChildItem -Path . -Filter $fileName -Recurse | Remove-Item -Force -Recurse # delete the setup file
    # Store install date
    $installDate = Get-Date
    $installDate = $installDate.ToString("yyyy-MM-dd")
    Set-Content -Path "$npInstallPath\installDate.txt" -Value $installDate
}

# --------------------------------------- #
# | Function to Launch Dorico With NPPE | #
# --------------------------------------- #
function LaunchDoricoWithNPPE() {
    $ButtonLaunchDoricoWithNPPE.Text = "Dorico + NPPE is running..."
    Start-Process -FilePath $doricoInstallPath

    Start-Process -FilePath "$npInstallPath\NotePerformer Playback Engines\NotePerformer Playback Engines.exe"

    timeout 20 # Wait for Dorico to launch
    $processName = "Dorico5"
    $process = Get-Process -Name $processName
    
    while ($process) {
        # don't show error if process is not found
        $process = Get-Process -Name $processName -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
    }

    # Close VSTAudioEngine5
    $processName = "VSTAudioEngine5"
    $process = Get-Process -Name $processName -ErrorAction SilentlyContinue
    if ($process) {
        $ButtonLaunchDoricoWithNPPE.Text = "VSTAudioEngine5 closed"
        Stop-Process -Name $processName -ErrorAction SilentlyContinue
    }
    # Close NotePerformer Playback Engines
    $processName = "NotePerformer Playback Engines"
    $process = Get-Process -Name $processName -ErrorAction SilentlyContinue
    if ($process) {
        $ButtonLaunchDoricoWithNPPE.Text = "NPPE closed"
        Stop-Process -Name $processName -ErrorAction SilentlyContinue
    }
}

# ----------------------------- #
# | Function to Launch Dorico | #
# ----------------------------- #
function LaunchDorico() {
    $ButtonLaunchDorico.Text = "Dorico is running..."
    Start-Process -FilePath $doricoInstallPath
    timeout 20 # Wait for Dorico to launch

    $processName = "Dorico5"
    $process = Get-Process -Name $processName
    
    while ($process) {
        # don't show error if process is not found
        $process = Get-Process -Name $processName -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
    }

    # Close VSTAudioEngine5
    $processName = "VSTAudioEngine5"
    $process = Get-Process -Name $processName -ErrorAction SilentlyContinue
    if ($process) {
        $ButtonLaunchDorico.Text = "VSTAudioEngine5 closed"
        Stop-Process -Name $processName -ErrorAction SilentlyContinue
    }
}

# ------------------------------------ #
# | Force reinstall NP if trial done | #
# ------------------------------------ #
if (Test-Path "$npInstallPath\installDate.txt") { # Check if install date file exists
    # check if install date is lower than 30 days
    $installDate = Get-Content -Path "$npInstallPath\installDate.txt" # Get install date
    $installDate = [DateTime]$installDate
    $today = Get-Date
    $today = [DateTime]$today
    $days = ($today - $installDate).Days
    if ($days -lt 30) { # If install date is lower than 30 days, launch Dorico and exit
    }
    else {
        [void] [System.Windows.MessageBox]::Show( "Note Performer are going to be reinstalled ", "Note Performer Manager", "OK", "Information" )
        ReinstallNotePerformer
    }
}

# --------------- #
# | MAIN WINDOW | #
# --------------- #
Add-Type -assembly System.Windows.Forms
Add-Type -AssemblyName PresentationFramework
$main_form = New-Object System.Windows.Forms.Form
$main_form.Text ='Note Perfomer Manager'
$main_form.Width = 400
$main_form.Height = 670
$main_form.AutoSize = $true 
$main_form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle # Make the form not resizable
$main_form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen # Center the form
$main_form.MaximizeBox = $false # Disable the maximize button
# change the icon of the form
$icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$PSScriptRoot\Resources\NP_Logo.ico")
$main_form.Icon = $icon

# ----------------------- #
# | LOGO NOTE PERFORMER | #
# ----------------------- #
$logoNP = New-Object System.Windows.Forms.PictureBox
$logoNP.Width = 400
$logoNP.Height = 100
$logoNP.Location = New-Object System.Drawing.Size(0,10)
$logoNP.Image = [System.Drawing.Image]::FromFile("$PSScriptRoot\Resources\NP_Logo.png")
$logoNP.SizeMode = 'Zoom'
$main_form.Controls.Add($logoNP)

# -------------------------------- #
# | BUTTON UPDATE NOTE PERFORMER | #
# -------------------------------- #
$ButtonUpdateNotePerformer = New-Object System.Windows.Forms.Button
$ButtonUpdateNotePerformer.Location = New-Object System.Drawing.Size(75,130)
$ButtonUpdateNotePerformer.Size = New-Object System.Drawing.Size(250,23)
if (Test-Path "$npInstallPath\installDate.txt") {
    $installDate = Get-Content -Path "$npInstallPath\installDate.txt" # Get install date
    $installDate = [DateTime]$installDate
    $today = Get-Date
    $today = [DateTime]$today
    $days = 30 - ($today - $installDate).Days
    $ButtonUpdateNotePerformer.Text = "Update NotePerformer (Remains $days days)"
}
else {
    $ButtonUpdateNotePerformer.Text = "Update NotePerformer (OUTDATED)"
}
$main_form.Controls.Add($ButtonUpdateNotePerformer)
$ButtonUpdateNotePerformer.Add_Click(
    {
        $ButtonUpdateNotePerformer.Text = "UPDATE IN PROGRESS..."
        ReinstallNotePerformer
        $ButtonUpdateNotePerformer.Text = "DONE !"
        $ButtonUpdateNotePerformer.Enabled = $false
    }
)

# ---------------------- #
# | BUTTON LAUNCH NPPE | #
# ---------------------- #
$ButtonLaunchNPPE = New-Object System.Windows.Forms.Button
$ButtonLaunchNPPE.Location = New-Object System.Drawing.Size(75,160)
$ButtonLaunchNPPE.Size = New-Object System.Drawing.Size(250,23)
$ButtonLaunchNPPE.Text = "Launch NotePerformer Playback Engine"
$main_form.Controls.Add($ButtonLaunchNPPE)
$ButtonLaunchNPPE.Add_Click(
    {
        Start-Process -FilePath "$npInstallPath\NotePerformer Playback Engines\NotePerformer Playback Engines.exe"
    }
)

# --------------------- #
# | HORIZONTAL SPACER | #
# --------------------- #
$horizontalBar = New-Object System.Windows.Forms.Label
$horizontalBar.Location = New-Object System.Drawing.Size(0,200)
$horizontalBar.Size = New-Object System.Drawing.Size(400,2)
$horizontalBar.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$main_form.Controls.Add($horizontalBar)

# ----------------------- #
# | LOGO VIRTUAL MEMORY | #
# ----------------------- #
$logoVM = New-Object System.Windows.Forms.PictureBox
$logoVM.Width = 400
$logoVM.Height = 100
$logoVM.Location = New-Object System.Drawing.Size(0,210)
$logoVM.Image = [System.Drawing.Image]::FromFile("$PSScriptRoot\Resources\VirtualMemory_Logo.png")
$logoVM.SizeMode = 'Zoom'
$main_form.Controls.Add($logoVM)

# ----------------------- #
# | LABEL AMOUNT OF RAM | #
# ----------------------- #
$ram = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty TotalPhysicalMemory
$ramAmount = [math]::Round($ram / 1GB, 2)
$virtualMemoryAmount = 2
$LabelAmountOfRAM = New-Object System.Windows.Forms.Label
$LabelAmountOfRAM.Location = New-Object System.Drawing.Size(0,320)
$LabelAmountOfRAM.Size = New-Object System.Drawing.Size(400,20)
$LabelAmountOfRAM.Text = "RAM : $ramAmount GB"
# Text align center
$LabelAmountOfRAM.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$main_form.Controls.Add($LabelAmountOfRAM)

# ---------------------- #
# | LABEL AMOUNT OF VM | #
# ---------------------- #
# get PagingFiles from registry
$PagingFiles = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name PagingFiles
# Check if PagingFiles exist
if ($PagingFiles) {
    $virtualMemoryAmount = $PagingFiles.PagingFiles.Substring($PagingFiles.PagingFiles.Length - 6) / 1024
}
else {
    $virtualMemoryAmount = 0
}
$LabelAmountOfVM = New-Object System.Windows.Forms.Label
$LabelAmountOfVM.Location = New-Object System.Drawing.Size(0,340)
$LabelAmountOfVM.Size = New-Object System.Drawing.Size(400,20)
$LabelAmountOfVM.Text = "Virtual Memory : $virtualMemoryAmount GB"
# Text align center
$LabelAmountOfVM.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$main_form.Controls.Add($LabelAmountOfVM)

# ----------------------------- #
# | BUTTON ADD VIRTUAL MEMORY | #
# ----------------------------- #
$ButtonAddVirtualMemory = New-Object System.Windows.Forms.Button
$ButtonAddVirtualMemory.Location = New-Object System.Drawing.Size(75,370)
$ButtonAddVirtualMemory.Size = New-Object System.Drawing.Size(250,23)
$ButtonAddVirtualMemory.Text = "Add 128 GB of VM (REBOOT REQUIRED)"
$main_form.Controls.Add($ButtonAddVirtualMemory)
$ButtonAddVirtualMemory.Add_Click(
    {
        $answer = [System.Windows.MessageBox]::Show( "The PC will reboot, did you really want to add 128 GB of Virtual Memory ?", "Note Performer Manager", "YesNo", "Warning" )
        if($answer -eq "Yes"){
            $PageFilePath = "C:\pagefile.sys"
            $InitialSizeMB = 131072
            $MaximumSizeMB = 131072
            New-Item -Path $PageFilePath -ItemType File -Value 0 -Force
            $PageFileConfig = "$PageFilePath $InitialSizeMB $MaximumSizeMB"
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "PagingFiles" -Value $PageFileConfig
            Stop-Computer -Force
        }
    }
)

# -------------------------------- #
# | BUTTON REMOVE VIRTUAL MEMORY | #
# -------------------------------- #
$ButtonRemoveVirtualMemory = New-Object System.Windows.Forms.Button
$ButtonRemoveVirtualMemory.Location = New-Object System.Drawing.Size(75,400)
$ButtonRemoveVirtualMemory.Size = New-Object System.Drawing.Size(250,23)
$ButtonRemoveVirtualMemory.Text = "Remove VM (REBOOT REQUIRED)"
$main_form.Controls.Add($ButtonRemoveVirtualMemory)
$ButtonRemoveVirtualMemory.Add_Click(
    {
        $answer = [System.Windows.MessageBox]::Show( "The PC will reboot, did you really want to remove Virtual Memory ?", "Note Performer Manager", "YesNo", "Warning" )
        if($answer -eq "Yes"){
            Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "PagingFiles" -Force
            Stop-Computer -Force
        }
    }
)
if($virtualMemoryAmount -gt 0){
    $ButtonAddVirtualMemory.Enabled = $false
    $ButtonRemoveVirtualMemory.Enabled = $true
}
else {
    $ButtonAddVirtualMemory.Enabled = $true
    $ButtonRemoveVirtualMemory.Enabled = $false
}

# --------------------- #
# | HORIZONTAL SPACER | #
# --------------------- #
$horizontalBar = New-Object System.Windows.Forms.Label
$horizontalBar.Location = New-Object System.Drawing.Size(0,440)
$horizontalBar.Size = New-Object System.Drawing.Size(400,2)
$horizontalBar.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$main_form.Controls.Add($horizontalBar)

# --------------- #
# | LOGO DORICO | #
# --------------- #
$logoD = New-Object System.Windows.Forms.PictureBox
$logoD.Width = 400
$logoD.Height = 100
$logoD.Location = New-Object System.Drawing.Size(0,450)
$logoD.Image = [System.Drawing.Image]::FromFile("$PSScriptRoot\Resources\D_Logo.png")
$logoD.SizeMode = 'Zoom'
$main_form.Controls.Add($logoD)

# ------------------------ #
# | BUTTON LAUNCH DORICO | #
# ------------------------ #
$ButtonLaunchDorico = New-Object System.Windows.Forms.Button
$ButtonLaunchDorico.Location = New-Object System.Drawing.Size(75,560)
$ButtonLaunchDorico.Size = New-Object System.Drawing.Size(250,23)
$ButtonLaunchDorico.Text = "Launch Dorico"
$main_form.Controls.Add($ButtonLaunchDorico)
$ButtonLaunchDorico.Add_Click(
    {
        $ButtonLaunchDoricoWithNPPE.Enabled = $false
        $ButtonLaunchDorico.Enabled = $false
        LaunchDorico
        $ButtonLaunchDorico.Text = "Launch Dorico"
        $ButtonLaunchDorico.Enabled = $true
        $ButtonLaunchDoricoWithNPPE.Enabled = $true
    }
)

# ---------------------------------- #
# | BUTTON LAUNCH DORICO WITH NPPE | #
# ---------------------------------- #
$ButtonLaunchDoricoWithNPPE = New-Object System.Windows.Forms.Button
$ButtonLaunchDoricoWithNPPE.Location = New-Object System.Drawing.Size(75,590)
$ButtonLaunchDoricoWithNPPE.Size = New-Object System.Drawing.Size(250,23)
$ButtonLaunchDoricoWithNPPE.Text = "Launch Dorico + NPPE"
$main_form.Controls.Add($ButtonLaunchDoricoWithNPPE)
$ButtonLaunchDoricoWithNPPE.Add_Click(
    {
        $ButtonLaunchDoricoWithNPPE.Enabled = $false
        $ButtonLaunchDorico.Enabled = $false
        LaunchDoricoWithNPPE
        $ButtonLaunchDoricoWithNPPE.Text = "Launch Dorico + NPPE"
        $ButtonLaunchDorico.Enabled = $true
        $ButtonLaunchDoricoWithNPPE.Enabled = $true
        $answer = [System.Windows.MessageBox]::Show( "Dou you want to remove the Virtual Memory (REBOOT REQUIRED) ?", "Note Performer Manager", "YesNo", "Warning" )
        if($answer -eq "Yes"){
            Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "PagingFiles" -Force
            Stop-Computer -Force
        }
    }
)

$main_form.ShowDialog()