//
//  GroupDetailViewController.h
//  DYT
//
//  Created by zhaoliang.chen on 13-6-3.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseGroupViewController.h"

@class TKImageCache;
@interface GroupDetailViewController : BaseGroupViewController {
    UIButton* btStartChat;
}

- (id)initWithData:(GroupObject*)obj withName:(NSString*)name;

@end
