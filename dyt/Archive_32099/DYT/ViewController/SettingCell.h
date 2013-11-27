//
//  SettingCell.h
//  DYT
//
//  Created by zhaoliang.chen on 13-7-3.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TKImageCache;
@interface SettingCell : UITableViewCell
<UITextFieldDelegate>{
    UILabel* titleLabel;
    UILabel* contentLabel;
    UIImageView* headImage;
    UITextField* nameTextField;
    TKImageCache* _recvHeadOnSettingCell;
}

@property(nonatomic,assign)int type;
@property(nonatomic,assign)int m_nRow;

- (void)setCell:(NSString*)title withContent:(NSString*)content;

@end
