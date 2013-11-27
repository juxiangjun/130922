//
//  AdsBookViewController.h
//  DYT
//
//  Created by zhaoliang.chen on 13-6-3.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TKImageCache;
@interface AdsBookViewController : UIViewController
<UITextFieldDelegate>{
    float height;
    UITextField* searchTextField;
    UIScrollView* listScrollView;
    GroupObject* parentGroup;
    NSMutableArray* arraySearch;
    TKImageCache* _recvGroupChild;
}

-(id)initWithData:(GroupObject*)obj;

@end
