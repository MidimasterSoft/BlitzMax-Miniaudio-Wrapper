//*************************************************************************
// version info 1.26
// 2021-06-14: debug information only in debug version
// this code is public domain
// author: Peter Wolkersdorfer www.midimaster
// thanks to col from https://github.com/davecamp
//************************************************************************


#if !defined(NDEBUG)
	#define DEBUG_OUTPUT(...) printf(__VA_ARGS__); fflush(0)
	#define MA_DEBUG_OUTPUT
#else
	#define DEBUG_OUTPUT
#endif

#include <brl.mod/blitz.mod/blitz.h>
#define STB_VORBIS_HEADER_ONLY
#include "stb_vorbis.c"    // Enables Vorbis decoding.




// COL workaround for BlitzMax thread register Needs minimum miniaudio.h version 0.10.36 or 0.11.01 and higher!!!
typedef struct mimaThread mimaThread;
struct mimaThread {
	mimaThread* Next;
	BBThread* Thread;
};

mimaThread* maThreads;

#ifdef WIN32
void mimaOnMAThreadEntry() {
	DWORD id = GetCurrentThreadId();
	DEBUG_OUTPUT("Registering thread id: %d\n", id);
	mimaThread* maThread = (mimaThread*)malloc(sizeof(mimaThread));
	maThread->Next = maThreads;
	maThread->Thread = bbThreadRegister(id);
	maThreads = maThread;
}
void mimaOnMAThreadExit() {
	DWORD id = GetCurrentThreadId();
	DEBUG_OUTPUT("Unregistering thread id: %d\n", id);
	mimaThread** Threads = &maThreads;
	mimaThread* ThisThread;
	while(ThisThread = *Threads)
		if(ThisThread->Thread->id == id) {
			*Threads = ThisThread->Next;
			bbThreadUnregister(ThisThread->Thread);
			free(ThisThread);
			break;
		}
		else
			Threads = &ThisThread->Next;
}
#else
void mimaOnMAThreadEntry() {
	void* handle = pthread_self();
	DEBUG_OUTPUT("Registering thread handle: 0x%08x\n", handle);
	mimaThread* maThread = (mimaThread*)malloc(sizeof(mimaThread));
	maThread->Next = maThreads;
	maThread->Thread = bbThreadRegister(handle);
	maThreads = maThread;
}
void mimaOnMAThreadExit() {
	void* handle = pthread_self();
	DEBUG_OUTPUT("Unregistering thread handle: 0x%08x\n", handle);
	mimaThread** Threads = &maThreads;
	mimaThread* ThisThread;
	while(ThisThread = *Threads)
		if(ThisThread->Thread->handle == handle) {
			*Threads = ThisThread->Next;
			bbThreadUnregister(ThisThread->Thread);
			free(ThisThread);
			break;
		}
		else
			Threads = &ThisThread->Next;
}
#endif

#define MA_ON_THREAD_ENTRY mimaOnMAThreadEntry();
#define MA_ON_THREAD_EXIT mimaOnMAThreadExit();
// end COL


#define MINIAUDIO_IMPLEMENTATION
#define MA_API extern
//#define MA_DEBUG_OUTPUT 
#define MA_LOG_LEVEL_INFO 4
#define MA_LOG_LEVEL MA_LOG_LEVEL_INFO
//#define MA_BLITZMAX_THREAD_COMPATIBILITY

#include "miniaudiox.h"

// The stb_vorbis implementation must come after the implementation of miniaudio.
#undef STB_VORBIS_HEADER_ONLY
#include "stb_vorbis.c"

#include <stdio.h>
#include <string.h>




// save WAV files
int MM_SaveWav(char* FileName, void *pPCMFramesToWrite, int frames, int format, int channels, int hertz){
	DEBUG_OUTPUT("MM ENCODER WAV ONE PASS \n");

	ma_encoder_config config = ma_encoder_config_init(ma_resource_format_wav, format, channels, hertz);
	ma_encoder encoder;
	ma_result result = ma_encoder_init_file(FileName, &config, &encoder);
	if (result != MA_SUCCESS) {
		DEBUG_OUTPUT("ERROR while defining WAV file \n");
		return 0;
	}
	int framesWritten = ma_encoder_write_pcm_frames(&encoder, pPCMFramesToWrite, frames);
	ma_encoder_uninit(&encoder);
	DEBUG_OUTPUT("------ \n");
	return 1;
}




// Get WAV encoder
struct ma_encoder  *MM_GetEncoder(char* FileName, int format, int channels, int hertz){
	DEBUG_OUTPUT("MM GET ENCODER WAV \n");

