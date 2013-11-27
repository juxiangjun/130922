//
//  GroupActCell.h
//  DYT
//
//  Created by zhaoliang.chen on 13-6-25.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupActCell : UITableViewCell {
    UILabel* titleLabel;
    UILabel* contentLabel;
    UIImageView* arrow;
}

- (void)setCell:(NSString*)title withContent:(NSString*)content;

@end
