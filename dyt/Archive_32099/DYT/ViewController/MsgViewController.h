//
//  MsgViewController.h
//  DYT
//
//  Created by zhaoliang.chen on 13-6-3.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface MsgViewController : UIViewController
<UITextFieldDelegate,UIScrollViewDelegate,
EGORefreshTableHeaderDelegate> {
    UITextField* searchTextField;
    UIScrollView* msgScrollView;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    NSMutableArray* deleteBtArray;      //删除按钮的数组
}

@end
