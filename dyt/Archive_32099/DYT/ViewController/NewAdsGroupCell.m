//
//  NewAdsGroupCell.m
//  DYT
//
//  Created by zhaoliang.chen on 13-6-25.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "NewAdsGroupCell.h"
#import "TKImageCache.h"

@implementation NewAdsGroupCell

#define ADDRESSTAG      1000
#define GROUPHEADTAG    2000

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        if (!_recvGroupMain) {
            _recvGroupMain = [[TKImageCache alloc] initWithCacheDirectoryName:@"activity"];
            _recvGroupMain.notificationName = @"recvGroupMain";
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvGroupMain:) name:@"recvGroupMain" object:nil];
        }
        
        head = createPortraitView(40);
        head.left = 10;
        head.centerY = self.contentView.height/2;
        head.image = getBundleImage(@"defaultGroup.png");
        [self.contentView addSubview:head];
        
        groupName = [[UILabel alloc]initWithFrame:CGRectMake(head.right+10, 2, self.contentView.width/2, 20)];
        groupName.backgroundColor = [UIColor clearColor];
        groupName.textColor = [UIColor colorWithRed:163.0/255.0 green:38.0/255.0 blue:38.0/255.0 alpha:1.0f];
        groupName.textAlignment = NSTextAlignmentLeft;
        groupName.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:groupName];
        
        allSubGroupName = [[UILabel alloc]initWithFrame:CGRectMake(groupName.left, groupName.bottom+4, 100, 20)];
        allSubGroupName.backgroundColor = [UIColor clearColor];
        allSubGroupName.textColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0f];
        allSubGroupName.textAlignment = NSTextAlignmentLeft;
        allSubGroupName.font = [UIFont systemFontOfSize:12];
        allSubGroupName.text = @"";
        [self.contentView addSubview:allSubGroupName];
        
        arrow = getImageViewByImageName(@"arrow.png");
        arrow.centerY = self.contentView.height/2;
        arrow.right = self.contentView.width-10;
        [self.contentView addSubview:arrow];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_recvGroupMain cancelOperations];
}

- (void)layoutSubviews {
    [super layoutSubviews];    
    head.left = 10;
    head.centerY = self.contentView.height/2;    
    arrow.centerY = self.contentView.height/2;
    arrow.right = self.contentView.width-10;
}

- (void)setCell:(GroupObject*)obj {
    head.tag = GROUPHEADTAG+obj.groupid;
    if (![obj.groupHead isKindOfClass:[NSNull class]]&&obj.groupHead.length>0) {
        NSURL *url = [NSURL URLWithString:getPicNameALL(obj.groupHead)];
        UIImage *img = [_recvGroupMain imageForKey:[obj.groupHead lastPathComponent]                                          url:url queueIfNeeded:YES tag:head.tag];
        if (img) {
            head.image = img;
        }
    }
    groupName.text = obj.groupName;
    for (int j=0; j<obj.subGroup.count; j++) {
        GroupObject* one = [obj.subGroup objectAtIndex:j];
        allSubGroupName.text = [allSubGroupName.text stringByAppendingFormat:@"%@",one.groupName];
        if (j!=one.subGroup.count-1) {
            allSubGroupName.text = [allSubGroupName.text stringByAppendingFormat:@","];
        }
    }
    allSubGroupName.width = [allSubGroupName.text sizeWithFont:allSubGroupName.font].width;
}

- (void)recvGroupMain:(NSNotification*)sender {
    NSDictionary *dict = [sender userInfo];
    UIImage *img = [dict objectForKey:@"image"];
    int tag = [[dict objectForKey:@"tag"] intValue];
    if (tag == head.tag) {
        UIImageView* imgView = (UIImageView*)[self.contentView viewWithTag:tag];
        imgView.image = img;
    }
}

@end
