SuperStrict
Import mima.miniaudio

Graphics 800,400

' Setup of the device:
Global MiniAudio:TMiniAudio=New TMiniAudio


Global Source:ExTAudioSample = MiniAudio.LoadExtendedAudioSample("TestABC.ogg", MiniAudio.FORMAT_S32)
Print Source.format
Print Source.Hertz
Print Source.channels
MiniAudio.OpenDevice( Miniaudio.PLAYBACK, Source.Format, Source.Channels, Source.Hertz, MyCallBack)


' this will be 32bit signed INT:
Global EchoBank:TBank=CreateBank(Source.Capacity*4+20000)
Global EchoRAM:Int Ptr = EchoBank.lock()

' now start it:
MiniAudio.StartDevice()

Global ReadPointer:Int , Reverb%
SetClsColor 255,255,255
Repeat
    Cls
		SetColor 1,55,55
		DrawRect 5,5,790,390
        SetColor 255,255,255
        DrawText "MouseHit to switch on reverb on  the narrator ABC", 100,100
		If Reverb
			DrawText "Reverb=ON", 100,130
		Else
			DrawText "Reverb=OFF", 100,130
		EndIf 
		If MouseHit(1)
			reverb=1-reverb
		EndIf 
    Flip
Until AppTerminate()
Miniaudio.CloseDevice()
End 



Function MyCallBack(a%, PlayBuffer:Int Ptr, RecordingBuffer:Int Ptr, Frames:Int)
	If ReadPointer>Source.Frames-Frames Then ReadPointer=0

	' here you manipulate the sound:
	For Local i:Int=0 To Frames-1
		Local now%=ReadPointer+ i
		Local Value:Int =  Source.SampleInt[now] 
		Value =  Value + EchoRAM[now]
		CalculateReverb now, Value
		PlayBuffer[i]= Value
	Next
    ReadPointer=ReadPointer + Frames
End Function 



Function CalculateReverb(when:Int, value:Float)
	If reverb=0 Return 

	Local f#=0.69, distance#=1000, df#=0.83, Early%=2000
	value=Value*0.17 + EchoRAM[when]/20
	For Local j%=0 To 9
		value    = value*f		
		distance = distance*df
		Local later:Int = Int(when+Early+ distance)
		EchoRAM[later]  = EchoRAM[later] + value
	Next
	EchoRAM[when]=0 
End Function 

