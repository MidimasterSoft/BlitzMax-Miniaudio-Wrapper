SuperStrict
Import mima.miniaudio

Graphics 400,200
Local MySound:TSound

' Setup of the device:
Global MiniAudio:TMiniAudio = New TMiniAudio

Local MySample:TAudioSample = MiniAudio.LoadAudioSample("TestABC.mp3")
MySound:TSound=LoadSound(MySample)

' or also possible direct:
'MySound = MiniAudio.Load_MP3("TestABC.mp3")


PlaySound MySound

Repeat
	DrawText "Open and Play MP3 file",100,100
	Flip 
Until AppTerminate()
End 