	ma_encoder_config config = ma_encoder_config_init(ma_resource_format_wav, format, channels, hertz);
	struct ma_encoder *encoder;
	int length = sizeof(struct ma_encoder);
	encoder = (struct ma_encoder*) malloc(length);

	ma_result result = ma_encoder_init_file(FileName, &config, encoder);
	if (result != MA_SUCCESS) {
		DEBUG_OUTPUT("ERROR while defining WAV encoder \n");
		return NULL;
	}
	DEBUG_OUTPUT("------ \n");
	return encoder;
}




// write to WAV encoder
int MM_WriteEncoder(ma_encoder *encoder, void *pPCMFramesToWrite, int frames){
	DEBUG_OUTPUT("MM WRITE TO ENCODER WAV \n");

	int framesWritten = ma_encoder_write_pcm_frames(encoder, pPCMFramesToWrite, frames);
		DEBUG_OUTPUT("------ \n");
	return 1;
}




// enumerate hardware devices:
struct ma_context *MM_GetContext(char* list){
	DEBUG_OUTPUT("MM CREATE CONTEXT \n");
	struct ma_context *instance;
	//int length = sizeof(struct ma_context);
	int length =ma_context_sizeof();
    DEBUG_OUTPUT("length of  context %i  \n",length);
	instance = (struct ma_context*) malloc(length);
	
    if (ma_context_init(NULL, 0, NULL, instance) != MA_SUCCESS) {
        DEBUG_OUTPUT("ERROR #mm1 while ma_context_init \n");
		return NULL;	
    }
    ma_device_info* pPlaybackInfos;
    ma_uint32 playbackCount;
    ma_device_info* pCaptureInfos;
    ma_uint32 captureCount;
    if (ma_context_get_devices(instance, &pPlaybackInfos, &playbackCount, &pCaptureInfos, &captureCount) != MA_SUCCESS) {
        DEBUG_OUTPUT("ERROR #mm2 while ma_context_get_devices \n");
		return NULL;	
    }
	DEBUG_OUTPUT("list of playback devices: \n");
    ma_uint32 iDevice;
    for (iDevice = 0; iDevice < playbackCount; iDevice += 1) {
		strncat(list , pPlaybackInfos[iDevice].name, 9999);
		strncat(list , "||", 9999);
        DEBUG_OUTPUT("%d - %s  \n", iDevice, pPlaybackInfos[iDevice].name);
    }
	strncat(list , "|IN||", 9999);
	DEBUG_OUTPUT("list of capture devices: \n");
    for (iDevice = 0; iDevice < captureCount; iDevice += 1) {
		strncat(list , pCaptureInfos[iDevice].name, 9999);
		strncat(list , "||", 9999);
        DEBUG_OUTPUT("%d - %s\n", iDevice, pCaptureInfos[iDevice].name);
    }
	strncat(list , "|END", 9999);
	DEBUG_OUTPUT("** end of context ************************* \n");
	return instance;
}




//one pass converting:
int MM_Convert(void* pOut, int frames, int format, int channels, int hertz, void* pIn, int SizeIn, int FormatIn, int ChannelsIn, int HertzIn){
	DEBUG_OUTPUT("MM CONVERTER ONE PASS \n");
	int result = ma_convert_frames( pOut, frames, format, channels, hertz, pIn, SizeIn, FormatIn, ChannelsIn, HertzIn);
	DEBUG_OUTPUT("------ \n");
	return result;	
}




//only decoding parameters:
int MM_DecodeParameter(char* FileName, int *frames, int* sampleRate, int* channels, int* format){
	DEBUG_OUTPUT("MM DECODER PARAMETER \n");
	//ma_decoder_config audioConfig = ma_decoder_config_init(ma_format_s16, 0, 0);
	ma_decoder_config audioConfig = ma_decoder_config_init(0, 0, 0);
	long long frameCount;
	short* pAudioData;
	int result = ma_decode_file(FileName, &audioConfig, &frameCount, &pAudioData);
	if (result != 0) {
		return 0;
	}
	*sampleRate = audioConfig.sampleRate;
	*channels = audioConfig.channels;
	*format = audioConfig.format;
	*frames = frameCount;
	DEBUG_OUTPUT("rate=%i  channels=%i  size=%i    format=%i  ------ \n", *sampleRate, *channels, *frames, *format);
	DEBUG_OUTPUT("------ \n");

	return 1;
}




