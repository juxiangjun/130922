//
//  VoiceManager.h
//  ims
//
//  Created by Tony Ju on 10/22/13.
//  Copyright (c) 2013 Tony Ju. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "HeadphonesDetector.h"
#import "AudioManagerDelegate.h"



@interface AudioManager : NSObject <
                                AVAudioRecorderDelegate,
                                AVAudioPlayerDelegate,
                                HeadphonesDetectorDelegate,
                                AudioManagerDelegate>
{
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    id audioManagerDelegate;
    NSString *audioFileName;

    int encoding;
    enum
    {
        ENC_AAC = 1,
        ENC_ALAC = 2,
        ENC_IMA4 = 3,
        ENC_ILBC = 4,
        ENC_ULAW = 5,
        ENC_PCM = 6,
    } encodingTypes;
    
}


+( AudioManager *) getInstance :(NSString*) fileName audioManagerDelegate:(id) delegte;

@property (nonatomic, retain) NSString* audioFileName;
-(BOOL) startRecord;
-(void) stopRecord;

-(BOOL) play: (NSString *) fileName;
-(BOOL) playOnlineAudio :(NSString *) url;
- (void) testPlay ;

@end
