//
//  GroupDetailViewController.m
//  DYT
//
//  Created by zhaoliang.chen on 13-6-3.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "GroupDetailViewController.h"
#import "ChatViewController.h"
#import "UserDetailViewController.h"
#import "TKImageCache.h"
#import "GroupActViewController.h"

@interface GroupDetailViewController ()

@end

@implementation GroupDetailViewController

#define USERHEADTAG 1000
#define GROUPPIC    2000

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChangeScrollView:) name:@"onChangeScrollView" object:nil];
    }
    return self;
}

- (id)initWithData:(GroupObject*)obj withName:(NSString*)name {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        groupObj = obj;
        parentName = name;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //if (([Reachability reachabilityForInternetConnection].currentReachabilityStatus == NotReachable) &&        ([Reachability reachabilityForLocalWiFi].currentReachabilityStatus == NotReachable)) {
        arrayUser = [GroupObject findMemberByGroup:groupObj.groupid];
    groupObj.arrGroupPic = [GroupPicData loadGroupPic:groupObj.groupid];
        [self createView];
    //} else {
        [self getGroupMember:groupObj.groupid];
    //}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];   
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"onChangeScrollView" object:nil];
}

- (void)goChat {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"gotoChatByGroupid" object:[NSNumber numberWithInt:groupObj.groupid]];
}

- (void)onChangeScrollView:(NSNotification*)sender {
    if (btStartChat) {
        [btStartChat removeFromSuperview];
        btStartChat = nil;
    }
    btStartChat = getButtonByImageName(@"btStartChat.png");
    btStartChat.centerX = self.view.width/2;
    btStartChat.top = startPoint;
    [btStartChat addTarget:self action:@selector(goChat) forControlEvents:UIControlEventTouchUpInside];
    btStartChat.tag = 10005;
    [mainScrollView addSubview:btStartChat];
    
    startPoint = btStartChat.bottom +10;
    
    mainScrollView.contentSize = CGSizeMake(mainScrollView.width, startPoint);
}

@end
