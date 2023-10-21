# What is Dorico_NotePerformer_Trial ?

Dorico_NotePerformer_Trial helps user who use NotePerformer trial version. The aim is to allow people to auto_reinstall NotePerformer trial each 30 days while launching Dorico and allow users to record sound from NotePerformer trial.  
#### ⚠️ Dont forget to change lines **20** and **21** in `NPA\NotePerformer_Assistant.ps1`⚠️

# NPA (NotePerformer Assistant)

To launch Dorico and automatically reinstall NotePerformer each 30 days you just have to launch the Powershell 7 file like this `.\NotePerformer_Assistant.ps1` 

# NPAR (NotePerformer Audio Recorder

To record audio from NotePerfomer, you can use `NotePerformer_Audio_Recorder.ps1` like this : `.\NotePerformer_Audio_Recorder.ps1`.  
This script use PS Core and Windows WASAPI to record the audio of your computer and FFMPEG to update the gain of the record.