//one pass decoding 16bit:
int MM_Decode16bit(char* FileName, short *TSampleRAM){
	DEBUG_OUTPUT("MM DECODER ONE PASS 16bit  \n");
	ma_decoder_config audioConfig = ma_decoder_config_init(ma_format_s16, 0, 0);
	long long frameCount;
	short* pAudioData;
	int result = ma_decode_file(FileName, &audioConfig, &frameCount, &pAudioData);
	if(audioConfig.channels>2){
		DEBUG_OUTPUT("ERROR NOT MONO or STEREO!!! Channels=%i \n", audioConfig.channels );
		return 0;
	}	
    int i;
	for (i=0; i<(frameCount*audioConfig.channels); i++){
		TSampleRAM[i] =  pAudioData[i];
	}
	DEBUG_OUTPUT("------ \n");
	return 1;	
}





//one pass decoding 32bit float:
int MM_Decode(char* FileName, float *TSampleRAM){
	DEBUG_OUTPUT("MM DECODER ONE PASS 32bit \n");
	ma_decoder_config audioConfig = ma_decoder_config_init(ma_format_f32, 0, 0);
	long long frameCount;
	float* pAudioData;
	int result = ma_decode_file(FileName, &audioConfig, &frameCount, &pAudioData);
    
	int i;
	for (i=0; i<(frameCount*audioConfig.channels); i++){
		TSampleRAM[i] =  pAudioData[i];
	}
	DEBUG_OUTPUT("------ \n");
	return 1;	
}



//one pass decoding 32bit int:
int MM_Decode32(char* FileName, int *TSampleRAM){
	DEBUG_OUTPUT("MM DECODER ONE PASS 32bit \n");
	ma_decoder_config audioConfig = ma_decoder_config_init(ma_format_s32, 0, 0);
	long long frameCount;
	int* pAudioData;
	int result = ma_decode_file(FileName, &audioConfig, &frameCount, &pAudioData);
    
	int i;
	for (i=0; i<(frameCount*audioConfig.channels); i++){
		TSampleRAM[i] =  pAudioData[i];
	}
	DEBUG_OUTPUT("------ \n");
	return 1;	
}






// call for config:
struct ma_device_config *ma_device_config_init_glue(struct ma_context *context, int DeviceTyp, int ID_Playback, int ID_Capture) {
		DEBUG_OUTPUT("START_DEVICE_GLUE \n");
		struct ma_device_config *config;
		int length = sizeof(struct ma_device_config);
		config = (struct ma_device_config*) malloc(length);	
		*config= ma_device_config_init(DeviceTyp);

		ma_device_info* pPlaybackInfos;
		ma_uint32 playbackCount;
		ma_device_info* pCaptureInfos;
		ma_uint32 captureCount;
		if (ma_context_get_devices(context, &pPlaybackInfos, &playbackCount, &pCaptureInfos, &captureCount) != MA_SUCCESS) {
			DEBUG_OUTPUT("ERROR #mm3 while ma_context_get_devices \n");
			return NULL;	
		}
		if(ID_Playback>-1){
			config->playback.pDeviceID = &pPlaybackInfos[ID_Playback].id;		
		} else{
			config->playback.pDeviceID = NULL;
		}
		if(ID_Capture>-1){
			config->capture.pDeviceID = &pCaptureInfos[ID_Capture].id;		
		} else{
			config->capture.pDeviceID = NULL;
		}
		//DEBUG_OUTPUT("selected playback device %i %s \n",ID_Playback, pPlaybackInfos[ID_Playback].name);
	DEBUG_OUTPUT("------ \n");
	return config;
}




// Device Filler:
void MM_SetDeviceConfig (struct ma_device_config *config, int playformat, int playchannels, int captformat, int captchannels, int hertz, ma_device_callback_proc Callback) {
	DEBUG_OUTPUT("FILL_VALUE_B \n");
	config->sampleRate        = hertz;
	config->playback.format   = playformat;
	config->playback.channels = playchannels;
	config->capture.format    = captformat;
	config->capture.channels  = captchannels;
	config->dataCallback      = Callback;
	DEBUG_OUTPUT("------ \n");
}




// Call for the device
struct ma_device *MM_GetDevice(struct ma_device_config *config , struct ma_context *context) {
	DEBUG_OUTPUT("CREATE A DEVICE \n");
	struct ma_device *device;

	int length = sizeof(struct ma_device);
	device = (struct ma_device*) malloc(length);
	if (ma_device_init(context, config, device) != MA_SUCCESS) {
		DEBUG_OUTPUT("ERROR #mm4 while ma_device_init \n");
		return NULL;
	}
	DEBUG_OUTPUT("------ \n");
	return device;	 

}



