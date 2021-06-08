SuperStrict
Import mima.miniaudio

Graphics 800,600
Const CHANNELS:Int=2
' Setup of the device:
Global MiniAudio:TMiniAudio=New TMiniAudio
MiniAudio.OpenDevice( MiniAudio.PLAYBACK, Miniaudio.FORMAT_S16, CHANNELS, 48000, MyCallBack)


' now start it:
MiniAudio.StartDevice()
 
Global Zeit%=MilliSecs()
Global Arc1:Double,  Arc2:Double

Repeat
	Cls 
        DrawText "Move your Mouse in X-dir to change the SINUS in the LEFT speaker", 100,100
        DrawText "Move your Mouse in y-dir to change the SINUS in the RIGHT speaker", 100,130
		DrawText "Memory allocated=" + GCMemAlloced(), 100,160
		DrawText "time running:" + (MilliSecs()-zeit),100,190
		Delay 0
	Flip 1
Until AppTerminate()
Miniaudio.CloseDevice()
End 


Function MyCallBack(a%, PlayBuffer:Short Ptr, RecordingBuffer:Short Ptr, Frames%)
	For Local i:Int=0 To Frames-1
        arc1=arc1+MouseX()/100.0+1
        arc2=arc2+MouseY()/100.0+1
 	   PlayBuffer[CHANNELS*i+0] = Int(Sin(arc1)*10000.0)
	   PlayBuffer[CHANNELS*i+1] = Int(Sin(arc2)*10000.0)
	Next 
End Function 
