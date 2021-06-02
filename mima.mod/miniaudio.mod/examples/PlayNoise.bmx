SuperStrict
Import mima.miniaudio

Graphics 800,600

' Setup of the device:
Global MiniAudio:TMiniAudio=New TMiniAudio
MiniAudio.GetDevice( MiniAudio.PLAYBACK, Miniaudio.FORMAT_S16, 1, 48000, MyCallBack)



' now start it:
MiniAudio.StartDevice()
Global NOISE%=0, Zeit%=MilliSecs()
Repeat
	Cls 
	DrawText "Kick LEFT MOUSE for NOISE",100,100
	If MouseDown(1)
			NOISE=1
	Else 
		NOISE=0
	EndIf 
	Flip 0
Until AppTerminate()
Miniaudio.KillDevice()
End 


Function MyCallBack(a%, PlayBuffer:Short Ptr, RecordingBuffer:Short Ptr, Frames%)
	' here you manipulate the sound:
	If NOISE=1 
		For Local i%=0 To frames-1
			PlayBuffer[i]=Rand(-32000,+32000)
		Next 
	EndIf 
End Function 