//
//  UserDetailCell.m
//  DYT
//
//  Created by zhaoliang.chen on 13-6-25.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "UserDetailCell.h"

@implementation UserDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 70, 20)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.textColor = [UIColor colorWithRed:170.0/255.0 green:170.0/255.0 blue:170.0/255.0 alpha:1.0f];
        titleLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:titleLabel];
        
        contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(titleLabel.right+15, 0, 200, 20)];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.textAlignment = NSTextAlignmentLeft;
        contentLabel.textColor = [UIColor blackColor];
        contentLabel.font = [UIFont fontWithName:@"STHeitiTC-Medium" size:16];
        contentLabel.numberOfLines = 0;
        [self.contentView addSubview:contentLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    titleLabel.centerY = self.contentView.height/2;
    contentLabel.centerY = titleLabel.centerY;
}

- (void)setCell:(NSString*)title withContent:(NSString*)content {
    titleLabel.text = title;
    contentLabel.text = content;
    CGSize size = CGSizeMake(contentLabel.width,2000);
    CGSize labelsize = [contentLabel.text sizeWithFont:contentLabel.font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
    contentLabel.frame = CGRectMake(contentLabel.left, contentLabel.top, contentLabel.width, labelsize.height);
    //self.contentView.height = contentLabel.height+20;
}

@end
