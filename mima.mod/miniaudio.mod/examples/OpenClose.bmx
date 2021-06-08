SuperStrict
Import mima.miniaudio

Graphics 800,600
' Setup of the device:
Global MiniAudio:TMiniAudio=New TMiniAudio
MiniAudio.OpenDevice( MiniAudio.PLAYBACK, Miniaudio.FORMAT_S16, 2, 48000, MyCallBack)

MiniAudio.StartDevice()
Repeat

Until AppTerminate()
Miniaudio.CloseDevice()
End 

Function MyCallBack(a:Byte Ptr, PlayBuffer:Short Ptr, RecordingBuffer:Short Ptr, Frames%)
	' do something with the samples
End Function 


