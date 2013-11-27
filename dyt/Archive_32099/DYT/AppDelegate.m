//
//  AppDelegate.m
//  DYT
//
//  Created by zhaoliang.chen on 13-5-31.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "MainViewController.h"
#import "Global.h"
#import "UINavigationControllerHack.h"

#import "EmotionLabel.h"
#import "HeadphonesDetector.h"
@implementation AppDelegate

@synthesize navController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    dispatch_queue_t queue = dispatch_queue_create("com.yx.dyt", NULL);
    dispatch_async(queue, ^(void) {
        EmotionLabel *label = [[EmotionLabel alloc] initWithFrame:CGRectMake(10, 0,0,0)];
        label.text = @"";
    });
    dispatch_release(queue);
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    
    LoginViewController* root = [[LoginViewController alloc]init];
    self.navController = [[UINavigationControllerHack alloc]initWithRootViewController:root];
    [self.window addSubview:self.navController.view];
    self.window.rootViewController = self.navController;
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound];    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChangeNum:) name:@"onChangeNum" object:nil];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"onRecvMsg" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateNewAnn" object:[NSNumber numberWithBool:YES]];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSString* res = [[[[deviceToken description]
                                stringByReplacingOccurrencesOfString: @"<" withString: @""]
                               stringByReplacingOccurrencesOfString: @">" withString: @""]
                              stringByReplacingOccurrencesOfString: @" " withString: @""];
    [[Global sharedInstance] setDeviceToken:res];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"notification fail:%@",[error description]);
    
    NSString *s = genRandomString(64);
    [[Global sharedInstance] setDeviceToken:s];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    NSLog(@"userInfo=%@",userInfo);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"onRecvMsg" object:[userInfo objectForKey:@"message"]];
}

- (void)onChangeNum:(NSNotification*)sender {
    int num = [(NSNumber*)sender.object intValue];
    [UIApplication sharedApplication].applicationIconBadgeNumber = num;
}

@end
