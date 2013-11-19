//
//  RTMPFileGetter.m
//  TestLib
//
//  Created by Vladimir Boychentsov on 11/26/10.
//  Copyright 2010 www.injoit.com. All rights reserved.
//


#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <stdio.h>

#include <getopt.h>

#include <rtmp_sys.h>
#include <log.h>
#include <rtmp.h>


#import "RTMPFileDownloader.h"




@implementation RTMPFileDownloader

@synthesize delegate;
@synthesize url;

@synthesize writeToFile;
@synthesize rewrite;

@synthesize started;

- (id) init {
	self = [super init];
	if (self) {
		[self clean];
		return self;
	}
	return nil;
}

- (id) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self clean];
		return self;
	}
	return nil;
}



- (void) dealloc {
	RTMP_DeleteStream(&rtmp);
	RTMP_Close(&rtmp);
	[url release];
	[writeToFile release];
	[super dealloc];
}


- (void) clean {
	
	if (RTMP_IsConnected(&rtmp)) {
		RTMP_DeleteStream(&rtmp);
		RTMP_Close(&rtmp);
	}
	
	nStatus = RD_SUCCESS;
	percent = 0;
	duration = 0.0;
	
	writeToFile = nil;
	
	nSkipKeyFrames = DEF_SKIPFRM;	// skip this number of keyframes when resuming
	
	bOverrideBufferTime = FALSE;	// if the user specifies a buffer time override this is true
	bStdoutMode = TRUE;	// if true print the stream directly to stdout, messages go to stderr
	bResume = FALSE;		// true in resume mode
	dSeek = 0;		// seek position in resume mode, 0 otherwise
	bufferTime = DEF_BUFTIME;
	
	// meta header and initial frame for the resume mode (they are read from the file and compared with
	// the stream we are trying to continue
	metaHeader = 0;
	nMetaHeaderSize = 0;
	
	// video keyframe for matching
	initialFrame = 0;
	nInitialFrameSize = 0;
	initialFrameType = 0;	// tye: audio or video
	
	hostname = (AVal){ 0, 0 };
	playpath = (AVal){ 0, 0 };
	subscribepath = (AVal){ 0, 0 };
	port = -1;
	protocol = RTMP_PROTOCOL_UNDEFINED;
	retries = 0;
	bLiveStream = FALSE;	// is it a live stream? then we can't seek/resume
	bHashes = FALSE;		// display byte counters not hashes by default
	
	timeout = DEF_TIMEOUT;	// timeout connection after 120 seconds
	dStartOffset = 0;	// seek position in non-live mode
	dStopOffset = 0;
	rtmp = (RTMP){ 0 };
	
	swfUrl = (AVal){ 0, 0 };
	tcUrl = (AVal){ 0, 0 };
	pageUrl = (AVal){ 0, 0 };
	app = (AVal){ 0, 0 };
	auth = (AVal){ 0, 0 };
	swfHash = (AVal){ 0, 0 };
	swfSize = 0;
	flashVer = (AVal){ 0, 0 };
	sockshost = (AVal){ 0, 0 };
	
	
}


- (void) removeFile {
	[[NSFileManager defaultManager] removeItemAtPath:writeToFile error:nil];
}

- (NSString*) filePath {
	return writeToFile;
}


