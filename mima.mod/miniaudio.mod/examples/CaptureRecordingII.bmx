' example to demonstrate capturing STEREO audio with miniaudio
' and transfering datas to the NEW extended ExTAudioSample type
' Quality is FORMAT_F32 means best quality and performance
' when recording is stopped the ExTAudioSample is saved as a WAV-file

SuperStrict
Import mima.miniaudio


Graphics 400,300

' Setup of the device:
Const    HERTZ:Int = 48000
Const CHANNELS:Int = 2

Global MiniAudio:TMiniAudio=New TMiniAudio
'if comment out this line capture will take the default capture device:
Miniaudio.SelectDevices(0,1)

Global Recording:ExTAudioSample = ExTAudioSample.Create(HERTZ*61,  HERTZ, MiniAudio.FORMAT_F32, CHANNELS)
Print Recording.format
Print Recording.Hertz
Print Recording.channels
MiniAudio.OpenDevice( MiniAudio.DUPLEX, Miniaudio.FORMAT_F32, CHANNELS, HERTZ, MyCallBack)


Global WritePointer:Int

Global RecordMode%

SetClsColor 255,255,255
Repeat
    Cls
		DrawButtons
		If MouseHit(1)
			RecordMode=1-RecordMode
			If RecordMode=0
				Print "PLAY"
				MiniAudio.StopDevice()
				MiniAudio.SaveExTAudioSample "MySong.WAV", Recording

			Else
				Print "RECORD"
				Recording.Clear
				WritePointer=0
				MiniAudio.StartDevice()
			EndIf 
		EndIf  
    Flip 0
Until AppTerminate()
Miniaudio.CloseDevice()
End 


Function MyCallBack(a%, PlayBackBuffer:Float Ptr, RecordingBuffer:Float Ptr, Frames%)
	' cares about not to overrun the ExTAudioSample-size:
	If WritePointer > (HERTZ*60*CHANNELS) Then WritePointer=0

	For Local i:Int=0 To frames-1 
		' fetch the sample:
		Local valueLeft:Float   = RecordingBuffer[i]
		Local valueRight:Float  = RecordingBuffer[i+1]
		
		' duplx it immediately:
		PlayBackBuffer[i]   = valueLeft
		PlayBackBuffer[i+1] = valueRight
		
		'and transfer it to the TAudioSample:
		Recording.SampleFloat[WritePointer+i]   = valueLeft
		Recording.SampleFloat[WritePointer+i+1] = valueRight
	Next
    WritePointer = WritePointer + Frames*CHANNELS

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

