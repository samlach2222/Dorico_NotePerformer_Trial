-- Show info in console

print ("Record.lua")
print ("Record audio from loopback device")

-- Execute record script

local scriptPath = "ABSOLUTE_PATh_TO_RECORD_PS1\\Record.ps1"
local command = "start powershell.exe -ExecutionPolicy Bypass -File " .. scriptPath

-- execute command but don't wait for it to finish

os.execute(command)

-- FOR DORICO -> START PLAYING SOUND

local app=DoApp.DoApp()
app:doCommand([[Play.StartOrStop?Set=true]])

