SuperStrict

Rem 
bbdoc: MiniAudio Wrapper
about: Binding/Wrapper for MiniAudio for BlitzMax.
End Rem
Module mima.miniaudio
ModuleInfo "Version: MiniAudio: 0.10.35 modified!!!"
ModuleInfo "Version: Wrapper: 1.25"
ModuleInfo "License: MIT(0)"
ModuleInfo "Copyright: MINIAUDIO David Reid - mackron@gmail.com  https://miniaud.io"
ModuleInfo "Copyright: WRAPPER Peter Wolkersdorfer info@midimaster.de  http://midimaster.de"

ModuleInfo "History: 1.25 again modiefied miniaudio.h because of BlitzMax DEBUG MODE problem"
ModuleInfo "History: 1.24 load multichannel audio files OGG FLAC WAV"
ModuleInfo "History: 1.23 new extended TAudioSample Object for 32bit float and multichannel "
ModuleInfo "History: 1.22 c89 compatible, OGG file support"
ModuleInfo "History: 1.21 remove two bugs"
ModuleInfo "History: 1.20 Save WAV-file"
ModuleInfo "History: 1.19 capture and playback n-channel via hardware devices"
ModuleInfo "History: 1.18 Load FLAC and WAV 24bit, 32bit and 32bit-float"
ModuleInfo "History: 1.16 enumerate devices and select them"



Import BRL.StandardIO
Import brl.audiosample
Import brl.audio
Import brl.bank
Import brl.linkedlist
Import brl.stringbuilder
Import "miniaudiowrapper.c"

Rem
bbdoc: MiniAudio-Wrapper.
about: Use MiniAudio as a Callback Audio device.
returns: A TMiniAudio object
End Rem
Type TMiniAudio
		'DeviceTyp:
		 Const PLAYBACK:Int=1, CAPTURE:Int=2, DUPLEX:Int=3, LOOPBACK:Int=4
		'Format:
		Const FORMAT_U8:Int=1, FORMAT_S16:Int=2 ,FORMAT_S24:Int=3, FORMAT_S32:Int=4, FORMAT_F32:Int=5 
		Const SUCCESS:Int=0;

		Field  DeviceConfig: Byte Ptr, Device:Byte Ptr, Decoder:Byte Ptr, DeviceContext: Byte Ptr
		
		Field Capture_Devices$[], Playback_Devices$[]
		Field  SelectedPlayBack:Int=-1, SelectedCapture:Int=-1
		Field FileList:TList=New TList


Rem
bbdoc: Open Device
returns: TRUE if successful 
about: Define Device Configuration
<br> @DeviceType is one of:
[ @Device Type | @Value | @Description
* PLAYBACK | 1 | Use the device for Playing
* CAPTURE | 2 | Use the device for Recording
* DUPLEX | 3 | Use the device for simultanious Capture and Playing 
* LOOPBACK | 4 | Record what is "on the speakers"
]
<br> @Channels is the number of Channels 1=MONO, 2=STEREO , 3-32=Multichannel. 
<br><br> @SampleRate is the frequency in samples per second (Hz) the audio sample will be processed. 
<br><br> @UserCallBackPointer is the name of your Callback-function
<br><br> @Format should be one of:

[ @Format | @Value | @Description
* FORMAT_U8 | 1 | Unsigned 8 bit
* FORMAT_S16 | 2 | Signed 16 bit little endian
* FORMAT_S24 | 3 | Signed 24 bit little endian
* FORMAT_S32 | 4 | Signed 32 bit little endian
* FORMAT_F32 | 5 | Signed 32 bit Float -1 to +1
]

End Rem
		Method OpenDevice:Int(DeviceType:Int, Format:Int, Channels:Int, SampleRate:Int, UserCallBackPointer: Byte Ptr)
			Return OpenDevice_II(DeviceType, Format, Channels, Format, Channels, SampleRate, UserCallBackPointer)
		End Method




Rem
bbdoc: Same as @OpenDevice, but with independent parameters for Capture and Playback:
returns: TRUE if successful 
about: Define two different Device Configurations for Duplex
 
