//
//  UINavigationControllerHack.m
//  DYT
//
//  Created by zhuang yihang on 7/12/13.
//  Copyright (c) 2013 zhaoliang.chen. All rights reserved.
//

#import "UINavigationControllerHack.h"

@interface UINavigationControllerHack (){
    BOOL enable_;
}

@end

@implementation UINavigationControllerHack

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        enable_ = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableAutoratate:) name:@"enableAutoratate" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate{
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations{
    if (!enable_) {
        return UIInterfaceOrientationMaskPortrait;
    }else{
        return UIInterfaceOrientationMaskAll;
    }
    
}

- (void)enableAutoratate:(NSNotification *)notification{
    NSNumber *n = (NSNumber *)notification.object;
    enable_ = [n boolValue];
}

@end
