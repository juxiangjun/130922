//
//  UserDetailViewController.h
//  DYT
//
//  Created by zhaoliang.chen on 13-6-3.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TKImageCache;
@interface UserDetailViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource> {
    UserObject* m_User;
    UIImageView* head;
    UILabel* name;
    UILabel* sex;
    TKImageCache* _recvUserHeadOnDetial;
    UITableView* infoTableView;
    NSArray* titleArray;
    NSArray* contentArray;
    int m_nUserid;
    UIImageView* lagreImg;
    UIImageView* myBigImg;
    
    //手势专用参数
    float lastScale;

}

- (id)initWithUserid:(int)userid;

@end
