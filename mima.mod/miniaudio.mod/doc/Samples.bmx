SuperStrict
Import mima.miniaudio

Global MiniAudio:TMiniAudio=New TMiniAudio

Global MySample:ExTAudioSample = MiniAudio.LoadExtendedAudioSample("TestABC.ogg", MiniAudio.FORMAT_F32)

'IMPORTANT: Pointer to Samples must have the correct format. Here: Float Ptr 
Global SampleRAM:Float Ptr= MySample.Samples()
...
MiniAudio.OpenDevice( MiniAudio.PLAYBACK, MiniAudio.FORMAT_F32, 1, 48000, MyCallBack)
...

Function MyCallBack(a%, PlayBuffer:Float Ptr, RecordingBuffer:Short Ptr, Frames:Int)
	For Local i:Int=0 To frames-1
		PlayBuffer[i] = SampleRAM[i+ReadPointer]
		Next
	Next
	ReadPointer = ReadPointer + Frames 
End Function 
