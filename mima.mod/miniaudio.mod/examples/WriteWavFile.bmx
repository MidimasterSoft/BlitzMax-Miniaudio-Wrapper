' save_wav_file.bmx
SuperStrict
Import mima.miniaudio
' Setup of the device:
Global MiniAudio:TMiniAudio=New TMiniAudio

Global Stream:MMStreamID= MiniAudio.OpenWavFile("test.wav" , Miniaudio.FORMAT_F32 , 3 , 44100 )
Print "StreamID=" + Stream.Id
Global actChannel%, time%, Part%
While Part<10
	If time<MilliSecs()
		time = MilliSecs() + 500
		Part=Part+1
		PartRecord
		Print "recording part no. " + Part
	EndIf 
	Delay 100
Wend 
MiniAudio.CloseWavFile(Stream )
End 

Function PartRecord()
	actChannel = (actChannel+1) Mod 3 ' only for demonstration of 3 channels

	Local Bank:TBank=CreateBank(5000*4*3+12)    ' 5000frames * 32bit * 3tracks +securitybuffer
	Global FrameLength% = 4*3  ' 32bit*3tracks
	For Local I%=0 To 4999
		Local pos:Int=i*FrameLength
		Local v#=Sin(i)/2
		Bank.PokeFloat(Pos+actChannel*4, v) '4=32bit
	Next 
	MiniAudio.WriteWavFile(Stream, Bank, 5000)
End Function 
