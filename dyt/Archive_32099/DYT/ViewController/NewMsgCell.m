//
//  NewMsgCell.m
//  DYT
//
//  Created by zhaoliang.chen on 13-6-6.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "NewMsgCell.h"
#import "TKImageCache.h"
#import "Tools.h"

@implementation NewMsgCell

#define HEADTAG 1000

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        if (!_recvHeadOnMsgMain) {
            _recvHeadOnMsgMain = [[TKImageCache alloc] initWithCacheDirectoryName:@"activity"];
            _recvHeadOnMsgMain.notificationName = @"recvHeadOnMsgMain";
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvHeadOnMsgMain:) name:@"recvHeadOnMsgMain" object:nil];
        }
        
        head = createPortraitView(44);
        head.left = 5;
        head.centerY = self.contentView.height/2;
        head.image = getBundleImage(@"defaultGroup.png");
        [self.contentView addSubview:head];
        
        newCount = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 18, 18)];
        newCount.center = CGPointMake(head.right-5, head.top+10);
        newCount.backgroundColor = [UIColor colorWithRed:218/255.0 green:8/255.0 blue:18/255.0 alpha:1];
        newCount.textColor = [UIColor whiteColor];
        newCount.textAlignment = NSTextAlignmentCenter;
        newCount.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:9];
        newCount.layer.cornerRadius = 9;
        newCount.layer.borderWidth = 2.0f;
        newCount.layer.borderColor = [UIColor whiteColor].CGColor;
        newCount.clipsToBounds = YES;
        [self.contentView addSubview:newCount];
        
        chatBG = getImageViewByImageName(@"oneMsgBG.png");
        chatBG.left = head.right;
        chatBG.centerY = head.centerY;
        chatBG.userInteractionEnabled = YES;
        [self.contentView addSubview:chatBG];
        chatBG.hidden = YES;
        
        groupName = [[UILabel alloc]initWithFrame:CGRectMake(head.right+20, 0, 250, 20)];
        groupName.backgroundColor = [UIColor clearColor];
        groupName.textColor = [UIColor blackColor];
        groupName.textAlignment = NSTextAlignmentLeft;
        groupName.font = [UIFont systemFontOfSize:16];
        groupName.bottom = self.contentView.centerY+5;
        [self.contentView addSubview:groupName];
        
        lTime = [[UILabel alloc]initWithFrame:CGRectMake(10, 2, chatBG.width/2, 20)];
        lTime.right = chatBG.width-5;
        lTime.backgroundColor = [UIColor clearColor];
        lTime.textColor = [UIColor colorWithRed:179.0/255.0 green:179.0/255.0 blue:179.0/255.0 alpha:1.0f];
        lTime.textAlignment = NSTextAlignmentRight;
        lTime.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:lTime];
        lTime.hidden = YES;
        
        lastChatName = [[UILabel alloc]initWithFrame:CGRectMake(groupName.left, 25, 50, 20)];
        lastChatName.backgroundColor = [UIColor clearColor];
        lastChatName.textColor = [UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0f];
        lastChatName.textAlignment = NSTextAlignmentLeft;
        lastChatName.font = [UIFont systemFontOfSize:14];
        lastChatName.top = self.contentView.centerY+10;
        [self.contentView addSubview:lastChatName];
        
        colon = [[UILabel alloc]initWithFrame:CGRectMake(lastChatName.right, lastChatName.top, 12, 20)];
        colon.backgroundColor = [UIColor clearColor];
        colon.textColor = [UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0f];
        colon.textAlignment = NSTextAlignmentLeft;
        colon.font = [UIFont systemFontOfSize:14];
        colon.text = @":";
        colon.width = [colon.text sizeWithFont:colon.font].width;
        colon.top = self.contentView.centerY+10;
        [self.contentView addSubview:colon];
        
        lastChatContent = [[UILabel alloc]initWithFrame:CGRectMake(colon.right, lastChatName.top, 160, 20)];
        lastChatContent.backgroundColor = [UIColor clearColor];
        lastChatContent.textColor = [UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0f];
        lastChatContent.textAlignment = NSTextAlignmentLeft;
        lastChatContent.font = [UIFont systemFontOfSize:14];
        lastChatContent.top = self.contentView.centerY+10;
        [self.contentView addSubview:lastChatContent];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    newCount.backgroundColor = [UIColor colorWithRed:218/255.0 green:8/255.0 blue:18/255.0 alpha:1];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_recvHeadOnMsgMain cancelOperations];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    head.left = 5;
    head.centerY = self.contentView.height/2;
    chatBG.left = head.right;
    chatBG.centerY = head.centerY;
    newCount.backgroundColor = [UIColor colorWithRed:218/255.0 green:8/255.0 blue:18/255.0 alpha:1];
}

- (void)setCell:(MsgObject*)obj {
    head.tag = HEADTAG+obj.subGroupid;
    if (obj.newMsgCount > 0) {
        if (obj.newMsgCount<10) {
            newCount.width = 18;
        }else if(obj.newMsgCount<100){
            newCount.width = 20;
        }else if(obj.newMsgCount<1000){
            newCount.width = 22;
        }
        newCount.hidden = NO;
        newCount.text = [NSString stringWithFormat:@"%d",obj.newMsgCount];
    } else {
        newCount.hidden = YES;
    }
    if (obj.subGroupHead.length!=0&&obj.subGroupHead!=nil) {
        NSURL *url = [NSURL URLWithString:getPicNameALL(obj.subGroupHead)];
        UIImage *img = [_recvHeadOnMsgMain imageForKey:[obj.subGroupHead lastPathComponent]                                          url:url queueIfNeeded:YES tag:head.tag];
        if (img) {
            head.image = img;
        }
    } else {
        head.image = getBundleImage(@"defaultGroup.png");
    }
    GroupObject* g = [GroupObject findByGroupid:obj.subGroupid];
    GroupObject* mainG = [GroupObject findByGroupid:g.parentid];
    groupName.text = [NSString stringWithFormat:@"%@ > %@",mainG.groupName,obj.subGroupName];
    
    if (check_string_valid( obj.lastName ) && check_string_valid( obj.lastContent ) ) {
        lastChatName.text = obj.lastName;
        lastChatName.width = [lastChatName.text sizeWithFont:lastChatName.font].width;
        if (lastChatName.width>50) {
            lastChatName.width=50;
        }
        lastChatContent.text = obj.lastContent;
        lTime.text = obj.lastTime;
        colon.hidden = NO;
        colon.left = lastChatName.right;
        lastChatContent.left = colon.right;
    } else {
        lastChatName.text = @"";
        lastChatContent.text = @"";
        lTime.text = @"";
        colon.hidden = YES;
    }
}

- (void)recvHeadOnMsgMain:(NSNotification*)sender {
    NSDictionary *dict = [sender userInfo];
    UIImage *img = [dict objectForKey:@"image"];
    int tag = [[dict objectForKey:@"tag"] intValue];
    
    if (head.tag == tag) {   
        head.image = img;
    }
}

@end
