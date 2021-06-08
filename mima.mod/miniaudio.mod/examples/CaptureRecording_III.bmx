' example to demonstrate MULTI-CHANNEL capturing audio with miniaudio
' and transfering datas to the NEW extended ExTAudioSample type
' Quality is FORMAT_S32 only for demonstration
' the DUPLEX will reduce the 8 channels to 2 "manually"
' when recording is stopped the ExTAudioSample is saved as a 16bit WAV-file
' this make it necessary to convert from S32 to S16
SuperStrict
Import mima.miniaudio


Graphics 400,300

' Setup of the device:
Const    HERTZ:Int = 44100
Const CHANNELS:Int = 8

Global MiniAudio:TMiniAudio=New TMiniAudio

'only hardware devices can capture 8 channels. So connect your USB-device and select it with its ID:
Print   "Capture-Devices:"
Local i:Int
For Local DeviceName:String= EachIn MiniAudio.CaptureDevices()
	Print  "ID=" + i + ": " + DeviceName
	i=i+1
Next
Local MyUsbDevice:Int=1
Miniaudio.SelectDevices(-1,MyUsbDevice)


Global Recording:ExTAudioSample = ExTAudioSample.Create(HERTZ*61,  HERTZ, MiniAudio.FORMAT_S32, CHANNELS)
Print Recording.format
Print Recording.Hertz
Print Recording.channels
' use OpenDevice_II when Playback and Capture needs different parameters:
MiniAudio.OpenDevice_II( MiniAudio.DUPLEX, Miniaudio.FORMAT_S32, 2, Miniaudio.FORMAT_S32, CHANNELS, HERTZ, MyCallBack)


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
				'this would easily save the wav with 32bit-INT:
				MiniAudio.SaveExTAudioSample "MySong.WAV", Recording
				
				' but we can also change the format during saving:
				Local StreamID:MMStreamID = MiniAudio.OpenWavFile("My16bitsong.Wav" , Miniaudio.FORMAT_S16, CHANNELS, HERTZ)
				MiniAudio.WriteWavFile StreamID, Recording.SampleInt, Recording.Frames, Recording.Format, CHANNELS, HERTZ
				MiniAudio.CloseWavfile StreamID
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


Function MyCallBack(a%, PlayBackBuffer:Int Ptr, RecordingBuffer:Int Ptr, Frames:Int)
	If WritePointer > (HERTZ*60*CHANNELS) Then WritePointer=0

	For Local i:Int=0 To Frames-1
		For Local j:Int=0 To CHANNELS-1
			' fetch the samples:
			Local value:Int = RecordingBuffer[i*CHANNELS + j]
			
			'and transfer it to the TAudioSample:
			Recording.SampleInt[WritePointer+i*CHANNELS + j] = value		
		Next 
		' now route the 8 capture channels to only 2 playbak channels as you like:
		' to prevent Distortion we divide each sample volume by 2
		Local valueL:Int = RecordingBuffer[8*i+0]/2 + RecordingBuffer[8*i+1]/2 + RecordingBuffer[8*i+2]/2 + RecordingBuffer[8*i+3]/2
		Local valueR:Int = RecordingBuffer[8*i+4]/2 + RecordingBuffer[8*i+5]/2 + RecordingBuffer[8*i+6]/2 + RecordingBuffer[8*i+7]/2
		PlayBackBuffer[2*i+0] = valueL
		PlayBackBuffer[2*i+1] = valueR
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

