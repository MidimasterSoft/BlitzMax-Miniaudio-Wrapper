' save_wav_file.bmx
SuperStrict
Import mima.miniaudio
' Setup of the device:
Global MiniAudio:TMiniAudio=New TMiniAudio

Global Bank:TBank=CreateBank(44100*4*3*2)    ' 44.1kHz * 32bit * 3tracks * 2seconds
Global FrameLength% = 4*3  ' 32bit*3tracks

For Local I%=0 To (44100*2-FrameLength)
	Local pos:Int=i*FrameLength
	
	'track 1 (sinus):
	Local v#=Sin(i)/2
	Bank.PokeFloat(Pos+0, v)
	
	' track 2 (silence): 
	Bank.PokeFloat(Pos+4, 0)
	
	'track 3 (noise): 
	v=Rnd()-0.5
	Bank.PokeFloat(Pos+8, v) 
Next 

MiniAudio.SaveWavFile("capture.wav" , Bank , Miniaudio.FORMAT_F32 , 3 , 44100 , 44100*2)
End 
