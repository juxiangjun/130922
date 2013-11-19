//
//  RTMPFileGetter.h
//  TestLib
//
//  Created by Vladimir Boychentsov on 11/26/10.
//  Copyright 2010 www.injoit.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RD_SUCCESS		0
#define RD_FAILED		1
#define RD_INCOMPLETE		2

#define DEF_TIMEOUT	30	/* seconds */
#define DEF_BUFTIME	(10 * 60 * 60 * 1000)	/* 10 hours default */
#define DEF_SKIPFRM	0

#define	SET_BINMODE(f)

#define STR2AVAL(av,str)	av.av_val = str; av.av_len = strlen(av.av_val)


#include <rtmp_sys.h>
#include <log.h>
#include <rtmp.h>

@class RTMPFileDownloader;

@protocol RTMPFileDownloaderDelegate;

int Download(RTMP * rtmp,		
			 FILE * file, 
			 uint32_t dSeek, 
			 uint32_t dStopOffset, 
			 double duration, 
			 int bResume, 
			 char *metaHeader, 
			 uint32_t nMetaHeaderSize, 
			 char *initialFrame, 
			 int initialFrameType, 
			 uint32_t nInitialFrameSize, 
			 int nSkipKeyFrames, 
			 int bStdoutMode, 
			 int bLiveStream, 
			 int bHashes, 
			 int bOverrideBufferTime, 
			 uint32_t bufferTime, 
			 double *percent,
			 RTMPFileDownloader *object
			 );

@interface RTMPFileDownloader : UIProgressView {

	
	id<RTMPFileDownloaderDelegate> delegate;
	
	NSString *url;
	NSString *writeToFile;
	BOOL rewrite;
	
@private
	
	int nStatus;
	double percent;
	double duration;
	
	int nSkipKeyFrames;	// skip this number of keyframes when resuming
	
	int bOverrideBufferTime;	// if the user specifies a buffer time override this is true
	int bStdoutMode;	// if true print the stream directly to stdout, messages go to stderr
	int bResume;		// true in resume mode
	uint32_t dSeek;		// seek position in resume mode, 0 otherwise
	uint32_t bufferTime;
	
	// meta header and initial frame for the resume mode (they are read from the file and compared with
	// the stream we are trying to continue
	char *metaHeader;
	uint32_t nMetaHeaderSize;
	
	// video keyframe for matching
	char *initialFrame;
	uint32_t nInitialFrameSize;
	int initialFrameType;	// tye: audio or video
	
	AVal hostname;
	AVal playpath;
	AVal subscribepath;
	int port;
	int protocol;
	int retries;
	int bLiveStream;	// is it a live stream? then we can't seek/resume
	int bHashes;		// display byte counters not hashes by default
	
	long int timeout;	// timeout connection after 120 seconds
	uint32_t dStartOffset;	// seek position in non-live mode
	uint32_t dStopOffset;
	RTMP rtmp;
	
	AVal swfUrl;
	AVal tcUrl;
	AVal pageUrl;
	AVal app;
	AVal auth;
	AVal swfHash;
	uint32_t swfSize;
	AVal flashVer;
	AVal sockshost;
	
	BOOL started;
	
}

@property (nonatomic, assign) id<RTMPFileDownloaderDelegate> delegate;

@property (nonatomic, retain, readonly) NSString *url;
@property (nonatomic, retain) NSString *writeToFile;
@property BOOL rewrite, started;


- (int) downloadAtString: (NSString*)_url;

- (void) setResumeFromMs:(int)r;

- (NSString*) filePath;
- (void) clean;

@end




@protocol RTMPFileDownloaderDelegate<NSObject>

@optional

- (void) didStartDownloadRTMPFile:(RTMPFileDownloader*)rtmpDownloader duration:(float)duration;
- (void) didFinishDownloadRTMPFile:(RTMPFileDownloader*)rtmpDownloader;
- (void) didFailDownloadRTMPFile:(RTMPFileDownloader *)rtmpDownloader;

- (void) downloaderRTMPFile:(RTMPFileDownloader *)rtmpDownloader didReceiveData:(NSData*)data;
- (void) downloaderRTMPFile:(RTMPFileDownloader *)rtmpDownloader didReceiveSeek:(int)ms andPrecent:(float)precent;

@end
