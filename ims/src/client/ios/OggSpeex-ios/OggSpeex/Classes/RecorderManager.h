//
//  RecorderManager.h
//  OggSpeex
//
//  Created by Jiang Chuncheng on 6/25/13.
//  Copyright (c) 2013 Sense Force. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "AQRecorder.h"
#import "Encapsulator.h"
#import "FLVFIle.h"
#import "rtmp.h"

@protocol RecordingDelegate <NSObject>

- (void)recordingFinishedWithFileName:(NSString *)filePath time:(NSTimeInterval)interval;
- (void)recordingTimeout;
- (void)recordingStopped;  //录音机停止采集声音
- (void)recordingFailed:(NSString *)failureInfoString;

@optional
- (void)levelMeterChanged:(float)levelMeter;

@end

@interface RecorderManager : NSObject <EncapsulatingDelegate, ConsumerDelegate> {
    
    Encapsulator *encapsulator;
    NSString *filename;
    NSDate *dateStartRecording;
    NSDate *dateStopRecording;
    NSTimer *timerLevelMeter;
    NSTimer *timerTimeout;
    NSMutableData *queue;
    double baseTime;
    int previousTagSize;
    int timestamp;
    int dataLength;
    FLVFIle *flvFile;
    RTMP *connPublish;
}

@property (nonatomic, weak)  id<RecordingDelegate> delegate;
@property (nonatomic, strong) Encapsulator *encapsulator;
@property (nonatomic, strong) NSDate *dateStartRecording, *dateStopRecording;
@property (nonatomic, strong) NSTimer *timerLevelMeter;
@property (nonatomic, strong) NSTimer *timerTimeout;

+ (RecorderManager *)sharedManager;

- (void)startRecording;

- (void)stopRecording;

- (void)cancelRecording;

- (NSTimeInterval)recordedTimeInterval;

@end
