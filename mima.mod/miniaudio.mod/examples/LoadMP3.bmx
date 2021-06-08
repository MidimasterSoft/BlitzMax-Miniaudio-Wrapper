' this works also for MP3, OGG, FLAC and WAV as long as they are MONO or STEREO
' This works also if the file has a 32bit-INT or 32bit-FLOAT format. 
' Those will be converted to BlitzMax Standard SF_MONO16LE or SF_STEREO16LE automatic.

SuperStrict
Import mima.miniaudio

Graphics 400,200
Local MySound:TSound

' Setup of the device:
Global MiniAudio:TMiniAudio = New TMiniAudio

Local MySample:TAudioSample = MiniAudio.LoadAudioSample("TestABC.mp3")
MySound:TSound=LoadSound(MySample)

' or also possible direct:
'MySound = MiniAudio.LoadSound("TestABC.mp3")


PlaySound MySound

Repeat
	DrawText "Open and Play MP3 file",100,100
	Flip 
Until AppTerminate()
End 
