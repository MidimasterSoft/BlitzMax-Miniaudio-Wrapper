SuperStrict
Import mima.miniaudio

Graphics 800,600

' Setup of the device:
Global MiniAudio:TMiniAudio=New TMiniAudio

Local Source:TAudioSample=LoadAudioSample("TestAbc.ogg")

Global ResultBank:TBank
ResultBank= MiniAudio.ConvertAudioSample(Source, Miniaudio.FORMAT_F32, 1, 12000)

'show 500 samples in old and new format:
For Local i%=1000 To 1500
	Print  i + ".Sample  Source:" +  SoundBank.PeekShort(i*2) + "-->" + Resultbank.PeekFloat(i*4)
Next 
End 




