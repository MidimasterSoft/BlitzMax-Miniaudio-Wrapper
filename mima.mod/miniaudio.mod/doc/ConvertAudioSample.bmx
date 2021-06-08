SuperStrict
Import mima.miniaudio

' Setup of the device:
Global MiniAudio:TMiniAudio=New TMiniAudio

Local Source:TAudioSample=LoadAudioSample("TestABC.ogg")

Global Target:ExTAudioSample
Target= MiniAudio.ConvertAudioSample(Source, Miniaudio.FORMAT_F32, 1, 12000)

'show 500 samples in old and new format:

Local SourcePointer: Short Ptr = Source.Samples
Local TargetPointer: Float Ptr = Target.Samples
For Local i%=1000 To 1500
	Print  i + ".Sample  Source:" +  SourcePointer[i] + "-->" + TargetPointer[i]
Next 
End 




