//
//  BaseGroupViewController.h
//  DYT
//
//  Created by zhaoliang.chen on 13-6-26.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraViewController.h"
@class TKImageCache;
@interface BaseGroupViewController : UIViewController
<CameraDelegate,UIImagePickerControllerDelegate,
UINavigationControllerDelegate,UIActionSheetDelegate>{
    UIScrollView* mainScrollView;
    UIScrollView* groupPicScrollView;
    UIScrollView* userScrollView;
    GroupObject* groupObj;
    NSString* parentName;
    TKImageCache* _recvGroupHead;
    TKImageCache* _recvUserHead;
    TKImageCache* _recvGroupPic;
    UIImageView* groupHead;
    NSMutableArray* arrayUser;
    float startPoint;
    int pageNum;
    TKImageCache* _recvBigImgOnGroupPic;
    UIImageView* lagreImg;
    UIImageView* myBigImg;
    
    //手势专用参数
    float lastScale;
}

- (void)createView;
- (void)getGroupMember:(int)groupid;

@end
