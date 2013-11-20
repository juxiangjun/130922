//
//  RecorderManager.mm
//  OggSpeex
//
//  Created by Jiang Chuncheng on 6/25/13.
//  Copyright (c) 2013 Sense Force. All rights reserved.
//

#import "RecorderManager.h"
#import "AQRecorder.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "FLVTag.h"

#define PACKAGE_SIZE 256

@interface RecorderManager()

- (void)updateLevelMeter:(id)sender;
- (void)stopRecording:(BOOL)isCanceled;

@end

@implementation RecorderManager

@synthesize dateStartRecording, dateStopRecording;
@synthesize encapsulator;
@synthesize timerLevelMeter;
@synthesize timerTimeout;

static RecorderManager *mRecorderManager = nil;
AQRecorder *mAQRecorder;
AudioQueueLevelMeterState *levelMeterStates;

+ (RecorderManager *)sharedManager {
    @synchronized(self) {
        if (mRecorderManager == nil)
        {
            mRecorderManager = [[self alloc] init];
        }
    }
    return mRecorderManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if(mRecorderManager == nil)
        {
            mRecorderManager = [super allocWithZone:zone];
            return mRecorderManager;
        }
    }
    
    return nil;
}

-(void) putData:(NSData *)data {
    NSLog(@"put encoded data into queue. %d", [data length]);
    [queue appendData:data];
    
    if ([queue length] > PACKAGE_SIZE) {
        /**get date from first 100*/
        NSData *packageData = [queue subdataWithRange: NSMakeRange(0, PACKAGE_SIZE)];
        NSData *tmp = [queue subdataWithRange:NSMakeRange(PACKAGE_SIZE, [queue length] - PACKAGE_SIZE)];
        queue = [[NSMutableData alloc] initWithData:tmp];
        
        if (baseTime == 0) {
            timestamp = 0;
            baseTime = CFAbsoluteTimeGetCurrent() * 1000;
        } else {
            double now = CFAbsoluteTimeGetCurrent()* 1000;
            timestamp = (int) (now - baseTime);
        }
        
        dataLength     = [packageData length] + 1;
        FLVTag *tag = [[FLVTag alloc] initWithTagData:previousTagSize :timestamp :packageData ];
        
        NSData *data = [tag getTagData];
        RTMPPacket packet = {0};
        RTMPPacket_Reset(&packet);
        char *buffer =(char *)[data bytes];
        packet.m_headerType = RTMP_PACKET_SIZE_MEDIUM;
        packet.m_packetType = RTMP_PACKET_TYPE_AUDIO;
        packet.m_nChannel = 0x04;
        packet.m_body = buffer;
        packet.m_nInfoField2 = connPublish->m_stream_id;
        packet.m_nBodySize = [data length];
        //packet.m_nBodySize = 132;
        packet.m_nTimeStamp = timestamp;
        RTMP_SendPacket(connPublish, &packet, 0);
        //RTMP_Write(connPublish, buffer, [data length]   );
        previousTagSize = dataLength + 11;
        [flvFile addTag:tag];
        
    }
}

- (void)startRecording {
    if ( ! mAQRecorder) {
        
        queue = [[NSMutableData alloc] init];
        mAQRecorder = new AQRecorder();
        
        baseTime = 0;
        previousTagSize = 0;
        
        flvFile = [[FLVFIle alloc] initWithFileName:@"test.flv"];
        
        
        const char *rtmpURL ="rtmp://192.168.7.96:1935/oflaDemo/998";
        connPublish = RTMP_Alloc();
        RTMP_Init(connPublish);
        RTMP_SetupURL(connPublish, (char*) rtmpURL);
        RTMP_EnableWrite(connPublish);
        RTMP_Connect(connPublish, NULL);
        RTMP_ConnectStream(connPublish,0);
        
        
        NSLog(@"ready to sleep.");
        [NSThread sleepForTimeInterval:2.0];
        NSLog(@"waked up.");

        
        OSStatus error = AudioSessionInitialize(NULL, NULL, interruptionListener, (__bridge void *)self);
        if (error) printf("ERROR INITIALIZING AUDIO SESSION! %d\n", (int)error);
        else
        {
            UInt32 category = kAudioSessionCategory_PlayAndRecord;
            error = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
            if (error) printf("couldn't set audio category!");
            
            error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, propListener, (__bridge void *)self);
            if (error) printf("ERROR ADDING AUDIO SESSION PROP LISTENER! %d\n", (int)error);
            UInt32 inputAvailable = 0;
            UInt32 size = sizeof(inputAvailable);
            
            // we do not want to allow recording if input is not available
            error = AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable, &size, &inputAvailable);
            if (error) printf("ERROR GETTING INPUT AVAILABILITY! %d\n", (int)error);
            
            // we also need to listen to see if input availability changes
            error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioInputAvailable, propListener, (__bridge void *)self);
            if (error) printf("ERROR ADDING AUDIO SESSION PROP LISTENER! %d\n", (int)error);
            
            error = AudioSessionSetActive(true); 
            if (error) printf("AudioSessionSetActive (true) failed");
        }
        
    }
    
    filename = [NSString stringWithString:[Encapsulator defaultFileName]];
    NSLog(@"filename:%@",filename);
    
