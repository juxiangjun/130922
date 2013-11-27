//
//  SettingCell.m
//  DYT
//
//  Created by zhaoliang.chen on 13-7-3.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "SettingCell.h"
#import "TKImageCache.h"

@implementation SettingCell

@synthesize type;
@synthesize m_nRow;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 60, 20)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.textColor = [UIColor colorWithRed:170.0/255.0 green:170.0/255.0 blue:170.0/255.0 alpha:1.0f];
        titleLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:titleLabel];
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
    if (contentLabel) {
        contentLabel.centerY = self.contentView.height/2;
        contentLabel.right = self.contentView.width-15;
    }
    if (headImage) {
        headImage.centerY = self.contentView.height/2;
        headImage.right = self.contentView.width-15;
    }
    if (nameTextField) {
        nameTextField.centerY = self.contentView.height/2;
        nameTextField.right = self.contentView.width-15;
    }
}

- (void)setCell:(NSString*)title withContent:(NSString*)content {
    titleLabel.text = title;
    if (type == 1) {//头像
        if (!_recvHeadOnSettingCell) {
            _recvHeadOnSettingCell = [[TKImageCache alloc] initWithCacheDirectoryName:@"activity"];
            _recvHeadOnSettingCell.notificationName = @"recvHeadOnSettingCell";
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvHeadOnSettingCell:) name:@"recvHeadOnSettingCell" object:nil];
        }
        
        headImage = createPortraitView(44);
        headImage.right = self.contentView .width-15;
        headImage.centerY = self.contentView .height/2;
        headImage.userInteractionEnabled = YES;
        headImage.image = getBundleImage(@"defaultHead.png");
        headImage.contentMode = UIViewContentModeScaleAspectFill;
        
        if (![content isKindOfClass:[NSNull class]]&&content.length>0) {
            NSURL *url = [NSURL URLWithString:getPicNameALL(content)];
            UIImage *img = [_recvHeadOnSettingCell imageForKey:[content lastPathComponent]                                       url:url queueIfNeeded:YES];
            if (img) {
                headImage.image = img;
            }
        }
        [self.contentView addSubview:headImage];
    } else if (type == 2) {
        nameTextField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 300, 25)];
        nameTextField.right = self.contentView .width-15;
        nameTextField.centerY = self.contentView.height/2;
        nameTextField.backgroundColor = [UIColor clearColor];
        nameTextField.borderStyle = UITextBorderStyleNone;
        nameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        nameTextField.textAlignment = NSTextAlignmentRight;
        nameTextField.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:14];
        nameTextField.textColor = [UIColor blackColor];
        nameTextField.returnKeyType = UIReturnKeyDone;
        nameTextField.delegate = self;
        nameTextField.text = content;
        [self.contentView addSubview:nameTextField];
    } else if (type == 3) {
        contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(90, 0, 300, 20)];
        contentLabel.centerY = self.contentView.height/2;
        contentLabel.right = self.contentView.width-15;
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.textAlignment = NSTextAlignmentRight;
        contentLabel.textColor = [UIColor blackColor];
        contentLabel.font = [UIFont systemFontOfSize:15];
        contentLabel.text = content;
        [self.contentView addSubview:contentLabel];
    }
}

- (void)recvHeadOnSettingCell:(NSNotification*)sender {
    NSDictionary *dict = [sender userInfo];
    UIImage *img = [dict objectForKey:@"image"];
    headImage.image = img;
}



@end
