'Three examples for Callbacks:

'Example I: only playback

Import mima.miniaudio

' Setup of the device:
Global MiniAudio:TMiniAudio=New TMiniAudio
MiniAudio.GetDevice( MiniAudio.PLAYBACK, Miniaudio.FORMAT_S16, 1, 48000, MyCallBack_I)

' now start it:
MiniAudio.StartDevice()
Repeat
	Flip 1
Until AppTerminate()
Miniaudio.KillDevice()
End 

Function MyCallBack_I(void:Byte Ptr, PlayBuffer:Short Ptr, RecordingBuffer:Short Ptr, Frames%)
	For Local i:Int=0 To Frames-1
		PlayBuffer[i*2] = Rand(-32000,+32000)
	Next 
End Function 

__________________________________________________________________________________

'Example II: only capture:

Import mima.miniaudio

' Setup of the device:
Global MiniAudio:TMiniAudio=New TMiniAudio
MiniAudio.GetDevice( MiniAudio.CAPTURE, Miniaudio.FORMAT_S16, 1, 48000, MyCallBack_II)

Global Source:TAudioSample=CreateAudioSample( HERTZ*60*10,  HERTZ, SF_MONO16LE) '10seconds
Global SoundBank:TBank=CreateStaticBank(Source.Samples, Source.Length)
Global WritePointer:Int

' now start it:
MiniAudio.StartDevice()
Repeat
	Flip 1
Until AppTerminate()
Miniaudio.KillDevice()
End 


Function MyCallBack_II(void:Byte Ptr, PlayBuffer:Short Ptr, RecordingBuffer:Short Ptr, Frames%)
	For Local i:Int=0 To Frames-1
		SoundBank.PokeShort(WritePointer+i*2 , RecordingBuffer[i*2])
	Next 
	WritePointer=WritePointer + Frames*2
End Function 


____________________________________________________________________________________

'Example III: Duplex:

Import mima.miniaudio

' Setup of the device:
Global MiniAudio:TMiniAudio=New TMiniAudio
MiniAudio.GetDevice( MiniAudio.DUPLEX, Miniaudio.FORMAT_S16, 1, 48000, MyCallBack_III)

' now start it:
MiniAudio.StartDevice()
Repeat
	Flip 1
Until AppTerminate()
Miniaudio.KillDevice()
End 


Function MyCallBack(void:Byte Ptr, PlayBuffer:Short Ptr, RecordingBuffer:Short Ptr, Frames%)
	For Local i:Int=0 To Frames-1
		PlayBuffer[i*2] = RecordingBuffer[i*2]
	Next 
End Function 