- (int) downloadAtString: (NSString*)_url; {
	
	started = NO;
	
	url = _url;
	
	char *opt = (char*)[self.url UTF8String];
	
	int first = 1;
	
	RTMP_Init(&rtmp);
	
	AVal parsedHost, parsedApp, parsedPlaypath;
	unsigned int parsedPort = 0;
	int parsedProtocol = RTMP_PROTOCOL_UNDEFINED;
	
	if (!RTMP_ParseURL(opt, &parsedProtocol, &parsedHost, &parsedPort, &parsedPlaypath, &parsedApp))
	{
		RTMP_Log(RTMP_LOGWARNING, "Couldn't parse the specified url (%s)!", opt);
	}
	else
	{
		if (!hostname.av_len)
			hostname = parsedHost;
		if (port == -1)
			port = parsedPort;
		if (playpath.av_len == 0 && parsedPlaypath.av_len)
		{
			playpath = parsedPlaypath;
		}
		if (protocol == RTMP_PROTOCOL_UNDEFINED)
			protocol = parsedProtocol;
		if (app.av_len == 0 && parsedApp.av_len)
		{
		    app = parsedApp;
		}
	}
	
	
	NSString *dPath = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
	
	if (writeToFile == nil) {
		writeToFile = [[NSString alloc] initWithCString:playpath.av_val encoding:NSUTF8StringEncoding];
		NSArray *arr = [writeToFile componentsSeparatedByString:@":"];
		writeToFile = [NSString stringWithFormat:@"%@.%@", [arr lastObject], [arr objectAtIndex:0]];
		writeToFile = [writeToFile lastPathComponent];
		writeToFile = [writeToFile stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
		writeToFile = [writeToFile stringByReplacingOccurrencesOfString:@" " withString:@"_"];
		//writeToFile = [dPath stringByAppendingPathComponent:writeToFile];		
		writeToFile = [dPath stringByAppendingPathComponent:@"songname.mp3"];		
	}
	
	FILE *file = fopen([writeToFile UTF8String], (rewrite)?"wb":"w+b");
	
	
	
	if (protocol == RTMP_PROTOCOL_UNDEFINED)
    {
		RTMP_Log(RTMP_LOGWARNING,
				 "You haven't specified a protocol or rtmp url.");
		protocol = RTMP_PROTOCOL_RTMP;
    }
	if (port == -1)
    {
		RTMP_Log(RTMP_LOGWARNING,
				 "You haven't specified a port or rtmp url, using default port 1935");
		port = 0;
    }
	if (port == 0)
    {
		if (protocol & RTMP_FEATURE_SSL)
			port = 443;
		else if (protocol & RTMP_FEATURE_HTTP)
			port = 80;
		else
			port = 1935;
    }
	
	if (tcUrl.av_len == 0)
    {
		char str[512] = { 0 };
		
		tcUrl.av_len = snprintf(str, 511, "%s://%.*s:%d/%.*s",
								RTMPProtocolStringsLower[protocol], hostname.av_len,
								hostname.av_val, port, app.av_len, app.av_val);
		tcUrl.av_val = (char *) malloc(tcUrl.av_len + 1);
		strcpy(tcUrl.av_val, str);
    }
	
	
	
	// User defined seek offset
	if (dStartOffset > 0)
    {
		// Live stream
		if (bLiveStream)
		{
			RTMP_Log(RTMP_LOGWARNING,
					 "Can't seek in a live stream, ignoring --start option");
			dStartOffset = 0;
		}
    }
	
	
	RTMP_SetupStream(&rtmp, protocol, &hostname, port, &sockshost, &playpath,
					 &tcUrl, &swfUrl, &pageUrl, &app, &auth, &swfHash, swfSize,
					 &flashVer, &subscribepath, dSeek, dStopOffset, bLiveStream, timeout);
	
	
	
	
	//dSeek = 823200;
	
	
	if (!bLiveStream && !(protocol & RTMP_FEATURE_HTTP))
		rtmp.Link.lFlags |= RTMP_LF_BUFX;
	
	
	
	while (1)
    {
		RTMP_Log(RTMP_LOGDEBUG, "Setting buffer time to: %dms", bufferTime);
		RTMP_SetBufferMS(&rtmp, bufferTime);
		
		if (first)
		{
			first = 0;
			RTMP_LogPrintf("Connecting ...");
			
			if (!RTMP_Connect(&rtmp, NULL))
			{
				nStatus = RD_FAILED;
				break;
			}
			
			RTMP_LogPrintf("Connected...");
			
			// User defined seek offset
			if (dStartOffset > 0)
			{
				// Don't need the start offset if resuming an existing file
				if (bResume)
				{
					RTMP_Log(RTMP_LOGWARNING,
							 "Can't seek a resumed stream, ignoring --start option");
					dStartOffset = 0;
				}
				else
				{
					dSeek = dStartOffset;
				}
			}
			
			// Calculate the length of the stream to still play
			if (dStopOffset > 0)
			{
				// Quit if start seek is past required stop offset
				if (dStopOffset <= dSeek)
				{
					RTMP_LogPrintf("Already Completed");
					nStatus = RD_SUCCESS;
					break;
				}
			}
			
			
			if (!RTMP_ConnectStream(&rtmp, dSeek))
			{
				nStatus = RD_FAILED;
				break;
			}
		}
		else
		{
			nInitialFrameSize = 0;
			
			if (retries)
            {
				RTMP_Log(RTMP_LOGERROR, "Failed to resume the stream\n\n");
				if (!RTMP_IsTimedout(&rtmp))
					nStatus = RD_FAILED;
				else
					nStatus = RD_INCOMPLETE;
				break;
            }
			RTMP_LogPrintf( "Connection timed out, trying to resume.");
			/* Did we already try pausing, and it still didn't work? */
			if (rtmp.m_pausing == 3)
            {
				/* Only one try at reconnecting... */
				retries = 1;
				dSeek = rtmp.m_pauseStamp;
				if (dStopOffset > 0)
                {
					if (dStopOffset <= dSeek)
                    {
						RTMP_LogPrintf("Already Completed\n");
						nStatus = RD_SUCCESS;
						break;
                    }
                }
				if (!RTMP_ReconnectStream(&rtmp, dSeek))
                {
					RTMP_Log(RTMP_LOGERROR, "Failed to resume the stream\n\n");
					if (!RTMP_IsTimedout(&rtmp))
						nStatus = RD_FAILED;
					else
						nStatus = RD_INCOMPLETE;
					break;
                }
            }
			else if (!RTMP_ToggleStream(&rtmp))
			{
				RTMP_Log(RTMP_LOGERROR, "Failed to resume the stream\n\n");
				if (!RTMP_IsTimedout(&rtmp))
					nStatus = RD_FAILED;
				else
					nStatus = RD_INCOMPLETE;
				break;
			}
			bResume = TRUE;
		}
		
		
		
		NSLog(@"download request");
		nStatus = Download(&rtmp, 
						   file, 
						   dSeek, 
						   dStopOffset, 
						   duration, 
						   bResume,
						   metaHeader, 
						   nMetaHeaderSize, 
						   initialFrame,
						   initialFrameType, 
						   nInitialFrameSize,
						   nSkipKeyFrames, 
						   bStdoutMode, 
						   bLiveStream, 
						   bHashes,
						   bOverrideBufferTime, 
						   bufferTime, 
						   &percent,
						   self);
		
		
		
				
		free(initialFrame);
		initialFrame = NULL;
		
		/* If we succeeded, we're done.
		 */
		if (nStatus != RD_INCOMPLETE || !RTMP_IsTimedout(&rtmp) || bLiveStream)
			break;
    }
	
	
	if (nStatus == RD_SUCCESS)
    {
		RTMP_LogPrintf("Download complete\n");
    }
	else if (nStatus == RD_INCOMPLETE)
    {
		RTMP_LogPrintf("Download may be incomplete (downloaded about %.2f%%), try resuming\n",
		 percent);
    }
	
	
	
	
	RTMP_Close(&rtmp);
	
	fclose(file);
	
	return 1;
}

- (void) setResumeFromMs:(int)r {
	dSeek = r;
	bResume = 1;
}


#pragma mark -
#pragma mark protocol

- (void) setProgressValue:(NSNumber*)value {
	[self setProgress:[value floatValue]];
	[self setNeedsDisplay];
}

- (void) downloaderRTMPFile:(RTMPFileDownloader *)rtmpDownloader didReceiveSeek:(int)ms andPrecent:(float)precent {
	[self.delegate downloaderRTMPFile:rtmpDownloader didReceiveSeek:ms andPrecent:precent];
	[self performSelectorOnMainThread:@selector(setProgressValue:)
									 withObject:[NSNumber numberWithFloat:((float)precent/100.0f)]
								  waitUntilDone:YES];
}


#pragma mark -
#pragma mark function


int Download(RTMP * rtmp,		// connected RTMP object
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
			 )	// percentage downloaded [out]
{
	int32_t now, lastUpdate;
	int bufferSize = 64 * 1024;
	char *buffer = (char *) malloc(bufferSize);
	int nRead = 0;
	off_t size = ftello(file);
	unsigned long lastPercent = 0;
	
	rtmp->m_read.timestamp = dSeek;
	
	*percent = 0.0;
	
	if (rtmp->m_read.timestamp)
    {
		RTMP_Log(RTMP_LOGDEBUG, "Continuing at TS: %d ms\n", rtmp->m_read.timestamp);
    }
	
	if (bLiveStream)
    {
		RTMP_LogPrintf("Starting Live Stream\n");
    }
	else
    {
		// print initial status
		// Workaround to exit with 0 if the file is fully (> 99.9%) downloaded
		if (duration > 0)
		{
			if ((double) rtmp->m_read.timestamp >= (double) duration * 999.0)
			{
				RTMP_LogPrintf("Already Completed at: %.3f sec Duration=%.3f sec\n",
							   (double) rtmp->m_read.timestamp / 1000.0,
							   (double) duration / 1000.0);
				return RD_SUCCESS;
			}
			else
			{
				*percent = ((double) rtmp->m_read.timestamp) / (duration * 1000.0) * 100.0;
				*percent = ((double) (int) (*percent * 10.0)) / 10.0;
				RTMP_LogPrintf("%s download at: %.3f kB / %.3f sec (%.1f%%)\n",
							   bResume ? "Resuming" : "Starting",
							   (double) size / 1024.0, (double) rtmp->m_read.timestamp / 1000.0,
							   *percent);
			}
		}
		else
		{
			RTMP_LogPrintf("%s download at: %.3f kB\n",
						   bResume ? "Resuming" : "Starting",
						   (double) size / 1024.0);
		}
    }
	
	if (dStopOffset > 0)
		RTMP_LogPrintf("For duration: %.3f sec\n", (double) (dStopOffset - dSeek) / 1000.0);
	
	if (bResume && nInitialFrameSize > 0)
		rtmp->m_read.flags |= RTMP_READ_RESUME;
	rtmp->m_read.initialFrameType = initialFrameType;
	rtmp->m_read.nResumeTS = dSeek;
	rtmp->m_read.metaHeader = metaHeader;
	rtmp->m_read.initialFrame = initialFrame;
	rtmp->m_read.nMetaHeaderSize = nMetaHeaderSize;
	rtmp->m_read.nInitialFrameSize = nInitialFrameSize;
	
	
//	BOOL first = 1;
	
	now = RTMP_GetTime();
	lastUpdate = now - 1000;
	do
    {
		nRead = RTMP_Read(rtmp, buffer, bufferSize);

		
		
		if (nRead > 0)
		{
			
			//RTMP_LogPrintf("write %dbytes (%.1f kB)\n", nRead, nRead/1024.0);
			if (duration <= 0) {	// if duration unknown try to get it from the stream (onMetaData)
				duration = RTMP_GetDuration(rtmp);
				
				if ([object.delegate respondsToSelector:@selector(didStartDownloadRTMPFile:duration:)]) {
					object.started = YES;
					[object.delegate didStartDownloadRTMPFile:object duration:duration];
				}
			}
			
			if (object.started) {

				if (fwrite(buffer, sizeof(unsigned char), nRead, file) !=
					(size_t) nRead)
				{
					
					RTMP_Log(RTMP_LOGERROR, "%s: Failed writing, exiting!", __FUNCTION__);
					free(buffer);
					return RD_FAILED;
				}				
				
				
				size += nRead;
				
			}
			
			
			
			if (duration > 0)
			{
				// make sure we claim to have enough buffer time!
				if (!bOverrideBufferTime && bufferTime < (duration * 1000.0))
				{
					bufferTime = (uint32_t) (duration * 1000.0) + 5000;	// extra 5sec to make sure we've got enough
					
					RTMP_Log(RTMP_LOGDEBUG,
							 "Detected that buffer time is less than duration, resetting to: %dms",
							 bufferTime);
					RTMP_SetBufferMS(rtmp, bufferTime);
					RTMP_UpdateBufferMS(rtmp);
				}
				*percent = ((double) rtmp->m_read.timestamp) / (duration * 1000.0) * 100.0;
				*percent = ((double) (int) (*percent * 10.0)) / 10.0;
				if (bHashes)
				{
					if (lastPercent + 1 <= *percent)
					{
						RTMP_LogStatus("#");
						lastPercent = (unsigned long) *percent;
					}
				}
				else
				{
					now = RTMP_GetTime();
					if (abs(now - lastUpdate) > 200)
					{
						
						float prc = (float) *percent;
						RTMP_LogStatus("\r%.3f kB / %.2f sec (%.1f%%)",
									   (double) size / 1024.0,
									   (double) (rtmp->m_read.timestamp) / 1000.0, prc);
						
						if ([object.delegate respondsToSelector:@selector(downloaderRTMPFile:didReceiveSeek:andPrecent:)]) {
							[object downloaderRTMPFile:object didReceiveSeek:rtmp->m_read.timestamp andPrecent:prc];
						}
						
						lastUpdate = now;
					}
				}
			}
			else
			{
				now = RTMP_GetTime();
				if (abs(now - lastUpdate) > 200)
				{
					if (bHashes)
						RTMP_LogStatus("#");
					else
						RTMP_LogStatus("\r%.3f kB / %.2f sec", (double) size / 1024.0,
									   (double) (rtmp->m_read.timestamp) / 1000.0);
					lastUpdate = now;
				}
			}
		}
#ifdef _DEBUG
		else
		{
			RTMP_Log(RTMP_LOGDEBUG, "zero read!");
		}
#endif
		
    }
	while (!RTMP_ctrlC && nRead > -1 && RTMP_IsConnected(rtmp) && !RTMP_IsTimedout(rtmp));
	free(buffer);
	if (nRead < 0)
		nRead = rtmp->m_read.status;
	
	/* Final status update */
	if (!bHashes)
    {
		if (duration > 0)
		{
			*percent = ((double) rtmp->m_read.timestamp) / (duration * 1000.0) * 100.0;
			*percent = ((double) (int) (*percent * 10.0)) / 10.0;
			
			float prc = (float) *percent;
			
			RTMP_LogStatus("\r%.3f kB / %.2f sec (%.1f%%)",
						   (double) size / 1024.0,
						   (double) (rtmp->m_read.timestamp) / 1000.0, prc);
			
			if ([object.delegate respondsToSelector:@selector(downloaderRTMPFile:didReceiveSeek:andPrecent:)]) {
				[object downloaderRTMPFile:object didReceiveSeek:rtmp->m_read.timestamp andPrecent:prc];
			}
			
		}
		else
		{
			RTMP_LogStatus("\r%.3f kB / %.2f sec", (double) size / 1024.0,
						   (double) (rtmp->m_read.timestamp) / 1000.0);
		}
    }
	
	RTMP_Log(RTMP_LOGDEBUG, "RTMP_Read returned: %d", nRead);
	
	if (bResume && nRead == -2)
    {
		RTMP_LogPrintf("Couldn't resume FLV file, try --skip %d\n\n",
					   nSkipKeyFrames + 1);
		return RD_FAILED;
    }
	
	if (nRead == -3)
		return RD_SUCCESS;
	
	if ((duration > 0 && *percent < 99.9) || RTMP_ctrlC || nRead < 0
		|| RTMP_IsTimedout(rtmp))
    {
		return RD_INCOMPLETE;
    }
	
	return RD_SUCCESS;
}


@end
