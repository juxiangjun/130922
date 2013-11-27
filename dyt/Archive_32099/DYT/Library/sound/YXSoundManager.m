//
//  YXSoundManager.m
//  Sound
//
//  Created by zhuang yihang on 6/5/13.
//  Copyright (c) 2013 YX. All rights reserved.
//

#import "YXSoundManager.h"
#import "YXResourceManager.h"
#import "HeadphonesDetector.h"
@interface YXSoundManager()<AVAudioRecorderDelegate,AVAudioPlayerDelegate,HeadphonesDetectorDelegate>{
    AVAudioRecorder *recorder_;
    AVAudioPlayer *player_;
}

@end

static YXSoundManager *_sharedManager = nil;
@implementation YXSoundManager
@synthesize delegate = delegate_;

+(YXSoundManager *)sharedManager{
    @synchronized( [YXSoundManager class] ){
        if(!_sharedManager)
            _sharedManager = [[self alloc] init];
        return _sharedManager;
    }
    return nil;
}

+(id)alloc
{
    @synchronized ([YXSoundManager class]){
        NSAssert(_sharedManager == nil,
                 @"Attempted to allocated a second instance");
        _sharedManager = [super alloc];
        return _sharedManager;
    }
    return nil;
}

-(id)init{
    self = [super init];
    if (self) {
        
        [HeadphonesDetector sharedDetector].delegate = self;
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
        [self updateRoute];
    }
    return self;
}

- (void)dealloc{
}

- (NSString *)getRecorderFileName{
    return @"recorder.wav";
}

- (BOOL)recordStart{
    if (recorder_ && recorder_.isRecording) {
        [recorder_ stop];
    }

    NSString *path = [[YXResourceManager sharedManager] getSoundDirectionary];
    path = [path stringByAppendingPathComponent:[self getRecorderFileName]];
    
    NSURL *url = [NSURL fileURLWithPath:path];
//    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
//                              [NSNumber numberWithFloat: 11025.0],                 AVSampleRateKey,
//                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
//                              [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
//                              [NSNumber numberWithInt: AVAudioQualityMedium],      AVEncoderAudioQualityKey,
//                              nil];
    NSDictionary *settings=[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithFloat:8000.0],AVSampleRateKey,
                            [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                            [NSNumber numberWithInt:1],AVNumberOfChannelsKey,
                            [NSNumber numberWithInt:8],AVLinearPCMBitDepthKey,
                            [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                            [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                            nil];
    
    NSError *error = nil;
    recorder_ = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    recorder_.delegate = self;
    [recorder_ prepareToRecord];
    recorder_.meteringEnabled = YES;
    [recorder_ record];
    [recorder_ updateMeters];
    
    if (error) {
        return FALSE;
    }
    
    return TRUE;
}

- (void)recordStop{
    [recorder_ stop];
    recorder_ = nil;
}

- (int)getSoundLevel{
    int res = 0;
    
    if ( recorder_ && recorder_.isRecording) {
        [recorder_ updateMeters];
        float val = [recorder_ averagePowerForChannel:0];
        if (val < -40) {
            res = 0;
        }else if(val < -20){
            res = 1;
        }else if(val < -10){
            res = 2;
        }else if(val < -5){
            res = 3;
        }
    }
    
    return res;
}

- (float)getsoundLength{
    return recorder_.currentTime;
}

- (BOOL)playStart:(NSString *)filePath{
    if (player_ && player_.isPlaying) {
        [player_ stop];
        player_ = nil;
    }
    
    if (filePath==nil) {
        [delegate_ soudnManagerError:nil];
        return FALSE;
    }
    
    NSError *error = nil;
    //NSURL *url = [NSURL fileURLWithPath:filePath];
    //player_ = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    NSData* voiceData = [VoiceConverter amrToNSData:filePath];
    player_ = [[AVAudioPlayer alloc] initWithData:voiceData error:&error];
    player_.delegate = self;
    [player_ play];
    if (error) {
        [delegate_ soudnManagerError:error];
        return FALSE;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"proximityChanged" object:nil];
    UIDevice *device = [UIDevice currentDevice];
    [device setProximityMonitoringEnabled:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proximityChanged:) name:UIDeviceProximityStateDidChangeNotification object:device];
    
    return TRUE;
}

- (BOOL)play:(NSData *)data{
    if (player_ && player_.isPlaying) {
        [player_ stop];
        player_ = nil;
    }
    
    if (data==nil) {
        [delegate_ soudnManagerError:nil];
        return FALSE;
    }
    
    NSError *error = nil;
    player_ = [[AVAudioPlayer alloc] initWithData:data error:&error];
    player_.delegate = self;
    [player_ play];
    if (error) {
        [delegate_ soudnManagerError:error];
        return FALSE;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"proximityChanged" object:nil];
    UIDevice *device = [UIDevice currentDevice];
    [device setProximityMonitoringEnabled:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proximityChanged:) name:UIDeviceProximityStateDidChangeNotification object:device];
    
    return TRUE;
}