<br> @DeviceType is :
[ @Device Type | @Value | @Description
* DUPLEX | 3 | Use the device for simultanious Capture and Playback 
]
<br><br> @PlayChannels is the number of Channels when playback 1 = MONO    2 = STEREO.
<br><br> @CaptChannels is the number of Channels when capture  1 = MONO    2 = STEREO. 
<br><br> @SampleRate is a common frequency in samples per second (Hz) for capture and playback. 
<br><br> @PlayFormat and @CaptFormat can be any one of:
[ @Format | @Value | @Description
* FORMAT_U8 | 1 | Unsigned 8 bit
* FORMAT_S16 | 2 | Signed 16 bit little endian
* FORMAT_S24 | 3 | Signed 24 bit little endian
* FORMAT_S32 | 4 | Signed 32 bit little endian
* FORMAT_F32 | 5 | Signed 32 bit Float -1 to +1
]

End Rem
		Method OpenDevice_II:Int(DeviceType:Int, PlayFormat:Int, PlayChannels:Int,  CaptFormat:Int, CaptChannels:Int,SampleRate:Int, UserCallBackPointer: Byte Ptr)
			If GetDeviceConfig(DeviceType)=False 
				Print  "Miniaudio could not be startet"
				Return False
			EndIf 
			SetDevice(PlayFormat, PlayChannels, CaptFormat, CaptChannels, SampleRate, UserCallBackPointer)
			Return True 
		End Method





Rem
bbdoc: Start Device.
about: Runs the Device or continues the Device
End Rem 
		Method StartDevice()
			_StartDevice:Int (Device:Byte Ptr)
		End Method



Rem
bbdoc: Stop Device.
about: Pauses the Device 
End Rem 		
		Method StopDevice()
			_StopDevice:Int (Device:Byte Ptr)		
		End Method
		


Rem
bbdoc: close Device.
about: Deletes the Device 
End Rem 		
		Method CloseDevice()
			_KillDevice:Int (Device:Byte Ptr)
		End Method








Rem
bbdoc: Playback Devices
returns: a String array
about: Lists all avaiable hardware Playback-Devices

End Rem
		Method PlaybackDevices:String[]()
			Return Playback_Devices
		End Method 

Rem
bbdoc: Capture Devices
returns: a String array
about: Lists all avaiable hardware Capture-Devices

End Rem
		Method CaptureDevices:String[]()
			Return Capture_Devices
		End Method 

Rem
bbdoc: Select Devices
returns: 
about: Select one from the avaiable hardware Devices. For ID_.. use their position in the string arrays  PlaybackDevices[] and CaptureDevices[]. 
The selection must be done before calling *MiniAudio.OpenDevice(). Sending -1 as ID uses the OS default device.

End Rem
		Method SelectDevices(ID_Playback:Int=-1, ID_Capture:Int=-1)
			If Deviceconfig<>Null Return 
			If ID_Playback >= Playback_Devices.length
				ID_Playback=-1
			EndIf 
			If ID_Capture >= Capture_Devices.length
				ID_Capture=-1
			EndIf 
			SelectedPlayBack = ID_Playback
			SelectedCapture = ID_Capture
			Print "selected ID: P=" + SelectedPlayBack + " C=" + SelectedCapture
		End Method










Rem
bbdoc: Load Audio-File as BlitzMax TSound Object
returns: a TSound object
about: Loads a MONO/STEREO audio MP3, FLAC, WAV or OGG file. No need for Defining or Starting the device.
Also 24bit-, 32bit- and 32bit-float files are processed and converted to BlitzMax 16bit.

End Rem
		Method LoadSound:TSound(File:String)
			Return LoadSound(Self.LoadAudioSample(File))
        End Method

		
Rem
bbdoc: Load MP3, FLAC, WAV or OGG as BlitzMax TAudioSample Object
returns: a TAudioSample object
about: Loads a MONO/STEREO audio MP3, FLAC, WAV or OGG file.  24bit-, 32bit- and 32bit-float-files will return 16bit TAudioSample. No need for Defining or Starting the device

End Rem
		Method LoadAudioSample:TAudioSample(File:String)
			Local Hertz:Int, Channels:Int, Frames:Int, Format:Int
			Local result:Int= MM_DecodeParameter(File.ToCString(), Varptr(Frames), Varptr(Hertz), Varptr(Channels), Varptr(Format))
			If Channels>2
				Print "ERROR not mono or stereo while loading TAudioSample"
			'	Return Null
			EndIf 
			Local Sample:TAudioSample=CreateAudioSample(Frames*Channels,Hertz,SF_MONO16LE)
			result= MM_Decode16bit(File.ToCString(), Sample.Samples)
			If result=0
				Print "ERROR while loading TAudioSample"
				Return Null
			EndIf 
			Return Sample 		
		End Method



