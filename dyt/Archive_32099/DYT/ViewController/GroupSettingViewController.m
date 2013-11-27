//
//  GroupSettingViewController.m
//  DYT
//
//  Created by zhaoliang.chen on 13-6-20.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "GroupSettingViewController.h"
#import "TKImageCache.h"
#import "UserDetailViewController.h"
#import "GroupActViewController.h"

@interface GroupSettingViewController ()

@end

@implementation GroupSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        pageNum = 0;
    }
    return self;
}

- (id)initWithGroupid:(int)groupid {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        groupObj = [GroupObject findByGroupid:groupid];
        parentName = [GroupObject findByGroupid:groupObj.parentid].groupName;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //if (([Reachability reachabilityForInternetConnection].currentReachabilityStatus == NotReachable) &&       ([Reachability reachabilityForLocalWiFi].currentReachabilityStatus == NotReachable)) {
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
    
}


@end
