//
//  AQRecorder.m
//  ims
//
//  Created by Tony Ju on 11/18/13.
//  Copyright (c) 2013 Tony Ju. All rights reserved.
//

#import "AQRecorder.h"


// Declare C callback functions
void AudioInputCallback(void * inUserData,  // Custom audio metadata
                        AudioQueueRef inAQ,
                        AudioQueueBufferRef inBuffer,
                        const AudioTimeStamp * inStartTime,
                        UInt32 inNumberPacketDescriptions,
                        const AudioStreamPacketDescription * inPacketDescs);

void AudioOutputCallback(void * inUserData,
                         AudioQueueRef outAQ,
                         AudioQueueBufferRef outBuffer);

static AQRecorder* aqRecorder = nil;

static double BASE_TIME;

@implementation AQRecorder


-init {
    if (self = [super init]) {
        BASE_TIME = 0;
    }
    
    return self;
}

+(AQRecorder *) getInstance {
    
    @synchronized([ AQRecorder class]) {
        if (aqRecorder == nil) {
            aqRecorder = [[AQRecorder alloc] init];
        } else {
            //audioManager.audioFileName = fileName;
        }
        return aqRecorder;
    }
    return nil;
}


-(void) startRecording {
    [self setupAudioFormat:&recordState.dataFormat];
    
    BASE_TIME = [[NSDate date] timeIntervalSince1970];

    
    recordState.currentPacket = 0;
	
    OSStatus status;
    status = AudioQueueNewInput(&recordState.dataFormat,
                                AudioInputCallback,
                                &recordState,
                                CFRunLoopGetCurrent(),
                                kCFRunLoopCommonModes,
                                0,
                                &recordState.queue);
    
    if (status == 0)
    {
        // Prime recording buffers with empty data
        for (int i = 0; i < NUM_BUFFERS; i++)
        {
            AudioQueueAllocateBuffer(recordState.queue, 16000, &recordState.buffers[i]);
            AudioQueueEnqueueBuffer (recordState.queue, recordState.buffers[i], 0, NULL);
        }
        
        status = AudioFileCreateWithURL(fileURL,
                                        kAudioFileAIFFType,
                                        &recordState.dataFormat,
                                        kAudioFileFlags_EraseFile,
                                        &recordState.audioFile);
        if (status == 0)
        {
            recordState.recording = true;
            status = AudioQueueStart(recordState.queue, NULL);
            if (status == 0)
            {
                //labelStatus.text = @"Recording";
            }
        }
    }
    
    if (status != 0)
    {
        [self stopRecording];
        //labelStatus.text = @"Record Failed";
    }

}

-  (void) stopRecording {
    
    recordState.recording = false;
    
    AudioQueueStop(recordState.queue, true);
    for(int i = 0; i < NUM_BUFFERS; i++)
    {
        AudioQueueFreeBuffer(recordState.queue, recordState.buffers[i]);
    }
    
    AudioQueueDispose(recordState.queue, true);
    AudioFileClose(recordState.audioFile);
    //labelStatus.text = @"Idle";
}


void AudioInputCallback(void * inUserData,
                        AudioQueueRef inAQ,
                        AudioQueueBufferRef inBuffer,
                        const AudioTimeStamp * inStartTime,
                        UInt32 inNumberPacketDescriptions,
                        const AudioStreamPacketDescription * inPacketDescs)
{
    
    if (BASE_TIME == 0) {
        NSLog(@"BASE TIME CAN'T BE ZERO.");
        //return ;
    }
    
    //int elapsedTime = inStartTime->mHostTime - BASE_TIME;

    NSLog(@"Enter AudioInputCallback");
    
}


void AudioOutputCallback(void * inUserData,
                         AudioQueueRef outAQ,
                         AudioQueueBufferRef outBuffer) {
    
}

- (void)setupAudioFormat:(AudioStreamBasicDescription*)format
{
	format->mSampleRate = 8000.0;
	format->mFormatID = kAudioFormatLinearPCM;
	format->mFramesPerPacket = 1;
	format->mChannelsPerFrame = 1;
	format->mBytesPerFrame = 2;
	format->mBytesPerPacket = 2;
	format->mBitsPerChannel = 16;
	format->mReserved = 0;
	format->mFormatFlags = kLinearPCMFormatFlagIsBigEndian     |
    kLinearPCMFormatFlagIsSignedInteger |
    kLinearPCMFormatFlagIsPacked;
}


@end