Rem
bbdoc: Load MP3, FLAC, WAV or OGG as new  extended ExTAudioSample Object.
returns: a ExTAudioSample object
about: Loads any audio OGG, MP3, FLAC or WAV file in the new extended TAudioSample object. Also Multichannel is supported. No need for Defining or Starting the device
<br><br> @Format should be one of:

[ @Format | @Value | @Description
* FORMAT_U8 | 1 | Unsigned 8 bit
* FORMAT_S16 | 2 | Signed 16 bit little endian
* FORMAT_S32 | 4 | Signed 32 bit little endian
* FORMAT_F32 | 5 | Signed 32 bit Float -1 to +1
]

The Audio datas will be converted to the new format 

See TYPE #ExTAudioSample for more informations.
End Rem
		Method LoadExtendedAudioSample:ExTAudioSample(File:String, Format:Int=FORMAT_F32)
			Local Hertz:Int, Channels:Int, Frames:Int, OldFormat:Int
			Print "format vorher " + format
			Local result:Int= MM_DecodeParameter(File.ToCString(), Varptr(Frames), Varptr(Hertz), Varptr(Channels), Varptr(oldFormat))
			If result=0
				Print "ERROR while loading TAudioSample"
				Return Null
			EndIf 
			Print "format vorher " + format
			Local Sample:ExTAudioSample = ExTAudioSample.Create(Frames, Hertz, Format, Channels)
			If Format=FORMAT_S32
				result= MM_Decode32(File.ToCString(),  Sample.Samples)			
			Else
				result= MM_Decode(File.ToCString(),  Sample.Samples)
			EndIf 
			Return Sample 		
		End Method












Rem
bbdoc: Save BlitzMax TAudioSample as WAV
about: Saves a TAudioSample as a WAV file.
<br><br> @FileName is the path + name of the audio file
<br><br> @Sample is the  TAudioSample object containing datas
<br><br> No need for Defining or Starting the device
<br><br>
Use #OpenWavFile() if you need to convert format or data is longer than 2GB
End Rem
		Method SaveTAudioSample(FileName:String, Sample:TAudioSample)
		
			Local Channels:Int = 1
			Local Format:Int = FORMAT_U8
			Select Sample.Format
				Case SF_MONO8
				Case SF_MONO16LE
					Format=FORMAT_S16
				Case SF_STEREO8
					channels=2
				Case SF_STEREO16LE
					channels=2
					Format=FORMAT_S16
			End Select
			Local Frames:Int = Sample.Length/Channels
			MM_SaveWav FileName.ToCString(), Sample.Samples, Frames, Format, Channels, Sample.Hertz
		End Method





Rem
bbdoc: Save new extended  TAudioSample as WAV
about: Saves a ExTAudioSample as a WAV file.
<br><br> @FileName is the path + name of the audio file
<br><br> @Sample is the  ExTAudioSample object containing datas
<br><br> No need for Defining or Starting the device
<br><br>
Use #OpenWavFile() if you need to convert format or data is longer than 2GB
End Rem
		Method SaveExTAudioSample(FileName:String, Sample:ExTAudioSample)
			MM_SaveWav FileName.ToCString(), Sample.Samples, Sample.Frames, Sample.Format, Sample.Channels, Sample.Hertz
		End Method







Rem
bbdoc: Save WAV Bank
returns: 
about: Saves the content of a  TBank as a WAV file. The content of the TBank must have the same format as the WAV file. No need for Defining or Starting the device
<br><br> @FileName is the path +name of the audio file
<br><br> @Bank is a TBank which contains the samples
<br><br> @Channels is the number of Channels 1 - 32.
<br><br> @Hertz is the frequency in samples per second (Hz) the Samples are captured.
<br><br> @Format should be one of:
[ @Format | @Value | @Description
* FORMAT_U8 | 1 | Unsigned 8 bit
* FORMAT_S16 | 2 | Signed 16 bit little endian
* FORMAT_S24 | 3 | Signed 24 bit little endian
* FORMAT_S32 | 4 | Signed 32 bit little endian
* FORMAT_F32 | 5 | Signed 32 bit Float -1 to +1
]
@Frames is is independent of Format and Channels and needs to be calculated by multiplication (Hertz*Seconds) 
or can also be calculated by TotalBytes/Channels/Format. So 32bit format and 5 channels are 4*5=20Bytes, but still only one frame!!!
Use @#OpenWavFile() if you need to convert format or data is longer than 2GB
End Rem
		Method SaveWavBank(FileName:String, Bank:TBank, Format:Int, Channels:Int, Hertz:Int, Frames:Int)
			MM_SaveWav FileName.ToCString(), Bank.Lock(), Frames, Format, Channels, Hertz
			Bank.Unlock()
		End Method




