//
//  PictureViewController.h
//  DYT
//
//  Created by zhaoliang.chen on 13-7-2.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    chatPic = 1,
    groupPic,
}picType;

@class TKImageCache;
@interface PictureViewController : UIViewController
<UIScrollViewDelegate,UIActionSheetDelegate,
UIGestureRecognizerDelegate>{
    UIScrollView* mainScrollView;
    NSArray* arrayChat;
    int m_nIndex;
    TKImageCache* _recvBigPic;
    UIActionSheet *saveActionSheet;
    int m_nOldPage;
    float largeHeight;
    
    //手势专用参数
    float lastScale;
    
    picType m_PicType;
}

- (id)initWithObj:(NSArray*)array whitIndex:(int)index;
- (id)initWithGroupPicData:(NSArray*)array whitIndex:(int)index;

@end
