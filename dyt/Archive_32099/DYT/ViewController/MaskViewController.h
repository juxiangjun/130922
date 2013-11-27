//
//  MaskViewController.h
//  DYT
//
//  Created by zhaoliang.chen on 13-7-9.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MaskViewController : UIViewController
<UITextViewDelegate>{
    UITextView* m_TextView;
    NSString* m_Mask;
}

-(id)initWithData:(NSString*)mask;

@end
