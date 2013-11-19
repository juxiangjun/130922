//
//  AudioManager.m
//  ims
//
//  Created by Tony Ju on 10/22/13.
//  Copyright (c) 2013 Tony Ju. All rights reserved.
//

#import "AudioManager.h"
#import "PathUtils.h"
#import "VoiceConverter.h"
#import "AudioFileConvertor.h"

static AudioManager* audioManager = nil;

@implementation AudioManager
@synthesize audioFileName;

+( AudioManager *) getInstance :(NSString*) fileName audioManagerDelegate:(id) delegte;{
    @synchronized([ AudioManager class]) {
        if (audioManager == nil) {
            audioManager = [[AudioManager alloc] initWithFileName:fileName :delegte];
        } else {
            audioManager.audioFileName = fileName;
        }
        return audioManager;
    }
    return nil;
}

-(id) initWithFileName: (NSString*) fileName :(AudioManagerDelegate*) delegate {
    NSLog(@"initialize audio manager.");
    self = [super init];
    if (self) {
        audioManagerDelegate = delegate;
        audioFileName = fileName;
        encoding = ENC_AAC;
        [HeadphonesDetector sharedDetector].delegate = self;
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
        //[self updateRoute];

    }
    return self;
;
}

#pragma mark ---- audio record and play ----
-(BOOL) startRecord {
    NSLog(@"startRecord...");
    
    BOOL result = TRUE;
    
    int capability = 10;
    // Init audio with record capability
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    
    NSMutableDictionary *recordSettings = [self getAudioRecordSettings:capability];
    
    NSString* path = [PathUtils getAudioDirectory];
    NSURL *url = [PathUtils getURLByFileName:path :audioFileName];
    
    NSError *error = nil;
    recorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSettings error:&error];
    recorder.delegate  = self;
    
    if ([recorder prepareToRecord] == YES){
        [recorder record];
        [recorder updateMeters];
    }else {
        int errorCode = CFSwapInt32HostToBig ([error code]);
        NSLog(@"Error: %@ [%4.4s])" , [error localizedDescription], (char*)&errorCode);
        result = FALSE;
    }
    
    NSLog(@"...startRecord");
    return result;
    
}

-(void) stopRecord {
    if (recorder) {
        [recorder stop];
        recorder = nil;
    }
}

-(BOOL) playOnlineAudio :(NSString *) url {
    BOOL result = TRUE;

    AVPlayer *avPlayer = [AVPlayer playerWithURL: [NSURL URLWithString:@"http://192.168.7.96/ims/audio/EEE22C9D-8DFE-4348-874B-3BDDD9156499.wav"]];
    [avPlayer play];
    
    return  result;

}

- (void) testPlay {
    NSString *tt = @"http://192.168.7.96/ims/audio/EEE22C9D-8DFE-4348-874B-3BDDD9156499.wav";
    
    if (player && player.isPlaying) {
        [player stop];
        player = nil;
    }

    
    NSURL *url = [NSURL URLWithString:tt];
    NSData *soundData = [NSData dataWithContentsOfURL:url];
    NSError* error = nil;

    player = [[AVAudioPlayer alloc] initWithData:soundData  error:&error];

    
    if (error) {
        NSLog(@"%@", error);
    } else {
        player.numberOfLoops = 0;
        [player play];
    }
}


-(BOOL) play:(NSString *)fileName {
    BOOL result = TRUE;
    
    if (player && player.isPlaying) {
        [player stop];
        player = nil;
    }

    NSLog(@"playRecording");
    // Init audio with playback capability
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    NSString* path = [PathUtils getAudioDirectory];
    NSURL *url = [PathUtils getURLByFileName:path :fileName];
    
    NSError *error;
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    if (error) {
        NSLog(@"Failed to play online file [%@]", url);
    } else {
        player.numberOfLoops = 0;
        [player play];
        NSLog(@"playing");
    }
    
    return  result;
}


