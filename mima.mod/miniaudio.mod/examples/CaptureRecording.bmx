' example to demonstrate capturing audio with miniaudio
' and transfering datas to the old BlitzMax TAudioSample type
' Quality is FORMAT_S16 means compatible quality to TAudioSample
' when recording is stopped the TAudioSample is converted into a TSound and played


SuperStrict
Import mima.miniaudio


Graphics 400,300

' Setup of the device:
Const  HERTZ:Int = 48000

Global MiniAudio:TMiniAudio=New TMiniAudio
'if comment out this line capture will take the default capture device:
Miniaudio.SelectDevices(0,1)
MiniAudio.OpenDevice( MiniAudio.DUPLEX, Miniaudio.FORMAT_S16, 1, HERTZ, MyCallBack)

' we need a TaudioSample for storing the incoming samples and a SHORT PTR to handle them
Global Recording:TAudioSample=CreateAudioSample( HERTZ*61,  HERTZ, SF_MONO16LE)  '60 seconds
Global RecordingRam:Short Ptr = Recording.Samples

Global WritePointer:Int

Global RecordMode%, Audio:TChannel

Local Music:TSound =LoadSound(Recording)
Audio=PlaySound(Music)

SetClsColor 255,255,255
Repeat
    Cls
		DrawButtons
		If MouseHit(1)
			RecordMode=1-RecordMode
			If RecordMode=0
				Print "PLAY"
				MiniAudio.StopDevice()
				Local Music:TSound =LoadSound(Recording)
				Audio=PlaySound(music)
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
Miniaudio.CloseDevice()
End 


Function MyCallBack(a%, PlayBackBuffer:Short Ptr, RecordingBuffer:Short Ptr, Frames:Int)
	' cares about not to overrun the TAudioSample-size:
	If WritePointer>HERTZ*60 Then WritePointer=0

	For Local i:Int=0 To frames-1
		' fetch the sample:
		Local value:Short   = RecordingBuffer[i]
		
		' duplx it immediately:
		PlayBackBuffer[i] = value
		
		'and transfer it to the TAudioSample:
		RecordingRAM[WritePointer+i] = value
	Next
    WritePointer = WritePointer + Frames
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
	For Local i:Int=0 To HERTZ*60
		RecordingRAM[i]=0
	Next 				
End Function