Rem
bbdoc: Special Open WAV File for Writing
returns: The handle to the file as MMStreamID
about: Opens a file for saving the content of a  TBank as a WAV file. Use it to save data in intervalls, when want to change
format or when data will be  longer than 2GB
<br><br> No need for Defining or Starting the device
<br><br> @FileName is the path +name of the audio file 
<br><br> @Channels is the number of Channels 1 - 32. 
<br><br> @Hertz is the frequency in samples per second (Hz) the file will have. 
<br><br> @Format should be one of:
[ @Format | @Value | @Description
* FORMAT_U8 | 1 | Unsigned 8 bit
* FORMAT_S16 | 2 | Signed 16 bit little endian
* FORMAT_S24 | 3 | Signed 24 bit little endian
* FORMAT_S32 | 4 | Signed 32 bit little endian
* FORMAT_F32 | 5 | Signed 32 bit Float -1 to +1
]
Use together with #WriteWavFile() and @CloseWavFile()
End Rem
		Method OpenWavFile:MMStreamID(FileName:String, Format:Int, Channels:Int, Hertz:Int)
			Local loc:mmFileHandle=New mmFileHandle 
			loc.Handle.ID=MilliSecs()
			loc.Format=Format
			loc.Channels=Channels
			loc.Hertz=Hertz
			loc.Encoder=MM_GetEncoder( FileName.ToCString(), Format, Channels, Hertz)
			If loc.encoder=Null Return Null
			FileList.addlast loc 
			Delay 2
			Return loc.Handle 
		End Method


Rem
bbdoc: Write data to WAV File 
about: writes to an opened WAV file for saving the content of a TBank. Use it to save data in intervalls, when want to change
format or when data will be  longer than 2GB
<br><br> @Handle is the handle to the file returned by OpenWavFile()
<br><br> @Adress is a Byte Ptr to a RAM which contains the samples
<br><br> @Frames is is independent of Format and Channels and needs to be calculated by multiplication (Hertz*Seconds) 
or can also be calculated by TotalBytes/Channels/Format. So 32bit format and 5 channels are 4*5=20Bytes, but still only one frame!!!
<br><br>
[ Only if you need to convert datas between Samples and file:
* @Channels is the number of source- channels 1 - 32. 
* @Hertz is the frequency in samples per second (Hz) the source datas have. 
* @Format is the source datas have.
]
@Format should be one of:
[ @Format | @Value | @Description
* FORMAT_U8 | 1 | Unsigned 8 bit
* FORMAT_S16 | 2 | Signed 16 bit little endian
* FORMAT_S24 | 3 | Signed 24 bit little endian
* FORMAT_S32 | 4 | Signed 32 bit little endian
* FORMAT_F32 | 5 | Signed 32 bit Float -1 to +1
]
Use together with #OpenWavFile() and #CloseWavFile()
End Rem
		Method WriteWavFile(Handle:MMStreamID, Adress:Byte Ptr, Frames:Int, Format:Int=0, Channels:Int=0, Hertz:Int=0)
			Local FileHandle:mmFileHandle = FindHandle(Handle)
			MM_WriteEncoder FileHandle.Encoder, Adress, Frames
		End Method