//    if (self.encapsulator) {
//        self.encapsulator.delegete = nil;
//        [self.encapsulator release];
//    }
//    self.encapsulator = [[[Encapsulator alloc] initWithFileName:filename] autorelease];
//    self.encapsulator.delegete = self;
    
    if ( ! self.encapsulator) {
        self.encapsulator = [[Encapsulator alloc] initWithFileName:filename :self];
        self.encapsulator.delegete = self;
    }
    else {
        [self.encapsulator resetWithFileName:filename];
    }
    
    if ( ! mAQRecorder->IsRunning()) {
        NSLog(@"audio session category : %@", [[AVAudioSession sharedInstance] category]);
        Boolean recordingWillBegin = mAQRecorder->StartRecord(encapsulator);
        if ( ! recordingWillBegin) {
            if ([self.delegate respondsToSelector:@selector(recordingFailed:)]) {
                [self.delegate recordingFailed:@"程序错误，无法继续录音，请重启程序试试"];
            }
            return;
        }
    }

    self.dateStartRecording = [NSDate date];
    
    if (!levelMeterStates)
    {
        levelMeterStates = (AudioQueueLevelMeterState *)malloc(sizeof(AudioQueueLevelMeterState) * 1);
    }
    self.timerLevelMeter = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateLevelMeter:) userInfo:nil repeats:YES];
    self.timerTimeout = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(timeoutCheck:) userInfo:nil repeats:NO];
}

- (void)stopRecording {
    [self stopRecording:NO];
    [flvFile close];
}

- (void)cancelRecording {
    [self stopRecording:YES];
}

- (void)stopRecording:(BOOL)isCanceled {
    if (self.delegate) {
        [self.delegate recordingStopped];
    }
    if (isCanceled) {
        if (self.encapsulator) {
            [self.encapsulator stopEncapsulating:YES];
        }
    }
    [self.timerLevelMeter invalidate];
    [self.timerTimeout invalidate];
    self.timerLevelMeter = nil;
//    free(levelMeterStates);
    if (mAQRecorder) {
        mAQRecorder->StopRecord();
    }
    self.dateStopRecording = [NSDate date];
}

- (void)encapsulatingOver {
    if (self.delegate) {
        [self.delegate recordingFinishedWithFileName:filename time:[self recordedTimeInterval]];
    }
}

- (NSTimeInterval)recordedTimeInterval {
    return (dateStopRecording && dateStartRecording) ? [dateStopRecording timeIntervalSinceDate:dateStartRecording] : 0;
}

- (void)updateLevelMeter:(id)sender {
    if (self.delegate) {
        UInt32 dataSize = sizeof(AudioQueueLevelMeterState);
        AudioQueueGetProperty(mAQRecorder->Queue(), kAudioQueueProperty_CurrentLevelMeter, levelMeterStates, &dataSize);
        if ([self.delegate respondsToSelector:@selector(levelMeterChanged:)]) {
            [self.delegate levelMeterChanged:levelMeterStates[0].mPeakPower];
        }

    }
}

- (void)timeoutCheck:(id)sender {
    [[self delegate] recordingTimeout];
}

- (void)dealloc {
    if (mAQRecorder) {
        delete mAQRecorder;
    }
    if (levelMeterStates)
    {
        delete levelMeterStates;
    }
    self.encapsulator = nil;
}

#pragma mark AudioSession listeners
void interruptionListener(	void *	inClientData,
                          UInt32	inInterruptionState)
{
	RecorderManager *THIS = (__bridge RecorderManager*)inClientData;
	if (inInterruptionState == kAudioSessionBeginInterruption)
	{
		if (mAQRecorder->IsRunning()) {
			[THIS stopRecording];
		}
	}
}

void propListener(	void *                  inClientData,
                  AudioSessionPropertyID	inID,
                  UInt32                  inDataSize,
                  const void *            inData)
{
	RecorderManager *THIS = (__bridge RecorderManager*)inClientData;
	if (inID == kAudioSessionProperty_AudioRouteChange)
	{
		CFDictionaryRef routeDictionary = (CFDictionaryRef)inData;
		//CFShow(routeDictionary);
		CFNumberRef reason = (CFNumberRef)CFDictionaryGetValue(routeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
		SInt32 reasonVal;
		CFNumberGetValue(reason, kCFNumberSInt32Type, &reasonVal);
		if (reasonVal != kAudioSessionRouteChangeReason_CategoryChange)
		{
			// stop the queue if we had a non-policy route change
			if (mAQRecorder->IsRunning()) {
				[THIS stopRecording];
			}
		}
	}
	else if (inID == kAudioSessionProperty_AudioInputAvailable)
	{
		if (inDataSize == sizeof(UInt32))
        {
//			UInt32 isAvailable = *(UInt32*)inData;
			// disable recording if input is not available
//			BOOL available = (isAvailable > 0) ? YES : NO;
		}
	}
}

@end
