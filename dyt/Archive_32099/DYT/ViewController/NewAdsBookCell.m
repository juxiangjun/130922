//
//  NewAdsBookCell.m
//  DYT
//
//  Created by zhaoliang.chen on 13-6-26.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "NewAdsBookCell.h"
#import "TKImageCache.h"

@implementation NewAdsBookCell

#define GROUPHEADCHILD  2000

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _recvGroupChild = [[TKImageCache alloc] initWithCacheDirectoryName:@"activity"];
        _recvGroupChild.notificationName = @"recvGroupChild";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvGroupChild:) name:@"recvGroupChild" object:nil];
        
        head = createPortraitView(44);
        head.left = 10;
        head.centerY = self.contentView.height/2;
        head.image = getBundleImage(@"defaultGroup.png");
        [self.contentView addSubview:head];
        
        groupName = [[UILabel alloc]initWithFrame:CGRectMake(head.right+10, 2, self.contentView.width/2, 20)];
        groupName.backgroundColor = [UIColor clearColor];
        groupName.textColor = [UIColor blackColor];
        groupName.textAlignment = NSTextAlignmentLeft;
        groupName.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:groupName];
        
        UILabel* l1 = [[UILabel alloc]initWithFrame:CGRectMake(groupName.left, groupName.bottom+4, 15, 20)];
        l1.backgroundColor = [UIColor clearColor];
        l1.textColor = [UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0f];
        l1.textAlignment = NSTextAlignmentLeft;
        l1.font = [UIFont systemFontOfSize:14];
        l1.text = @"共";
        l1.width = [l1.text sizeWithFont:l1.font].width;
        [self.contentView addSubview:l1];
        
        memberLabel = [[UILabel alloc]initWithFrame:CGRectMake(l1.right, l1.top, 10, 20)];
        memberLabel.backgroundColor = [UIColor clearColor];
        memberLabel.textColor = [UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0f];
        memberLabel.textAlignment = NSTextAlignmentLeft;
        memberLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:memberLabel];
        
        l3 = [[UILabel alloc]initWithFrame:CGRectMake(50, l1.top, 15, 20)];
        l3.backgroundColor = [UIColor clearColor];
        l3.textColor = [UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0f];
        l3.textAlignment = NSTextAlignmentLeft;
        l3.font = [UIFont systemFontOfSize:14];
        l3.text = @"人";
        l3.width = [l3.text sizeWithFont:l3.font].width;
        [self.contentView addSubview:l3];
        
        mask = [[UILabel alloc]initWithFrame:CGRectMake(0, l1.top, 15, 20)];
        mask.backgroundColor = [UIColor clearColor];
        mask.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0f];
        mask.textAlignment = NSTextAlignmentRight;
        mask.font = [UIFont systemFontOfSize:14];
        mask.width = [mask.text sizeWithFont:mask.font].width;
        mask.right = self.contentView.width-20;
        [self.contentView addSubview:mask];
        
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

- (void)layoutSubviews {
    [super layoutSubviews];
    head.centerY = self.contentView.height/2;
    mask.centerY = self.contentView.height/2;
    arrow.centerY = self.contentView.height/2;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_recvGroupChild cancelOperations];
}

- (void)setCell:(GroupObject*)one {
    if ((![one.groupHead isKindOfClass:[NSNull class]])&&one.groupHead.length>0) {
        head.tag = GROUPHEADCHILD+one.groupid;
        NSURL *url = [NSURL URLWithString:getPicNameALL(one.groupHead)];
        UIImage *img = [_recvGroupChild imageForKey:[one.groupHead lastPathComponent]                                          url:url queueIfNeeded:YES tag:head.tag];
        if (img) {
            head.image = img;
        }
    }
    groupName.text = one.groupName;
    memberLabel.text = [NSString stringWithFormat:@"%d",one.memberCount];
    memberLabel.width = [memberLabel.text sizeWithFont:memberLabel.font].width;
    l3.left = memberLabel.right;
    l3.width = [l3.text sizeWithFont:l3.font].width;
    mask.text = one.remark;
    mask.width = [mask.text sizeWithFont:mask.font].width;
    mask.right = arrow.left-20;
}

- (void)recvGroupChild:(NSNotification*)sender {
    NSDictionary *dict = [sender userInfo];
    UIImage *img = [dict objectForKey:@"image"];
    int tag = [[dict objectForKey:@"tag"] intValue];
    if (tag == head.tag) {
        UIImageView* imgView = (UIImageView*)[self.contentView viewWithTag:tag];
        imgView.image = img;
    }
}



@end
