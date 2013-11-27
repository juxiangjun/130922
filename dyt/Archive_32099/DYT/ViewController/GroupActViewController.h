//
//  GroupActViewController.h
//  DYT
//
//  Created by zhaoliang.chen on 13-6-25.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TKImageCache;
@interface GroupActViewController : UIViewController
<UITableViewDataSource,UITableViewDelegate>{
    GroupObject* groupObj;
    UIScrollView* mainScrollView;
    UITableView* tableAct;
    NSArray* titleArray;
    NSArray* contentArray;
    UILabel* lNumber;
    UIView* userImg;
    UIButton* btJoin;
    ActiveObject* activeobj;
    NSMutableArray* arrayUser;
    TKImageCache* _recvUserOnAct;
    BOOL isJoin;
}

- (id)initWithGroup:(GroupObject*)group;

@end
