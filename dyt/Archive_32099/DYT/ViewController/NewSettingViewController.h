//
//  NewSettingViewController.h
//  DYT
//
//  Created by zhaoliang.chen on 13-7-3.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewSettingViewController : UIViewController
<UITableViewDataSource,UITableViewDelegate,
UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    UserObject* myUser;
    UIScrollView* mainScrollView;
    UITableView* settingTableView;
    NSArray* titleArrayOne;
    NSArray* titleArrayTwo;
    NSArray* contentArray;
}

@end