-(NSMutableDictionary *) getAudioRecordSettings :(int) capability {
    
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] initWithCapacity:capability];
    if(encoding == ENC_PCM)
    {
        [recordSettings setObject:[NSNumber numberWithInt: kAudioFormatLinearPCM] forKey: AVFormatIDKey];
        [recordSettings setObject:[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [recordSettings setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
        [recordSettings setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    }
    else
    {
        NSNumber *formatObject;
        
        switch (encoding) {
            case (ENC_AAC):
                formatObject = [NSNumber numberWithInt: kAudioFormatMPEG4AAC];
                break;
            case (ENC_ALAC):
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleLossless];
                break;
            case (ENC_IMA4):
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleIMA4];
                break;
            case (ENC_ILBC):
                formatObject = [NSNumber numberWithInt: kAudioFormatiLBC];
                break;
            case (ENC_ULAW):
                formatObject = [NSNumber numberWithInt: kAudioFormatULaw];
                break;
            default:
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleIMA4];
        }
        
        [recordSettings setObject:formatObject forKey: AVFormatIDKey];
        [recordSettings setObject:[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        [recordSettings setObject:[NSNumber numberWithInt:12800] forKey:AVEncoderBitRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [recordSettings setObject:[NSNumber numberWithInt: AVAudioQualityHigh] forKey: AVEncoderAudioQualityKey];
    }
    
    
    return recordSettings;
}


#pragma mark --- Headphone changed ---
/*
- (void) headphonesDetectorStateChanged: (HeadphonesDetector *) headphonesDetector {
    [self proximityChanged:nil];
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

*/

#pragma mark --- AVPlayer Delegate ---

/* audioPlayerDidFinishPlaying:successfully: is called when a sound has finished playing. This method is NOT called if the player is stopped due to an interruption. */
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"audioPlayerDidFinishPlaying");
    
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@"audioPlayerDecodeErrorDidOccur");
}

#if TARGET_OS_IPHONE

/* audioPlayerBeginInterruption: is called when the audio session has been interrupted while the player was playing. The player will have been paused. */
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
    
}

/* audioPlayerEndInterruption:withOptions: is called when the audio session interruption has ended and this player had been interrupted while playing. */
/* Currently the only flag is AVAudioSessionInterruptionFlags_ShouldResume. */
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags NS_AVAILABLE_IOS(6_0) {
    
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withFlags:(NSUInteger)flags NS_DEPRECATED_IOS(4_0, 6_0) {
    
}

/* audioPlayerEndInterruption: is called when the preferred method, audioPlayerEndInterruption:withFlags:, is not implemented. */
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player NS_DEPRECATED_IOS(2_2, 6_0) {
    
}



#endif // TARGET_OS_IPHONE

#pragma mark --- AVRecorder Delegate ---
/* audioRecorderDidFinishRecording:successfully: is called when a recording has been finished or stopped. This method is NOT called if the recorder is stopped due to an interruption. */
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    NSLog(@"audioRecorderDidFinishRecording...");
    NSString* path = [PathUtils getAudioDirectory];
    NSURL *url = [PathUtils getURLByFileName:path :audioFileName];
    BOOL result =[AudioFileConvertor exportAssetAsWaveFormat:[url path]];
    NSLog(@"Convert Result: %d", result);
    [audioManagerDelegate onRecorderFinished];
    NSLog(@"...audioRecorderDidFinishRecording");
}

/* if an error occurs while encoding it will be reported to the delegate. */
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    NSLog(@"audioRecorderEncodeErrorDidOccur...");
    NSLog(@"...audioRecorderEncodeErrorDidOccur");
}

#if TARGET_OS_IPHONE

/* audioRecorderBeginInterruption: is called when the audio session has been interrupted while the recorder was recording. The recorded file will be closed. */
- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder  {
    
}

/* audioRecorderEndInterruption:withOptions: is called when the audio session interruption has ended and this recorder had been interrupted while recording. */
/* Currently the only flag is AVAudioSessionInterruptionFlags_ShouldResume. */
- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withOptions:(NSUInteger)flags NS_AVAILABLE_IOS(6_0) {
    
}

- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withFlags:(NSUInteger)flags NS_DEPRECATED_IOS(4_0, 6_0)  {
    
}

/* audioRecorderEndInterruption: is called when the preferred method, audioRecorderEndInterruption:withFlags:, is not implemented. */
- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder NS_DEPRECATED_IOS(2_2, 6_0) {
    
}

#endif


#pragma mark -- private method ---

-(NSString *) getAudioFilePath {
    NSString* soundDirectory = [PathUtils getAudioDirectory];
    return [soundDirectory stringByAppendingPathComponent:audioFileName];
}

-(NSData *) getAudioFileData :(NSString *) fileName {
    fileName = [fileName stringByReplacingOccurrencesOfString:@"wav" withString:@"amr"];
    NSString* filePath = [[PathUtils getAudioDirectory] stringByAppendingPathComponent:fileName];
    NSData* data = [VoiceConverter amrToNSData:filePath];
    return data;
}



@end
