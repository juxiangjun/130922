//
//  GroupActCell.m
//  DYT
//
//  Created by zhaoliang.chen on 13-6-25.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "GroupActCell.h"

@implementation GroupActCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 60, 20)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.textColor = [UIColor colorWithRed:137.0/255.0 green:137.0/255.0 blue:137.0/255.0 alpha:1.0f];
        titleLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:titleLabel];
        
        contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 180, 20)];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.textAlignment = NSTextAlignmentRight;
        contentLabel.textColor = [UIColor blackColor];
        contentLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:contentLabel];
        
        arrow = getImageViewByImageName(@"arrow.png");
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
    titleLabel.centerY = self.contentView.height/2;
    contentLabel.centerY = self.contentView.height/2;
    arrow.centerY = self.contentView.height/2;
    arrow.right = self.contentView.width-10;
    contentLabel.right = arrow.left-20;
}

- (void)setCell:(NSString*)title withContent:(NSString*)content {
    titleLabel.text = title;
    contentLabel.text = content;
}

@end
