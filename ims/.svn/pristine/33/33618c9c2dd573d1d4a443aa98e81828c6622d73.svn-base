//
//  TestLibAppDelegate.h
//  TestLib
//
//  Created by Vladimir Boychentsov on 11/23/10.
//  Copyright 2010 www.injoit.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "RTMPFileDownloader.h"


@class RTMPFileDownloader;

@interface TestLibAppDelegate : NSObject <UIApplicationDelegate,AVAudioPlayerDelegate , RTMPFileDownloaderDelegate> {
    UIWindow *window;
	
	RTMPFileDownloader *object1;
	RTMPFileDownloader *object2;
	
	NSURL *soundFileURL;
	
	AVAudioPlayer *appSoundPlayer;
	
	IBOutlet UIButton *playbutton ;
	IBOutlet UIButton *resumebutton ;
	IBOutlet UIButton *pausebutton ;
	IBOutlet UIButton *stopbutton ;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) NSURL *soundFileURL;
@property (nonatomic, retain) AVAudioPlayer *appSoundPlayer;


@end

