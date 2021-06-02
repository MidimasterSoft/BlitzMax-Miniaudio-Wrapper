SuperStrict
Import mima.miniaudio


Graphics 400,300

' Setup of the device:
Const  HERTZ:Int = 48000

Global MiniAudio:TMiniAudio=New TMiniAudio
MiniAudio.GetDevice( MiniAudio.DUPLEX, Miniaudio.FORMAT_S16, 1, HERTZ, MyCallBack)


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


Function MyCallBack(a%, PlayBackBuffer:Short Ptr, RecordingBuffer:Short Ptr, Frames%)
	For Local i%=0 To frames-1
		PlayBackBuffer[i]=RecordingBuffer[i]
		SoundBank.PokeShort(WritePointer+2*i , RecordingBuffer[i])
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
				For Local i%=0 To (HERTZ*60) Step 4
					SoundBank.PokeInt(i,0)
				Next 				
End Function