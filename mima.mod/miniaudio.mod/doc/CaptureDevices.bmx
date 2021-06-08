SuperStrict
Import mima.miniaudio

' Setup of the device:
Global MiniAudio:TMiniAudio=New TMiniAudio

Local i:Int
Print   "Capture-Devices:"

For Local DeviceName:String= EachIn MiniAudio.CaptureDevices()
	Print  "ID=" + i + ": " + DeviceName
	i=i+1
Next 
