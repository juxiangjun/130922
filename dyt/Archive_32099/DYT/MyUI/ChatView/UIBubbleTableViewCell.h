//
//  UIBubbleTableViewCell.h
//
//  Created by Alex ;
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import <UIKit/UIKit.h>
#import "NSBubbleData.h"
@interface UIBubbleTableViewCell : UITableViewCell
<UIAlertViewDelegate>{
    ChatObject* _chatObj;
    UILabel* labelVoiceLength;
    float bgPoint;
    UIActivityIndicatorView* actView;
    UIButton* btFailMark;
    UIAlertView *reSendAlert;
    UIAlertView *deleteAlert;
}

@property (nonatomic, strong) NSBubbleData *data;
@property (nonatomic) BOOL showAvatar;


- (void)updateImage;
- (void)writeToSql;

- (void)setDataInternal:(NSBubbleData *)value;
- (void) setupInternalData;
@end
