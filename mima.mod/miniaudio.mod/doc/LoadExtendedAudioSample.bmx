SuperStrict
Import mima.miniaudio
Graphics 400,300
Global MiniAudio:TMiniAudio=New TMiniAudio

Global MySample:ExTAudioSample = MiniAudio.LoadExtendedAudioSample("TestABC.ogg", MiniAudio.FORMAT_F32)

'IMPORTANT: Pointer to Samples must have the correct format. Here: Float Ptr 
Global SampleRAM:Float Ptr= MySample.Samples()


Print MySample.format
Print MySample.Hertz
Print MySample.channels


MiniAudio.OpenDevice( MiniAudio.PLAYBACK, MySample.Format, MySample.Channels, MySample.Hertz, MyCallBack)
Global ReadPointer:Int

' now start it:
MiniAudio.StartDevice()
Repeat

	Flip 0
Until AppTerminate()
Miniaudio.CloseDevice()
End 


Function MyCallBack(a%, PlayBuffer:Float Ptr, RecordingBuffer:Short Ptr, Frames:Int)
	' here you manipulate the sound:
	Local Channels:Int = MySample.Channels
	For Local i:Int=0 To frames-1
		For Local j:Int=0 To channels-1
			PlayBuffer[i*Channels+j] = SampleRAM[((i+ReadPointer)*Channels+j)]
		Next
	Next
	ReadPointer = ReadPointer + Frames 
End Function 