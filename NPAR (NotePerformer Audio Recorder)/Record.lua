-- Show info in console
print ("Record.lua")
print ("Record audio from loopback device")

----------------
-- FOR FFMPEG --
----------------
-- Check if ffmpeg is in the path environment variable
local ffmpegOK = true
local ffmpegInPath = os.execute("ffmpeg -version")
if ffmpegInPath == nil then
    -- ffmpeg.exe not found in path
    -- Check if the folder /ffmpeg exists
    local ffmpegPath = ".\\ffmpeg\\ffmpeg.exe"
    local ffmpegExists = io.open(ffmpegPath, "r")
    if ffmpegExists == nil then
        -- ffmpeg.exe not found in the folder /ffmpeg
        ffmpegOK = false
        return
    else
        -- ffmpeg.exe found in the folder /ffmpeg
        ffmpegOK = true
    end
    return
else
    -- ffmpeg.exe found in path
    ffmpegOK = true
end

---------------------------------------
-- FOR NPA (NotePerformer Assistant) --
---------------------------------------
local scriptPath = "& ./NotePerformer_Audio_Recorder.ps1"
local luaPath = debug.getinfo(1).source:match("@?(.*/)")
local command = "start powershell.exe -ExecutionPolicy Bypass -Command \"cd '" .. luaPath .. "' ; " .. scriptPath .. " true\""
--execute command but don't wait for it to finish
os.execute(command)

----------------
-- FOR DORICO --
----------------
if ffmpegOK then
    -- Create pipe who wait for NPAR to connect (finish initialisation)
    local scriptCommand = "(New-Object IO.Pipes.NamedPipeServerStream('npar', 'Out')).WaitForConnection()"
    local command = "powershell.exe -Command \"cd '" .. luaPath .. "' ; " .. scriptCommand .. "\""
    --execute command but don't wait for it to finish
    os.execute(command)

    local app=DoApp.DoApp()
    -- Impossible for the moment to get duration of the flow or to get play button state
    app:doCommand([[Play.SetPlayheadToFlowStart]])
    app:doCommand([[Play.StartOrStop?Set=true]])
end