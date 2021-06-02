' example: loadAudioSample.bmx

Global MiniAudio:TMiniAudio=New TMiniAudio

Local MySample:TAudioSample = MiniAudio.LoadAudioSample("TestABC.flac")

Local MySound:TSound=LoadSound(MySample)
PlaySound MySound