Rem
bbdoc: Close WAV File 
about: Closes a WAV file (opened with OpenWavFile) after saving the content.
<br><br> 
<br><br> @Handle is the handle to the file returned by OpenWavFile()
<br><br>
Use together with #OpenWavFile() and  #WriteWavFile()
End Rem
		Method CloseWavFile(Handle:MMStreamID)
			Local FileHandle:mmFileHandle = FindHandle(Handle)
			_EncoderClose FileHandle.Encoder
			FileList.remove FileHandle 
		End Method


		Method FindHandle:mmFileHandle(Handle:MMSTreamID)
			For Local loc:mmFileHandle=EachIn FileList
				If loc.Handle=Handle  Return loc 
			Next 
			Return Null
		End Method  
		
		
		
		Method New()
			GetContext
		End Method


		
		Method GetContext:Int()
			Local Speicher:TBank=CreateBank(10000)
			speicher.PokeByte(0,Asc("|"))
			speicher.PokeByte(1,Asc("O"))
			speicher.PokeByte(2,Asc("U"))
			speicher.PokeByte(3,Asc("T"))
			speicher.PokeByte(4,Asc("|"))
			speicher.PokeByte(5,Asc("|"))
			If DeviceContext <> Null Return False  
			Self.DeviceContext = MM_GetContext(speicher.lock())
			If DeviceContext=Null End   
			speicher.unlock()
			Local sb:TStringBuilder = New TStringBuilder
			For Local i%=0 To 999
				If speicher.PeekByte(i)=0 Exit 				
				sb.Append(Chr(speicher.PeekByte(i)))
			Next
			Local a$= sb.ToString()
			Local arr$[]=a.split("||")
			Local typ%=0, InNr%=0, OutNr%=0
			For Local a$ = EachIn arr
				Select a
					Case "|OUT"
						typ=0
						OutNr=0
					Case "|IN"
						typ=1
						InNr=0
					Case "|END"
						typ=3
					Default
					Select typ
						Case 0
							OutNr=OutNr+1
						Case 1
							InNr=InNr+1
					End Select
				End Select
			Next 
			typ=0
			Local In$[InNr], Out$[OutNr], nr%


			For Local a$ = EachIn arr
				Select a
					Case "|OUT"
						typ=0
						nr=0
					Case "|IN"
						typ=1
						nr=0
					Case "|END"
						typ=3
					Default
					Select typ
						Case 0
							Out[nr]=a
						Case 1
							In[nr]=a
					End Select
					nr=nr+1
				End Select
			Next 
			Capture_Devices=In
			Playback_Devices=Out
			Return True 
				
		End Method






Rem
bbdoc: ConvertAudioSample
returns: a ExTAudioSample object
about: Converts a BlitzMax TAudioSample into the new extended TAudioSample with new format, samplerate and channels.
<br><br> @Format is the Target-format and should be one of:

[ @Format | @Value | @Description
* FORMAT_U8 | 1 | Unsigned 8 bit
* FORMAT_S16 | 2 | Signed 16 bit little endian
* FORMAT_S32 | 4 | Signed 32 bit little endian
* FORMAT_F32 | 5 | Signed 32 bit Float -1 to +1
]
<br><br> @Channels is the target number of Channels 1 = MONO    2 = STEREO. 
<br><br> @Hertz is the target frequency in samples per second (Hz). 
End Rem
		Method ConvertAudioSample:ExTAudioSample(Source:TAudioSample, Format:Int, Channels:Int, Hertz:Int)
			Local  sourceChannels:Int, sourceFormat:Int, sourceSize:Int, BanksSize:Int

			Select Source.Format
				Case SF_MONO8
					SourceFormat=FORMAT_U8
					sourceChannels=1
					sourceSize=source.length
				Case SF_STEREO8
					SourceFormat=FORMAT_U8
					sourceChannels=2
					sourceSize=source.length/2
				Case SF_MONO16LE
					SourceFormat=FORMAT_S16
					sourceChannels=1
					sourceSize=source.length
				Case SF_STEREO16LE
					SourceFormat=FORMAT_S16
					sourceChannels=2	
					sourceSize=source.length/2
				Default
					Print "source format not suppported"
					Return Null
			End Select 
			'estimate the number of samples:
			Local FinalSize:Int = MM_Convert(Null, 0, Format, Channels, Hertz, Source.Samples, sourceSize, sourceFormat, sourceChannels, source.Hertz)
			' now convert it :
			Local Sample:ExTAudioSample = ExTAudioSample.Create(FinalSize, Hertz, Format, Channels)
			MM_Convert(Sample.Samples, FinalSize, Format, Channels, Hertz, Source.Samples, sourceSize, sourceFormat, sourceChannels, source.Hertz)
			Return Sample 		
		End Method









