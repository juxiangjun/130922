//
//  NewAdsGroupCell.h
//  DYT
//
//  Created by zhaoliang.chen on 13-6-25.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TKImageCache;
@interface NewAdsGroupCell : UITableViewCell {
    UIImageView* head;
    UILabel* groupName;
    UILabel* allSubGroupName;
    UIImageView* arrow;
    TKImageCache* _recvGroupMain;
}

- (void)setCell:(GroupObject*)obj;

@end
