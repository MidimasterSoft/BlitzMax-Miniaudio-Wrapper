' absolute minimum example to demonstrate capturing audio with miniaudio
' This code does not do anything usefull, but is perfect to test
' if MiniAudio is runable on your computer
SuperStrict
Import mima.miniaudio
Graphics 400,300

'define the device:
Global MiniAudio:TMiniAudio = New TMiniAudio
MiniAudio.OpenDevice( MiniAudio.CAPTURE, Miniaudio.FORMAT_S16, 1, 48000, MyCallBack)
Global MyRam:Int[9999]

' main loop:
Repeat
    Flip 1
Until AppTerminate()
Miniaudio.CloseDevice()
End 

' transfer miniaudio data to my INTEGER array:
Function MyCallBack(a:Int, PlayBackBuffer:Short Ptr, RecordingBuffer:Short Ptr, Frames:Int)
	For Local i:Int=0 Until Frames
		Local value:Short   = RecordingBuffer[i]
		MyRAM[i] = value
	Next
End Function 
