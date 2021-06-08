# BlitzMax-Miniaudio-Wrapper 1.25 (2021-06-08)
a binding/wrapper for the audio library Miniaudio to the language BlitzMax  

The wrapper enables to use the C-library miniaudio (https://github.com/mackron/miniaudio) in the BASIC language BlitzMax (https://blitzmax.org/)

at the moment it is in Beta-state. 

There is already a manual here: https://www.syntaxbomb.com/index.php/topic,8419.0.html 

Now you can use the repository to download the whole module

And a discussion forum here: https://www.syntaxbomb.com/index.php/topic,8388.0.html

Until MiniAudio V0.10.36 will be published we still included a modified version of V 0.10.35

## Example

Here is a minimal example. It opens the device and makes some noise
```
Import mima.miniaudio

' Setup of the device:
Global MiniAudio:TMiniAudio=New TMiniAudio
MiniAudio.OpenDevice( MiniAudio.PLAYBACK, Miniaudio.FORMAT_S16, 1, 48000, MyCallBack)

' now start it:
MiniAudio.StartDevice()

'your main loop:
Repeat
	Flip 1
Until AppTerminate()

' free the device:
Miniaudio.CloseDevice()
End 

'data aree delivered via a callback procedure:
Function MyCallBack(void:Byte Ptr, PlayBuffer:Short Ptr, RecordingBuffer:Short Ptr, Frames:Int)
	For Local i:Int=0 To Frames-1
		PlayBuffer[i] = Rand(-32000,+32000)
	Next 
End Function 


```
# Device Features:
Audio-Playback and Recording with low latency below 30msec  
Realtime Samples access of already playing samples  
Playback and Capture MONO STEREO, 3-32 tracks  
Full Duplex: Capture and Playback at the same time  
Loopback: Record what is "on the speakers"  
All backend devices on all plattforms are supported incl. WASAPI on Windows  
access to USB hardware devices with upto 32 capture/playback channels  
Formats: 8bit, 16bit, 32bit and 32bit-float  
Samples-Rates from 8kHz-192kHzHz  
CallBack-Access, Multithread 

# File Features:
 
Opening MP3, OGG, FLAC and WAV files with Audioformats bejond 16bit  
Opening OGG, FLAC and WAV files with Multichannels  
Converting Audiofiles to old BlitzMax TAudioSample TSound objects  
New extended TAudioSample object with multichannel and 32bit samples  
Save WAV-files in various formats upto 32 tracks 



# Functions and Methods

## Type TMiniAudio:

### OpenDevice 
Opens the Device.
  
### OpenDevice_II 
Same as OpenDevice, but with independent parameters for Capture and Playback.  

### StartDevice
Starts the Device. 
 
### StopDevice 
Stops the Device.
  
### CloseDevice
Close the Device.
  
### PlaybackDevices
Lists all avaiable Playback Devices.
  
### CaptureDevices 
Lists all avaiable Capture Devices.
  
### SelectDevices 
Select the Devices.
  
### LoadSound 
Load Audio-File as BlitzMax TSound Object.  

### LoadAudioSample 
Load MP3, FLAC, WAV or OGG as BlitzMax TAudioSample Object.  

### LoadExtendedAudioSample 
Load MP3, FLAC, WAV or OGG as new extended ExTAudioSample Object.  

### SaveTAudioSample 
Save BlitzMax TAudioSample as WAV.  

### SaveExTAudioSample 
Save new extended TAudioSample as WAV.  

### SaveWavBank 
Save a TBank as WAV File.  

### OpenWavFile 
Special Open WAV File for Writing.  

### WriteWavFile 
Special Write data to WAV File.
  
### CloseWavFile 
Close special WAV File.
  
### ConvertAudioSample 
Convert TAudioSample into a ExTAudioSample.
  
### ConvertAudioSample_II ConvertAudioSample_II
Convert  TAudioSample into a TBank.   


## Type ExTAudioSample:

### Create 
Create Extended TAudio Object.  

### Samples 
Sample-Pointer to audio data.  

### ExtractChannel 
Extract one Channel from a ExTAudioSample.  

### ImportChannel 
Imports one Channel into a ExTAudioSample.  
Clear Clears the Sample Buffer.  
