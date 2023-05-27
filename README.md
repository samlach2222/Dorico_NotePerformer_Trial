# Dorico_NotePerformer_Trial

## What is Dorico_NotePerformer_Trial ?

Dorico_NotePerformer_Trial helps user who use NotePerformer trial version. The aim is to allow people to auto_reinstall NotePerformer trial each 30 days while launching Dorico and allow users to record sound from NotePerformer trial.
Dont forget to change lines `21` and `22` in the powershell script

## LAUNCH DORICO + NOTEPERFORMER

To launch Dorico and automatically reinstall NotePerformer each 30 days you just have to launch the Powershell 7 file like this `.\Dorico.ps1` 

## RECORD SOUND TO WAV

1. Open `_CODE/ApplicationLoopback.sln` in Visual Studio (rebase the project if necessary)
2. Select `Release` and right clic on Project then `Generate Project`
3. Move generated project in Release folder to `RECORD SOUND TO WAV` folder
4. Move `Record.lua` to `C:\Users\<USERNAME>\AppData\Roaming\Steinberg\Dorico 4\Script Plug-ins` (can also be Dorico 5)
5. Change line `8` of `Record.lua`
6. In Dorico, you can now in `script` panel launch the recorder 