- (BOOL)isPlaying{
    return [player_ isPlaying];
}

- (float)getVoiceLength:(NSString *)filePath{
    NSError *error = nil;
    NSData* voiceData = [VoiceConverter amrToNSData:filePath];
    AVAudioPlayer *p = [[AVAudioPlayer alloc] initWithData:voiceData error:&error];
    return p.duration;
}

- (void)playStop{
    [player_ stop];
    [delegate_ soudnManagerPlayFinish];
    UIDevice *device = [UIDevice currentDevice];
    [device setProximityMonitoringEnabled:NO];
    player_ = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"proximityChanged" object:nil];
}

#pragma mark AVAudioRecorder
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    NSString *path = [[YXResourceManager sharedManager] getSoundDirectionary];
    path = [path stringByAppendingPathComponent:[self getRecorderFileName]];
    [VoiceConverter wavToAmr:path];
    path = [path stringByReplacingOccurrencesOfString:@"wav" withString:@"amr"];
    [delegate_ soudnManagerRecordFinish:path];
    recorder_ = nil;
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error{
    [delegate_ soudnManagerError:error];
}

#pragma mark AVAudioPlayer
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    UIDevice *device = [UIDevice currentDevice];
    [device setProximityMonitoringEnabled:NO];
    [delegate_ soudnManagerPlayFinish];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"proximityChanged" object:nil];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    UIDevice *device = [UIDevice currentDevice];
    [device setProximityMonitoringEnabled:NO];
    [delegate_ soudnManagerError:error];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"proximityChanged" object:nil];
}

- (void)proximityChanged:(NSNotification*)sender {
    
    if ([[HeadphonesDetector sharedDetector] headphonesArePlugged]) {
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
        AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
    }else{
        UIDevice *device = [UIDevice currentDevice];
        
        OSStatus status = 0;
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        status = AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);

        
        if ([device proximityState]) {
            
            UInt32 doChangeDefaultRoute = 1;
            status = AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof (doChangeDefaultRoute), &doChangeDefaultRoute);
        }else{
            
            UInt32 doChangeDefaultRoute = 0;
            status = AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof (doChangeDefaultRoute), &doChangeDefaultRoute);
        }
    }
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
}

- (void)updateRoute{
    if ([[HeadphonesDetector sharedDetector] headphonesArePlugged]) {
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
        AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
    }else{
        UIDevice *device = [UIDevice currentDevice];
        
        OSStatus status = 0;
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        status = AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
        
        
        if ([device proximityState]) {
            
            UInt32 doChangeDefaultRoute = 1;
            status = AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof (doChangeDefaultRoute), &doChangeDefaultRoute);
        }else{
            
            UInt32 doChangeDefaultRoute = 0;
            status = AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof (doChangeDefaultRoute), &doChangeDefaultRoute);
        }
    }
}

- (void) headphonesDetectorStateChanged: (HeadphonesDetector *) headphonesDetector{
    [self proximityChanged:nil];
}
@end
