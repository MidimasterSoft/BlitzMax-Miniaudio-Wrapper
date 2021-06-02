SuperStrict
Framework BRL.GlMax2D
Import Brl.standardio
Import brl.audiosample
Import brl.oggloader
Import brl.bank
Import mima.miniaudio

Graphics 800,400

' Setup of the device:
Global MiniAudio:TMiniAudio=New TMiniAudio
MiniAudio.GetDevice( MiniAudio.PLAYBACK, Miniaudio.FORMAT_S16, 1, 12000, MyCallBack)


Global Source:TAudioSample=LoadAudioSample("TestABC.ogg")
Global SoundBank:TBank=CreateStaticBank(Source.Samples, Source.Length*2)

' this will be 32bit signed INT:
Global EchoBank:TBank=CreateBank(Source.Length*4+20000)
' now start it:
MiniAudio.StartDevice()

Global Pointer:Int , Reverb%
SetClsColor 255,255,255
Repeat
    Cls
		SetColor 1,55,55
		DrawRect 5,5,790,390
        SetColor 255,255,255
        DrawText "MouseHit to switch on reverb on  the narrator ABC", 100,100
		If Reverb
			DrawText "Reverb=ON", 100,130
		Else
			DrawText "Reverb=OFF", 100,130
		EndIf 
		If MouseHit(1)
			reverb=1-reverb
		EndIf 
    Flip
Until AppTerminate()
Miniaudio.KillDevice()
End 


Function MyCallBack(a%, Buffer:Short Ptr, RecordingBuffer:Short Ptr, Frames%)
	' here you manipulate the sound:
	For Local i%=0 To frames-1
		Local da% = Pointer/2+i
		Local V%= ShortInt(SoundBank.PeekShort(pointer+2*i))
		V = V + echobank.PeekInt(da*4)
		CalculateReverb da, v
		Buffer[i]= V
	Next
    Pointer=(Pointer + 2*Frames) Mod 480000
End Function 


Function CalculateReverb(when%, value#)
	If reverb=0 Return 
	Local f#=0.40, dist#=2700, df#=0.72

	For Local j%=0 To 99
		value=value*f
		dist=dist*df
		Local when2%=Int(when+Dist)*4
		Local w%=echobank.PeekInt(when2) + value
		Echobank.PokeInt(when2, w)
	Next 
	Echobank.PokeInt(when*4,0)
End Function 


Function ShortInt:Int( s:Int )
    Return (s Shl 16) Sar 16
End Function
