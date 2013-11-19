//
//  AQRecorder.h
//  ims
//
//  Created by Tony Ju on 11/18/13.
//  Copyright (c) 2013 Tony Ju. All rights reserved.
//

#import <Foundation/Foundation.h>
#define NUM_BUFFERS 3
#define SECONDS_TO_RECORD 10
#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/AudioFile.h>


typedef struct {
    
    AudioStreamBasicDescription dataFormat;
    AudioQueueRef queue;
    AudioQueueBufferRef buffers[NUM_BUFFERS];
    AudioFileID audioFile;
    SInt64 currentPacket;
    bool recording;
    
} RecordState;


typedef struct {
    
    AudioStreamBasicDescription  dataFormat;
    AudioQueueRef                queue;
    AudioQueueBufferRef          buffers[NUM_BUFFERS];
    AudioFileID                  audioFile;
    SInt64                       currentPacket;
    bool                         playing;
    
} PlayState;

@interface AQRecorder : NSObject {
    RecordState recordState;
    CFURLRef fileURL;
}

+(AQRecorder *) getInstance;

-(void) startRecording;
-(void) stopRecording;

@end
