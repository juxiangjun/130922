//
//  TestLibAppDelegate.m
//  TestLib
//
//  Created by Vladimir Boychentsov on 11/23/10.
//  Copyright 2010 www.injoit.com. All rights reserved.
//


#import "TestLibAppDelegate.h"
#import "RTMPFileDownloader.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@implementation TestLibAppDelegate

AVAudioPlayer *sound;

@synthesize window;
@synthesize soundFileURL, appSoundPlayer;

#pragma mark -
#pragma mark Application lifecycle


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
    
	RTMP_debuglevel = RTMP_LOGINFO;
	
	//RTMP_debuglevel = RTMP_LOGALL;
	
    [self.window makeKeyAndVisible];
    
	
	
	object1 = [[RTMPFileDownloader alloc] initWithFrame:CGRectMake(20, 40, 150, 25)];
	[object1 setDelegate:self];
	[window addSubview:object1];
	[NSThread detachNewThreadSelector:@selector(downloadObject1) toTarget:self withObject:nil];
	
    return YES;
}
 

- (void) downloadObject1 {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
//	rtmp://localhost/vod/8.mp3
	//NSString *file = @"rtmp://192.168.1.3/vod/8.mp3";
	NSString *file = @"rtmp://server.audiopedia.su/vod/disk2/большая коллекция/25.03.10/Инбер В - Ленин и время (стих).mp3";
//	NSString *file = @"rtmp://localhost/vod/x x/Антоколький Павел - Поэзия (ст. чт.автор).mp3";
	//NSString *file = @"rtmp://server.audiopedia.su/vod/disk2/большая коллекция/Дюрренматт Ф - Туннель.mp3";
	[object1 downloadAtString:file];	
	
	[pool drain];
}


- (void) downloadObject2 {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	
	NSString *file = @"rtmp://server.audiopedia.su/vod/disk2/большая коллекция/Дюрренматт Ф - Туннель.mp3";
	[object2 downloadAtString:file];	
	
	[pool drain];
}




- (IBAction) playFile {
	
}



#pragma mark -
#pragma mark *play*
- (IBAction) playaction {
	
	
	
    NSString *file = [[NSString alloc] initWithFormat:@"%@/%@",
					   [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], @"songname.mp3"];
	NSLog(@"%@", file);
	[file release];
	
	
}//playbutton touch up inside


- (void) didStartDownloadRTMPFile:(RTMPFileDownloader*)rtmpDownloader  duration:(float)duration{
	NSLog(@"didStartDownloadRTMPFile duration %f", duration);
}

- (void) didFinishDownloadRTMPFile:(RTMPFileDownloader*)rtmpDownloader {
	NSLog(@"didFinishDownloadRTMPFile");
}

- (void) downloaderRTMPFile:(RTMPFileDownloader *)rtmpDownloader didReceiveSeek:(int)ms andPrecent:(float)precent {
	NSLog(@"downloaderRTMPFile time: %.4f sec / precent: %.1f%%",  (float)ms/1000.0, precent);
}


- (void) downloaderRTMPFile:(RTMPFileDownloader *)rtmpDownloader didReceiveData:(NSData*)data {
//	NSLog(@"data %@", data);
}












- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
	
	
	
	//if (file != 0)
//		fclose(file);
	
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	if (object1 != nil) {
		[object1 release];
	}
	if (object2 != nil) {
		[object2 release];
	}
	
	
    [window release];
    [super dealloc];
}


@end
