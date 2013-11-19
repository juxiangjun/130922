//
//  ApplicationInterface.h
//  rtmpdumplib
//
//  Created by aftek aftek on 28/07/10.
//  Copyright 2010 aftek. All rights reserved.
// Aftek Ltd (http://www.aftek.com).
#ifndef __APP_INT__
#define __APP_INT__
typedef enum
{
	FORMAT_PCM_PLATFORM_ENDIAN=0,
	FORMAT_ADPCM,
	FORMAT_MP3, FORMAT_PCM_LITTLE_ENDIAN,FORMAT_NELLYMOSER_16KHZ_MONO,FORMAT_NELLYMOSER_8KHZ_MONO,
	FORMAT_NELLYMOSER,FORMAT_G711_A_LAW_PCM,FORMAT_G711_MU_LAW_PCM,FORMAT_ACC,FORMAT_SPEEX,FORMAT_MP3_8KHZ,
	FORMAT_DEVICE_SPECIFIC
	
}RTMP_AUDIO_FORMAT;

typedef enum
{
	JPEG=0,
	H263VIDEOPACKET,
	SCREENVIDEOPACKET, VP6FLVVIDEOPACKET,VP6FLVALPHAVIDEOPACKET,SCREENV2VIDEOPACKET,
	AVCVIDEOPACKET
	
}RTMP_VIDEO_FORMAT;
typedef struct rtmp_audio
{
	char data[1024 *10];
	int size;
	short sample_size;
	short channel;
	short sample_rate;
	RTMP_AUDIO_FORMAT format;			
	
}rtmp_audio;

typedef struct rtmp_video
{
	char data[320*480*3];
	int size;
	int count;
}rtmp_video;

typedef struct rtmp_metadata
{
	float duration;
	float width;
	float height;
	float video_data_rate;
	float framerate;
	float video_codec_id;
	float audio_data_rate;
	float audio_sample_rate;
	float audio_sample_size;
	float stereo;
	float audio_codec_id;
	float file_size;
}rtmp_metadata;

#endif