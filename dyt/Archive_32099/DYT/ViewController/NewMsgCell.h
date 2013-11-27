//
//  NewMsgCell.h
//  DYT
//
//  Created by zhaoliang.chen on 13-6-6.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TKImageCache;
@interface NewMsgCell : UITableViewCell {
    UIImageView* head;
    UIImageView* chatBG;
    UILabel* groupName;
    UILabel* lTime;
    UILabel* lastChatName;
    UILabel* lastChatContent;
    UILabel* colon;
    UILabel* newCount;
    TKImageCache* _recvHeadOnMsgMain;
}

- (void)setCell:(MsgObject*)obj;

@end