Rem
bbdoc: ConvertAudioSample_II
returns: a TBank object
about: Converts a TAudioSample into a Bank with new format, samplerate and channels.
<br><br> @Format is the Target-format and should be one of:

[ @Format | @Value | @Description
* FORMAT_U8 | 1 | Unsigned 8 bit
* FORMAT_S16 | 2 | Signed 16 bit little endian
* FORMAT_S24 | 3 | Signed 24 bit little endian
* FORMAT_S32 | 4 | Signed 32 bit little endian
* FORMAT_F32 | 5 | Signed 32 bit Float -1 to +1
]
<br><br> @Channels is the target number of Channels 1 = MONO    2 = STEREO. 
<br><br> @Hertz is the target frequency in samples per second (Hz). 
End Rem
		Method ConvertAudioSample_II:TBank(Source:TAudioSample, Format:Int, Channels:Int, Hertz:Int)
			Local  sourceChannels:Int, sourceFormat:Int, sourceSize:Int, BanksSize:Int

			Select Source.Format
				Case SF_MONO8
					SourceFormat=FORMAT_U8
					sourceChannels=1
					sourceSize=source.length
				Case SF_STEREO8
					SourceFormat=FORMAT_U8
					sourceChannels=2
					sourceSize=source.length/2
				Case SF_MONO16LE
					SourceFormat=FORMAT_S16
					sourceChannels=1
					sourceSize=source.length
				Case SF_STEREO16LE
					SourceFormat=FORMAT_S16
					sourceChannels=2	
					sourceSize=source.length/2
				Default
					Print "source format not suppported"
					Return Null
			End Select 
			'estimate the number of samples:
			Local FinalSize:Int = MM_Convert(Null, 0, Format, Channels, Hertz, Source.Samples, sourceSize, sourceFormat, sourceChannels, source.Hertz)
			Select Format
				Case FORMAT_U8
					BanksSize = FinalSize*Channels
				Case FORMAT_S16
					BanksSize = FinalSize*Channels*2			
				Case FORMAT_S24
					BanksSize = FinalSize*Channels*3
				Case FORMAT_S32
					BanksSize = FinalSize*Channels*4
				Case FORMAT_F32
					BanksSize = FinalSize*Channels*4
			End Select  
			' now convert it :
			Local OutBank:TBank = CreateBank(BanksSize)
			Local Adress:Byte Ptr=OutBank.Lock()
			MM_Convert(Adress, FinalSize, Format, Channels, Hertz, Source.Samples, sourceSize, sourceFormat, sourceChannels, source.Hertz)
			Outbank.unLock()
			Return OutBank 		
		End Method




		Method GetDeviceConfig:Int(DeviceType:Int)
			If DeviceConfig<>Null Return False  
			If DeviceType<1 Or DeviceType>4 Return False 
			DeviceConfig = _DeviceConfigInit(DeviceContext, DeviceType, SelectedPlayBack, SelectedCapture)
			If DeviceConfig=Null End   
			Return True 
		End Method 

		Method SetDevice(PlayFormat:Int, PlayChannels:Int, CaptFormat:Int, CaptChannels:Int,SampleRate:Int, UserCallBackPointer: Byte Ptr)
			_SetDeviceConfig DeviceConfig, PlayFormat, PlayChannels, CaptFormat, CaptChannels, SampleRate, UserCallBackPointer  
			Device=_GetDevice(DeviceConfig, DeviceContext)
			'Device=_GetDevice(DeviceConfig, Null)
			If Device=Null End 
		End Method









	Function FormatLen:Int(Format:Int)
		Select Format 
			Case FORMAT_U8
				Return 1
			Case FORMAT_S16
				Return 2		
			Case FORMAT_S24
				Return 3
			Case FORMAT_S32, FORMAT_F32 
				Return 4
		End Select 
		Return 0
	End Function 

End Type



