# BlitzMax-Miniaudio-Wrapper 1.25 (2021-06-08)
a binding/wrapper for the audio library Miniaudio to the language BlitzMax  

The wrapper enables to use the C-library miniaudio (https://github.com/mackron/miniaudio) in the BASIC language BlitzMax (https://blitzmax.org/)

at the moment it is in Beta-state. 

There is already a manual here: https://www.syntaxbomb.com/index.php/topic,8419.0.html 

Now you can use the repository to download the whole module

And a discussion forum here: https://www.syntaxbomb.com/index.php/topic,8388.0.html

Until MiniAudio V0.10.36 will be published we still included a modified version of V 0.10.35

## Example

Here is a minimal example. It opens the device and makes some noise
```
Import mima.miniaudio

' Setup of the device:
Global MiniAudio:TMiniAudio=New TMiniAudio
MiniAudio.GetDevice( MiniAudio.PLAYBACK, Miniaudio.FORMAT_S16, 1, 48000, MyCallBack)

' now start it:
MiniAudio.StartDevice()

'your main loop:
Repeat
	Flip 1
Until AppTerminate()

' free the device:
Miniaudio.KillDevice()
End 

'data aree delivered via a callback procedure:
Function MyCallBack(void:Byte Ptr, PlayBuffer:Short Ptr, RecordingBuffer:Short Ptr, Frames:Int)
	For Local i:Int=0 To Frames-1
		PlayBuffer[i] = Rand(-32000,+32000)
	Next 
End Function 


```


All these will move the next days to github.





