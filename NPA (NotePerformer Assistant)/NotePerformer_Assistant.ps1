# Authors : Samlach2222, Mahtwo
# Description : Install NotePerformer trials each time the trials are out
# Version : 1.5
# Date : 2024-10-26
# Usage : Run the script with PowerShell 7
# Requirements :
# - NotePerformer install path and Dorico install path must be changed
# - NotePerformer path must have "Dorico" in it

# relaunch in admin mode if not
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process pwsh.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`""   # ⚠ REMOVE "-WindowStyle Hidden" TO SEE THE POWERSHELL WINDOW ⚠
    Exit
}

# ------------------------------- #
# | Env Variables and Functions | #
# ------------------------------- #
$url = "https://www.noteperformer.com/DownloadNotePerformerTrial5.php?platform=PC"
$npInstallPath = "PATH_TO_NOTE_PERFORMER_INSTALL_FOLDER\NotePerformer" # /!\ CHANGE THIS WITH YOUR NP INSTALL FOLDER /!\
$doricoInstallPath = "PATH_TO_DORICO_INSTALL_FOLDER\Dorico5.exe" # /!\ CHANGE THIS WITH YOUR DORICO INSTALL FOLDER /!\

# ---------------------------- #
# | Function to Reinstall NP | #
# ---------------------------- #

function ReinstallNotePerformer() {
    $uninstallPath = "$npInstallPath\Uninstall NotePerformer.exe"
    if (Test-Path $uninstallPath) {
        Start-Process -FilePath $uninstallPath -ArgumentList "/S" -Wait
    }

    # Start a background job to monitor the Dorico process
    $ref_buttonUpdateNotePerformer = Get-Variable ButtonUpdateNotePerformer
    $job = Start-ThreadJob {
        param($url, $npInstallPath)

        # Initialize download settings
        $webRequest = [System.Net.HttpWebRequest]::Create($url)
        $webRequest.Method = "GET"
        $webResponse = $webRequest.GetResponse()
        $totalBytes = $webResponse.ContentLength

        # Determine the file name from Content-Disposition or URL
        $contentDisposition = $webResponse.Headers["Content-Disposition"]
        $fileName = if ($contentDisposition) {
            ([System.Net.Mime.ContentDisposition]::new($contentDisposition)).FileName
        }
        else {
            [System.IO.Path]::GetFileName($url)
        }

        Write-Host "$fileName Downloaded"

        # Prepare file stream for saving download
        $fileStream = [System.IO.FileStream]::new($fileName, [System.IO.FileMode]::Create)
        $responseStream = $webResponse.GetResponseStream()
        $buffer = New-Object byte[] 8192  # Buffer size: 8 KB
        $totalRead = 0

        # Download in chunks and update progress
        while (($read = $responseStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
            $fileStream.Write($buffer, 0, $read)
            $totalRead += $read

            # Calculate and display download progress
            $percentage = [math]::Round(($totalRead / $totalBytes) * 100, 2)
            $percentage *> log.txt
            ($using:ref_buttonUpdateNotePerformer).Value.Text = "DOWNLOAD IN PROGRESS ($percentage%)"
        }
        ($using:ref_buttonUpdateNotePerformer).Value.Text = "DOWNLOAD DONE !"
        # Clean up streams after download is complete
        $fileStream.Close()
        $responseStream.Close()

        # Install NotePerformer
        ($using:ref_buttonUpdateNotePerformer).Value.Text = "INSTALL IN PROGRESS..."
        Start-Process -FilePath $fileName -ArgumentList "/S /D=$npInstallPath" -Wait

        # Delete the setup file
        Remove-Item -Path $fileName -Force

        # Store install date
        $installDate = (Get-Date).ToString("yyyy-MM-dd")
        Set-Content -Path "$npInstallPath\installDate.txt" -Value $installDate
        ($using:ref_buttonUpdateNotePerformer).Value.Text = "INSTALL DONE !"
        if (Test-Path "$npInstallPath\installDate.txt") {
            $installDate = Get-Content -Path "$npInstallPath\installDate.txt" # Get install date
            $installDate = [DateTime]$installDate
            $today = Get-Date
            $today = [DateTime]$today
            $days = 30 - ($today - $installDate).Days
            ($using:ref_buttonUpdateNotePerformer).Value.Text = "Update NotePerformer (Remains $days days)"
        }
        else {
            ($using:ref_buttonUpdateNotePerformer).Value.Text = "NotePerformer is OUTDATED, Click to update it"
            ($using:ref_buttonUpdateNotePerformer).Value.ForeColor = [System.Drawing.Color]::DarkRed
        }
    } -ArgumentList $url, $npInstallPath
}

# --------------------------------------- #
# | Function to Launch Dorico With NPPE | #
# --------------------------------------- #
function LaunchDoricoWithNPPE() {
    $ButtonLaunchDoricoWithNPPE.Text = "Dorico + NPPE is running..."
    Start-Process -FilePath $doricoInstallPath
    Start-Process -FilePath "$npInstallPath\NotePerformer Playback Engines\NotePerformer Playback Engines.exe"
    Start-Sleep -Seconds 20 # Wait for Dorico to launch

    $processName = "Dorico5"

    # Start a background job to monitor the Dorico process
    $ref_buttonLaunchDoricoWithNPPE = Get-Variable ButtonLaunchDoricoWithNPPE
    $ref_buttonLaunchDorico = Get-Variable ButtonLaunchDorico
    Start-ThreadJob {
        param($processName)

        # set variable with 59 minutes in seconds
        $timeOut = 3540


        # Continuously check if the process is running
        while (Get-Process -Name $processName -ErrorAction SilentlyContinue || $timeOut -gt 0) {
            # display time remaining in minutes and seconds
            $minutes = [math]::Floor($timeOut / 60)
            $seconds = $timeOut % 60
            $timeLeft = "Trial time left: ${minutes}:${seconds}"
            ($using:ref_buttonLaunchDoricoWithNPPE).Value.Text = $timeLeft
            $timeOut -= 1
            Start-Sleep -Seconds 1 # Check every second
        }

        # TODO : Check timeOut and save current file, display a message box if timeOut is 0

        # Once the process stops, close VSTAudioEngine5
        $vstProcessName = "VSTAudioEngine5"
        $vstProcess = Get-Process -Name $vstProcessName -ErrorAction SilentlyContinue
        if ($vstProcess) {
            Stop-Process -Name $vstProcessName -ErrorAction SilentlyContinue
        }

        #  Once the process stops, close NotePerformer Playback Engines
        $npeProcessName = "NotePerformer Playback Engines"
        $npeProcess = Get-Process -Name $npeProcessName -ErrorAction SilentlyContinue
        if ($npeProcess) {
            Stop-Process -Name $npeProcessName -ErrorAction SilentlyContinue
        }

        ($using:ref_buttonLaunchDoricoWithNPPE).Value.Text = "Launch Dorico + NPPE"
        ($using:ref_buttonLaunchDorico).Value.Enabled = $true
        ($using:ref_buttonLaunchDoricoWithNPPE).Value.Enabled = $true


    } -ArgumentList $processName
}

# ----------------------------- #
# | Function to Launch Dorico | #
# ----------------------------- #
function LaunchDorico() {
    $ButtonLaunchDorico.Text = "Dorico is running..."
    Start-Process -FilePath $doricoInstallPath
    Start-Sleep -Seconds 20 # Wait for Dorico to launch

    $processName = "Dorico5"

    # Start a background job to monitor the Dorico process
    $ref_buttonLaunchDoricoWithNPPE = Get-Variable ButtonLaunchDoricoWithNPPE
    $ref_buttonLaunchDorico = Get-Variable ButtonLaunchDorico
    Start-ThreadJob {
        param($processName)

        # set variable with 59 minutes in seconds
        $timeOut = 3540

        # Continuously check if the process is running
        while (Get-Process -Name $processName -ErrorAction SilentlyContinue || $timeOut -gt 0) {
            # display time remaining in minutes and seconds
            $minutes = [math]::Floor($timeOut / 60)
            $seconds = $timeOut % 60
            $timeLeft = "Trial time left: ${minutes}:${seconds}"
            ($using:ref_buttonLaunchDorico).Value.Text = $timeLeft
            $timeOut -= 1
            Start-Sleep -Seconds 1 # Check every second
        }

        # TODO : Check timeOut and save current file, display a message box if timeOut is 0

        # Once the process stops, close VSTAudioEngine5
        $vstProcessName = "VSTAudioEngine5"
        $vstProcess = Get-Process -Name $vstProcessName -ErrorAction SilentlyContinue
        if ($vstProcess) {
            Stop-Process -Name $vstProcessName -ErrorAction SilentlyContinue
        }

        ($using:ref_buttonLaunchDorico).Value.Text = "Launch Dorico"
        ($using:ref_buttonLaunchDorico).Value.Enabled = $true
        ($using:ref_buttonLaunchDoricoWithNPPE).Value.Enabled = $true

    } -ArgumentList $processName
}

# ------------------------------------ #
# | Force reinstall NP if trial done | #
# ------------------------------------ #
if (Test-Path "$npInstallPath\installDate.txt") {
    # Check if install date file exists
    # check if install date is lower than 30 days
    $installDate = Get-Content -Path "$npInstallPath\installDate.txt" # Get install date
    $installDate = [DateTime]$installDate
    $today = Get-Date
    $today = [DateTime]$today
    $days = ($today - $installDate).Days
    if ($days -lt 30) {
        # If install date is lower than 30 days, launch Dorico and exit
    }
    else {
        [void] [System.Windows.MessageBox]::Show( "Note Performer are going to be reinstalled ", "Note Performer Assistant", "OK", "Information" )
        ReinstallNotePerformer
    }
}

# --------------- #
# | MAIN WINDOW | #
# --------------- #
Add-Type -assembly System.Windows.Forms
Add-Type -AssemblyName PresentationFramework
$main_form = New-Object System.Windows.Forms.Form
$main_form.Text = 'Note Perfomer Assistant'
$main_form.Width = 400
$main_form.Height = 450
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
$logoNP.Location = New-Object System.Drawing.Size(0, 10)
$logoNP.Image = [System.Drawing.Image]::FromFile("$PSScriptRoot\Resources\NP_Logo.png")
$logoNP.SizeMode = 'Zoom'
$main_form.Controls.Add($logoNP)

# -------------------------------- #
# | BUTTON UPDATE NOTE PERFORMER | #
# -------------------------------- #
$ButtonUpdateNotePerformer = New-Object System.Windows.Forms.Button
$ButtonUpdateNotePerformer.Location = New-Object System.Drawing.Size(75, 130)
$ButtonUpdateNotePerformer.Size = New-Object System.Drawing.Size(250, 23)
if (Test-Path "$npInstallPath\installDate.txt") {
    $installDate = Get-Content -Path "$npInstallPath\installDate.txt" # Get install date
    $installDate = [DateTime]$installDate
    $today = Get-Date
    $today = [DateTime]$today
    $days = 30 - ($today - $installDate).Days
    $ButtonUpdateNotePerformer.Text = "Update NotePerformer (Remains $days days)"
}
else {
    $ButtonUpdateNotePerformer.Text = "NotePerformer is OUTDATED, Click to update it"
    $ButtonUpdateNotePerformer.ForeColor = [System.Drawing.Color]::DarkRed
}
$main_form.Controls.Add($ButtonUpdateNotePerformer)
$ButtonUpdateNotePerformer.Add_Click(
    {
        $ButtonUpdateNotePerformer.ForeColor = [System.Drawing.Color]::Black
        ReinstallNotePerformer
    }
)

# ---------------------- #
# | BUTTON LAUNCH NPPE | #
# ---------------------- #
$ButtonLaunchNPPE = New-Object System.Windows.Forms.Button
$ButtonLaunchNPPE.Location = New-Object System.Drawing.Size(75, 160)
$ButtonLaunchNPPE.Size = New-Object System.Drawing.Size(250, 23)
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
$horizontalBar.Location = New-Object System.Drawing.Size(0, 200)
$horizontalBar.Size = New-Object System.Drawing.Size(400, 2)
$horizontalBar.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$main_form.Controls.Add($horizontalBar)

# --------------- #
# | LOGO DORICO | #
# --------------- #
$logoD = New-Object System.Windows.Forms.PictureBox
$logoD.Width = 400
$logoD.Height = 100
$logoD.Location = New-Object System.Drawing.Size(0, 220)
$logoD.Image = [System.Drawing.Image]::FromFile("$PSScriptRoot\Resources\D_Logo.png")
$logoD.SizeMode = 'Zoom'
$main_form.Controls.Add($logoD)

# ------------------------ #
# | BUTTON LAUNCH DORICO | #
# ------------------------ #
$ButtonLaunchDorico = New-Object System.Windows.Forms.Button
$ButtonLaunchDorico.Location = New-Object System.Drawing.Size(75, 340)
$ButtonLaunchDorico.Size = New-Object System.Drawing.Size(250, 23)
$ButtonLaunchDorico.Text = "Launch Dorico"
$main_form.Controls.Add($ButtonLaunchDorico)
$ButtonLaunchDorico.Add_Click(
    {
        $ButtonLaunchDoricoWithNPPE.Enabled = $false
        $ButtonLaunchDorico.Enabled = $false
        LaunchDorico
    }
)

# ---------------------------------- #
# | BUTTON LAUNCH DORICO WITH NPPE | #
# ---------------------------------- #
$ButtonLaunchDoricoWithNPPE = New-Object System.Windows.Forms.Button
$ButtonLaunchDoricoWithNPPE.Location = New-Object System.Drawing.Size(75, 370)
$ButtonLaunchDoricoWithNPPE.Size = New-Object System.Drawing.Size(250, 23)
$ButtonLaunchDoricoWithNPPE.Text = "Launch Dorico + NPPE"
$main_form.Controls.Add($ButtonLaunchDoricoWithNPPE)
$ButtonLaunchDoricoWithNPPE.Add_Click(
    {
        $ButtonLaunchDoricoWithNPPE.Enabled = $false
        $ButtonLaunchDorico.Enabled = $false
        LaunchDoricoWithNPPE
    }
)

$main_form.ShowDialog()