Extern "C"
	Function MM_SaveWav:Int (FileName:Byte Ptr, SampleRam:Byte Ptr, Frames:Int, Format:Int, Channels:Int, Hertz:Int)
	Function MM_GetEncoder:Byte Ptr(FileName:Byte Ptr, Format:Int, Channels:Int, Hertz:Int)
	Function MM_WriteEncoder (Encoder:Byte Ptr, SampleRam:Byte Ptr, Frames:Int) 

	Function MM_GetContext:Byte Ptr(StringRam:Byte Ptr)
	
	Function MM_Decode16bit:Int(FileName:Byte Ptr, SampleRam:Byte Ptr)
	Function MM_Decode32:Int(FileName:Byte Ptr, SampleRam:Byte Ptr)
	Function MM_Decode:Int(FileName:Byte Ptr, SampleRam:Byte Ptr)
	Function MM_DecodeParameter:Int(FileName:Byte Ptr, SIZE: Int Ptr, Hertz: Int Ptr, Channels: Int Ptr, Format: Int Ptr)

	Function MM_Convert:Int ( OutBuffer:Byte Ptr, Frames:Int, Format:Int, Channels:Int, Hertz:Int, SourceBuffer:Byte Ptr, sourceSize:Int, sourceFormat:Int, sourceChannels:Int, sourceHertz:Int)
	
	Function _DeviceConfigInit:Byte Ptr( DeviceContext:Byte Ptr, DeviceType:Int, ID_Playback:Int, ID_Capture:Int) = "ma_device_config_init_glue"
	Function _SetDeviceConfig (DeviceRAM:Byte Ptr, PlayFormat:Int, PlayChannels:Int, CaptFormat:Int, CaptChannels:Int, Hertz:Int, CallBack:Byte Ptr ) = "MM_SetDeviceConfig"	
	Function _GetDevice:Byte Ptr  (DeviceRAM:Byte Ptr , DeviceContext:Byte Ptr) = "MM_GetDevice"
	Function _StartDevice:Int (DeviceRAM:Byte Ptr) = "ma_device_start"
	Function _StopDevice:Int (DeviceRAM:Byte Ptr) = "ma_device_stop"
	Function _KillDevice:Int (DeviceRAM:Byte Ptr) = "ma_device_uninit"
	Function _EncoderClose (EncoderRAM:Byte Ptr) = "ma_encoder_uninit"

End Extern



Type mmFileHandle
	Field Handle:MMStreamID, Encoder:Byte Ptr, Format:Int, Channels:Int, Hertz:Int 
End Type 


Type MMStreamID
	Field id:Int
End Type



Rem
bbdoc: Extended TAudioSample Object.
about: Enables multichannel and 32bit FLOAT
End Rem
Type ExTAudioSample 'Extends TAudioSample
	Const FORMAT_U8:Int=1, FORMAT_S16:Int=2 ,FORMAT_S24:Int=3, FORMAT_S32:Int=4, FORMAT_F32:Int=5 

	Field SampleBank:TBank, Frames:Int, Hertz:Int, Channels: Int, Capacity:Int, FrameLength:Int
	Field Format:Int, SampleSize:Int
	Field SampleByte:Byte Ptr, SampleFloat: Float Ptr, SampleInt:Int Ptr, SampleShort:Short Ptr



Rem
bbdoc: Create Extended TAudio Object.
returns: a ExTAudioSample Object
about: Container for 8bit 16bit 32bit INTEGERs and 32bit FLOAT samples and 1-32 Multi-Channels

<br> @{Definition of the Sample Ram}
<br> The SampleRam has the same definition like in miniaudio. The samples are organized in Frames. Each frame contains all sample belonging to the same time stamp.
This is called interlaced. Means
<br> <pre> | 1st sample LEFT | 1st sample RIGHT | 1st sample CH3 |...1st sample CH n || 2nd sample LEFT | 2nd sample RIGHT | 2nd sample CH3 |......|.... </pre>

