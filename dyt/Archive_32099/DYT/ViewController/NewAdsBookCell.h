//
//  NewAdsBookCell.h
//  DYT
//
//  Created by zhaoliang.chen on 13-6-26.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TKImageCache;
@interface NewAdsBookCell : UITableViewCell {    
    TKImageCache* _recvGroupChild;
    UIImageView* head;
    UILabel* groupName;
    UILabel* memberLabel;
    UILabel* mask;
    UILabel* l3;
    UIImageView* arrow;
}

- (void)setCell:(GroupObject*)one;

@end
