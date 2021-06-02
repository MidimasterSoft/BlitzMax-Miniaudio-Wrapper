' example: loadsound.bmx

Global MiniAudio:TMiniAudio = New TMiniAudio

Local MySound:TSound = MiniAudio.LoadSound("TestABC.mp3")
PlaySound MySound

