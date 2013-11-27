//
//  MainViewController.h
//  DYT
//
//  Created by zhaoliang.chen on 13-6-4.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewMsgViewController;
@class AnnViewController;
@interface MainViewController : UIViewController
<UITabBarControllerDelegate> {
    int m_nUserid;
    BOOL isAutoLogin;
    NewMsgViewController *msg;
    AnnViewController *ann;
    UIView* tabRedPoint;
    UIImageView* backImg;
}

@property (strong, nonatomic) UITabBarController* tabbarController;

- (id)initWithUserid:(int)userid;

@end