<br> @Frames: total number of Frames in this Audio. 
<br> @Hertz is the frequency in samples per second (Hz) the Samples are captured.
<br> @Channels is 1-32 
<br> @Format is one of:
[ @Format | @Pointer | @Description
* FORMAT_U8 | 1 | Unsigned 8 bit
* FORMAT_S16 | 2 | Signed 16 bit little endian
* FORMAT_S32 | 4 | Signed 32 bit little endian
* FORMAT_F32 | 5 | Signed 32 bit Float -1 to +1
]
End Rem 		
	Function Create:ExTAudioSample(frames:Int, hertz:Int, format:Int, channels:Int )
		Local loc:ExTAudioSample = New ExTAudioSample
		Print "format=" +  format
		
		loc.Channels    = Channels
		loc.Frames      = frames
		loc.hertz       = hertz
		loc.format      = format
	    Select format 
			Case FORMAT_U8
				loc.SampleSize=1
			Case FORMAT_S16
				loc.SampleSize=2		
			Case FORMAT_S32, FORMAT_F32
				loc.SampleSize=4
		End Select 	
		loc.FrameLength = channels * 4
		loc.capacity    = frames * loc.SampleSize
		loc.SampleBank  = CreateBank(loc.capacity+400)
		loc.SampleByte  = loc.SampleBank.lock()
		loc.SampleShort = loc.SampleByte
		loc.SampleInt   = loc.SampleByte
		loc.SampleFloat = loc.SampleByte
		Print "Create ExTAudio size=" + loc.capacity+ " " + loc.format + " " + format
		Return loc
	End Function	
	
	'Method FramesToPos:Int(FramePos:Int)
	'	Return FramePos * FrameLength
	'End Method 

Rem
bbdoc: Headline
End Rem


Rem
bbdoc: Sample-Pointer to audio data
returns: a Byte Ptr
about: Returns the Pointer to the sample datas
<br> @IMPORTANT 
<br> for easy use of the Sample RAM define your  pointer of the correct type with this method:
[ @Format | @Pointer | @Example
* FORMAT_U8 | Byte Ptr | <pre>Global SampleRAM:Byte Ptr = MySample.Samples()
* FORMAT_S16 | Short Ptr | <pre>Global SampleRAM:Short Ptr = MySample.Samples()
* FORMAT_S32 | Int Ptr | <pre>Global SampleRAM:Int Ptr = MySample.Samples()
* FORMAT_F32 | Float Ptr | <pre> Global SampleRAM:Float Ptr = MySample.Samples()
]
End Rem
	Method Samples:Byte Ptr()
		Return SampleByte
	End Method




Rem
bbdoc: Extract one Channel.
returns: a ExTAudioSample Object
about: Extracts one channel of a Multi-Channel Audio-Sample
<br> @Source: The multichannel object
<br> @Channel: the channel to extract
End Rem 
	Method ExtractChannel:ExTAudioSample(Channel:Int)
		Local loc:ExTAudioSample = Create( Frames, Hertz, Format, 1 )
			
		For Local i:Int=0 To Frames-1
			Select Format 
				Case FORMAT_U8
					loc.SampleByte[i]  = SampleByte[i*Channels + Channel]
				Case FORMAT_S16
					loc.SampleShort[i] = SampleShort[i*Channels + Channel]
				Case FORMAT_S32
					loc.SampleInt[i]   = SampleInt[i*Channels + Channel]
				Case FORMAT_F32
					loc.SampleFloat[i] = SampleFloat[i*Channels + Channel]
				Default 
					Return Null
			End Select 
		Next
		Return loc 
	End Method	
	
	
	
	
Rem
bbdoc: Import one Channel.
return: TRUE if successfull
about: Imports one channel into a Multi-Channel Audio-Sample
<br> @Source: The single channel object
<br> @Destination: The multichannel object
<br> @Channel: the channel to be overwritten
<br> Source and destination must havethe same Format, Hertz and number of frames. 
End Rem 
	Method ImportChannel:Int(Source:ExTAudioSample, Channel:Int)
		If Channel         > Channels Return 0
		If Source.Channels<> 1        Return 0
		If source.Format  <> Format   Return 0
		If Source.Frames   > Frames   Return 0
		If Source.Hertz   <> Hertz    Return 0

		For Local i:Int=0 To Source.Frames-1
			Select Format 
				Case FORMAT_U8
					SampleByte[i*Channels + Channel] = source.SampleByte[i]
				Case FORMAT_S16
					SampleShort[i*Channels + Channel] = source.SampleShort[i]
				Case FORMAT_S32
					SampleInt[i*Channels + Channel] = source.SampleInt[i]
				Case FORMAT_F32
					SampleFloat[i*Channels + Channel] = source.SampleFloat[i]
			End Select 
		Next
		Return True
	End Method	

Rem
bbdoc: Clears the Sample Buffer.
about: fills the sample buffer with 0
End Rem 	
	Method Clear()
		For Local i%=0 To Capacity/4
			SampleInt[i]=0
		Next 
	End Method 
End Type 

