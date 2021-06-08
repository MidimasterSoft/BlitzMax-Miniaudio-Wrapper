SuperStrict
Import mima.miniaudio

' Setup of the device:
Global MiniAudio:TMiniAudio=New TMiniAudio

Local i:Int
Print   "Playback-Devices:"

For Local DeviceName:String= EachIn MiniAudio.PlaybackDevices()
	Print  "ID=" + i + ": " + DeviceName
	i=i+1
Next 
