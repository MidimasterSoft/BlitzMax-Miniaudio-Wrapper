SuperStrict
Import mima.miniaudio


Graphics 400,300

' Setup of the device:
Const  HERTZ:Int = 48000

Global MiniAudio:TMiniAudio=New TMiniAudio
Miniaudio.SelectDevices(0,1)
'MiniAudio.GetDevice( MiniAudio.DUPLEX, Miniaudio.FORMAT_S16, 8, HERTZ, MyCallBack)
MiniAudio.GetDevice_II( MiniAudio.DUPLEX, Miniaudio.FORMAT_S32, 2, Miniaudio.FORMAT_S32, 8, HERTZ, MyCallBack)


Global Source:TAudioSample=CreateAudioSample( HERTZ*61,  HERTZ, SF_MONO16LE)  '60 seconds
Global SoundBank:TBank=CreateStaticBank(Source.Samples, Source.Length)

Global WritePointer:Int

Global RecordMode%, Audio:TChannel

Local Music:TSound =LoadSound(Source)
audio=PlaySound(music)

SetClsColor 255,255,255
Repeat
    Cls
		DrawButtons
		If MouseHit(1)
			RecordMode=1-RecordMode
			If RecordMode=0
				Print "PLAY"
				MiniAudio.StopDevice()
				Local s:TStream=WriteStream("noise.wav")
				For Local i%=0 To WritePointer/2
					s.WriteShort(Source.Samples[i*2])
				Next 
				CloseStream s 
				Local Music:TSound =LoadSound(Source)
				
				audio=PlaySound(music)
			Else
				Print "RECORD"
				ClearSample()
				StopChannel Audio
				WritePointer=0
				MiniAudio.StartDevice()
			EndIf 
		EndIf  
    Flip 0
Until AppTerminate()
Miniaudio.KillDevice()
End 


Function MyCallBack(a%, PlayBackBuffer:Int Ptr, RecordingBuffer:Int Ptr, Frames%)
	For Local i%=0 To frames-1
		Local valueL%=RecordingBuffer[8*i]+RecordingBuffer[8*i+1]+RecordingBuffer[8*i+2]+RecordingBuffer[8*i+3]
		Local valueR%=RecordingBuffer[8*i+7]+RecordingBuffer[8*i+7]'+RecordingBuffer[8*i+6]+RecordingBuffer[8*i+7]
		PlayBackBuffer[2*i]= valueR
		PlayBackBuffer[2*i+1]=valueR
		SoundBank.PokeShort(WritePointer+2*i , valueR/65536)
	Next
    WritePointer = (WritePointer + 2*Frames) Mod (HERTZ*60)
End Function 




Function DrawButtons()
		SetColor 1,55,55
		DrawRect 5,5,390,290
    
		SetColor 255,255,255
		DrawRect 100,200,100,40
 		DrawRect 250,200,100,40
       DrawText "AUDIO-RECORDER", 100,100
        DrawText "click Button to switch!", 100,260
		SetColor 111,111,111
		DrawRect 102,202,96,36
		DrawRect 252,202,96,36
		SetColor 255,255,255
		If RecordMode=1
			SetColor 155,55,55
			DrawRect 252,202,96,36
			 DrawText "recording....", 100,130
		Else 
			SetColor 55,155,55
			DrawRect 102,202,96,36
			 DrawText "Playback.... (or waiting)", 100,130
		EndIf 
		SetColor 255,255,255
		DrawText "PLAY",120,210
		DrawText "RECORD",270,210
End Function 


Function ClearSample()
Print soundbank.size() + " " + (HERTZ*60)
				For Local i%=0 To (HERTZ*60) Step 4
					SoundBank.PokeInt(i,0)
				Next 				
End Function