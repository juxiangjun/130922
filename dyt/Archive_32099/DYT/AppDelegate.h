//
//  AppDelegate.h
//  DYT
//
//  Created by zhaoliang.chen on 13-5-31.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UINavigationControllerHack;
@interface AppDelegate : UIResponder
<UIApplicationDelegate,UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationControllerHack* navController;

@end
