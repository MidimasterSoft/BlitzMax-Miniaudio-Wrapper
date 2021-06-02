SuperStrict
Import mima.miniaudio

Graphics 800,400
 
' Setup of the device:
Global MiniAudio:TMiniAudio=New TMiniAudio
MiniAudio.GetDevice( MiniAudio.PLAYBACK, Miniaudio.FORMAT_S16, 1, 12000, MyCallBack)

Global Source:TAudioSample=LoadAudioSample("TestABC.ogg")
Print source.length


Global SoundBank:TBank=CreateStaticBank(Source.Samples, Source.Length*2) 
' now start it:
MiniAudio.StartDevice()
 
Global Pointer:Int , LastMouse:Int , Speed:Int=1
 
Repeat
    Cls
        SetColor 255,255,255
        DrawText "Mouse the Slider to navigate through the spoken ABC", 100,100
        DrawRect 50,300,700,20
        SetColor 1,1,1
        DrawRect 52,302,696,16
        SetColor 255,255,255
        DrawOval 50+ Pointer*680/Source.Length/2,298,25,25    
        SetColor 1,1,1
        DrawOval 52+ Pointer*680/Source.Length/2,300,21,21    
        If MouseDown(1)
                If MouseX()>49 And MouseX()<745
                        If LastMouse<>MouseX()
                                LastMouse = MouseX()
                                Local p%=(MouseX()-50)*Source.Length*2/700
                                Pointer= p & $FFFFF4
                                Speed=2
                        Else
                                Speed=1
                        EndIf
                EndIf
        Else
                Speed=1
                LastMouse=0
        EndIf
    Flip
Until AppTerminate()
Miniaudio.KillDevice()
End
 
 
Function MyCallBack(a%, PlayBuffer:Short Ptr, RecordingBuffer:Short Ptr, Frames%)
        ' here you manipulate the sound:
		Local jump%=2*speed
        For Local i%=0 To frames-1
				PlayBuffer[i]= SoundBank.PeekShort(pointer+i*jump)
        Next
        Pointer=(Pointer + Frames*jump) Mod  480000
End Function 
