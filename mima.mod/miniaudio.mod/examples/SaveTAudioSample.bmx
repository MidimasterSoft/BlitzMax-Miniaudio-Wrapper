' save_taudiosample.bmx
SuperStrict
Import mima.miniaudio
' Setup of the device:
Global MiniAudio:TMiniAudio = New TMiniAudio

Global Sample:TAudioSample = LoadAudioSample("TestABC.ogg")

MiniAudio.SaveTAudioSample("TestABC.wav", Sample)

End 

