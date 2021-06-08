SuperStrict
Import mima.miniaudio

' Setup of the device:
Global MiniAudio:TMiniAudio=New TMiniAudio

Local i:Int
Print   "Capturek-Devices:"

For Local DeviceName:String= EachIn MiniAudio.CaptureDevices()
	Print  "ID=" + i + ": " + DeviceName
	i=i+1
Next 

' keep default playback device, but use capture device ID=1:
Miniaudio.SelectDevices(-1,1)
MiniAudio.OpenDevice( MiniAudio.CAPTURE, Miniaudio.FORMAT_S16, 1, 48000, MyCallBack)
