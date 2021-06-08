SuperStrict
Import mima.miniaudio

Graphics 800,600

' Setup of the device:
Global MiniAudio:TMiniAudio=New TMiniAudio
MiniAudio.OpenDevice( MiniAudio.PLAYBACK, Miniaudio.FORMAT_S16, 1, 48000, MyCallBack)

' now start it:
MiniAudio.StartDevice()

Global NOISE%=0, Zeit%=MilliSecs()
Repeat
	Cls 
	DrawText "listen to some crackles and then press the mouse once ",100,100
	DrawText "in the same rhythm. The time difference youz hear is the latency ",100,130
	If MouseDown(1)
		If NOISE=0
			NOISE=1
		EndIf 
	Else 
		NOISE=0
	EndIf 
	Delay 1
	Flip 
Until AppTerminate()
Miniaudio.CloseDevice()
End 


Function MyCallBack(a%, PlayBuffer:Short Ptr, RecordingBuffer:Short Ptr, Frames%)
	' here you manipulate the sound:
	If NOISE=1 
		NOISE=2
		For Local i%=0 To frames-1
			PlayBuffer[i]=Rand(-32000,+32000)
		Next 
	ElseIf Zeit<MilliSecs()
		zeit=Zeit+1000
		For Local i%=0 To frames-1
			PlayBuffer[i]=Rand(-32000,+32000)
		Next 
	EndIf 
End Function 


