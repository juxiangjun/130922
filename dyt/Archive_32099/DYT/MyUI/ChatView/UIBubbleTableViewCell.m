//
//  UIBubbleTableViewCell.m
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import <QuartzCore/QuartzCore.h>
#import "UIBubbleTableViewCell.h"
#import "NSBubbleData.h"
#import "UserDetailViewController.h"
#import "TKImageCache.h"
#import "DYTImageCache.h"
#import "EmotionLabel.h"
#import "Tools.h"
#import "MyButton.h"

@interface UIBubbleTableViewCell ()

@property (nonatomic, retain) UIView *customView;
@property (nonatomic, retain) UIImageView *bubbleImage;
@property (nonatomic, retain) MyButton *btBubbleImage;
@property (nonatomic, retain) UIImageView *avatarImage;
@property (nonatomic, strong) UILabel* labelName;

- (void) setupInternalData;

@end

@implementation UIBubbleTableViewCell

@synthesize data = _data;
@synthesize customView = _customView;
@synthesize bubbleImage = _bubbleImage;
@synthesize btBubbleImage;
@synthesize showAvatar = _showAvatar;
@synthesize avatarImage = _avatarImage;
@synthesize labelName;

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
	[self setupInternalData];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.data = nil;
    self.customView = nil;
    [self.btBubbleImage resignFirstResponder];
    self.bubbleImage = nil;
    self.avatarImage = nil;
    self.btBubbleImage = nil;
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

- (void)setDataInternal:(NSBubbleData *)value {
	self.data = value;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvheadImg:) name:@"recvheadImg" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resizeBubble:) name:@"resizeBubble" object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getVoiceLengthInCell:) name:@"getVoiceLengthInCell" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSendMsgState:) name:@"getSendMsgState" object:nil];
    
	[self setupInternalData];
}

- (void)resizeBubble:(NSNotification *)notification{
    NSBubbleData *d = (NSBubbleData *)notification.object;
    if (self.data == d) {
        [self setupInternalData];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.customView.centerY = self.btBubbleImage.height/2;
    if (_chatObj.type == 2) {
        self.customView.centerX = self.btBubbleImage.width/2;
    }
}

- (void) setupInternalData {
    
    if (self.data==nil) {
        return;
    }
    
    //UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    //[self addGestureRecognizer:recognizer];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    if (!self.bubbleImage) {
#if !__has_feature(objc_arc)
        self.bubbleImage = [[[UIImageView alloc] init] autorelease];
#else
        self.bubbleImage = [[UIImageView alloc] init];
#endif
        //[self addSubview:self.bubbleImage];
    }
    if (self.btBubbleImage) {
        [self.btBubbleImage removeFromSuperview];
        self.btBubbleImage = nil;
    }
    self.btBubbleImage = [[MyButton alloc]initWithFrame:CGRectZero];
    //self.btBubbleImage.buttonType = UIButtonTypeCustom;
    //self.btBubbleImage = [MyButton buttonWithType:UIButtonTypeCustom];
    [btBubbleImage.smallBT addTarget:self action:@selector(onTagVoice) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.btBubbleImage];
    
    NSBubbleType type = self.data.type;
    
    CGFloat width = self.data.view.frame.size.width;
    CGFloat height = self.data.view.frame.size.height;

    CGFloat x = (type == BubbleTypeSomeoneElse) ? 0 : self.frame.size.width - width - self.data.insets.left - self.data.insets.right;
    CGFloat y = 0;
    // Adjusting the x coordinate for avatar
    if (self.showAvatar)
    {
        [self.avatarImage removeFromSuperview];
#if !__has_feature(objc_arc)
        self.avatarImage = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)] autorelease];
#else
        self.avatarImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
#endif
        self.avatarImage.layer.cornerRadius = 9.0;
        self.avatarImage.layer.masksToBounds = YES;
        self.avatarImage.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.2].CGColor;
        self.avatarImage.layer.borderWidth = 1.0;
        self.avatarImage.userInteractionEnabled = YES;
        self.avatarImage.tag = 10101;
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onShowInfo:)];
        [self.avatarImage addGestureRecognizer:tap];
        
        CGFloat avatarX = (type == BubbleTypeSomeoneElse) ? 2 : self.frame.size.width - 52;
        CGFloat avatarY = 5;
        
        self.avatarImage.frame = CGRectMake(avatarX, avatarY, 50, 50);
        [self addSubview:self.avatarImage];
        
        CGFloat delta = self.avatarImage.top;
        if (delta > 0) y = delta;
        
        if (type == BubbleTypeSomeoneElse) x += 70;
        if (type == BubbleTypeMine) x -= 70;
        
        self.labelName = [[UILabel alloc]initWithFrame:CGRectMake(self.avatarImage.left, self.avatarImage.bottom+5, self.avatarImage.width, 15)];
        self.labelName.backgroundColor = [UIColor clearColor];
        self.labelName.textColor = [UIColor blackColor];
        self.labelName.textAlignment = NSTextAlignmentCenter;
        self.labelName.font = [UIFont systemFontOfSize:12];
        [self addSubview:self.labelName];
        
        [self updateImage];
    }

    [self.customView removeFromSuperview];
    self.customView = self.data.view;
    //self.customView.frame = CGRectMake(x + self.data.insets.left, y + self.data.insets.top, width, height);
    if (type == BubbleTypeSomeoneElse) {
        self.customView.frame = CGRectMake(20, y + self.data.insets.top, width, height);
    }else{
        self.customView.frame = CGRectMake(10, y + self.data.insets.top, width, height);
    }
    
    //self.customView.backgroundColor = [UIColor clearColor];
    self.customView.userInteractionEnabled = NO;
    [self.btBubbleImage.smallBT addSubview:self.customView];
    self.btBubbleImage.myView = self.customView;

    self.bubbleImage.userInteractionEnabled = YES;
    if (type == BubbleTypeSomeoneElse) {
        UIEdgeInsets insets = UIEdgeInsetsMake(28,30,12,10);
        self.bubbleImage.image = [[UIImage imageNamed:@"chatBGOther.png"] resizableImageWithCapInsets:insets];
        [self.btBubbleImage.smallBT setBackgroundImage:[[UIImage imageNamed:@"chatBGOther.png"] resizableImageWithCapInsets:insets] forState:UIControlStateNormal];
        [self.btBubbleImage.smallBT setBackgroundImage:[[UIImage imageNamed:@"chatBGOtherDown.png"] resizableImageWithCapInsets:insets] forState:UIControlStateHighlighted];
        x-=10;
    } else {
        
        UIEdgeInsets insets = UIEdgeInsetsMake(28,15,12,30);
        self.bubbleImage.image = [[UIImage imageNamed:@"chatBGMe.png"] resizableImageWithCapInsets:insets];
        [self.btBubbleImage.smallBT setBackgroundImage:[[UIImage imageNamed:@"chatBGMe.png"] resizableImageWithCapInsets:insets] forState:UIControlStateNormal];
        [self.btBubbleImage.smallBT setBackgroundImage:[[UIImage imageNamed:@"chatBGMeDown.png"] resizableImageWithCapInsets:insets] forState:UIControlStateHighlighted];
        x+=10;
    }
    //UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    //recognizer.minimumPressDuration = 1.0f;
    //[self.btBubbleImage addGestureRecognizer:recognizer];


    self.bubbleImage.frame = CGRectMake(x, y, width + self.data.insets.left + self.data.insets.right, height + self.data.insets.top + self.data.insets.bottom);
    self.btBubbleImage.frame = CGRectMake(x, y, width + self.data.insets.left + self.data.insets.right, height + self.data.insets.top + self.data.insets.bottom);
    //[self.btBubbleImage setMyButton:CGSizeMake(width + self.data.insets.left + self.data.insets.right, height + self.data.insets.top + self.data.insets.bottom)];
    if (type == BubbleTypeSomeoneElse) {
        bgPoint = self.btBubbleImage.left;
    } else {
        bgPoint = self.btBubbleImage.right;
    }
    
    //加入显示时间长度的label
    if (labelVoiceLength) {
        [labelVoiceLength removeFromSuperview];
        labelVoiceLength = nil;
    }
    labelVoiceLength = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 16)];
    labelVoiceLength.centerY = self.btBubbleImage.centerY;
    labelVoiceLength.backgroundColor = [UIColor yellowColor];
    labelVoiceLength.textColor = [UIColor redColor];
    labelVoiceLength.textAlignment = NSTextAlignmentLeft;
    labelVoiceLength.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:labelVoiceLength];
    labelVoiceLength.hidden = YES;
    
    if (_chatObj.userid == [[DataManager sharedManager] getUser].userid) {
        [self judgeStats];
    }
}

- (void)onShowInfo:(UITapGestureRecognizer*)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"lookUser" object:[NSNumber numberWithInt:_chatObj.userid]];
}

- (void)onTagVoice {
    if (_chatObj.type == 3) {
        [self.data playVoice:nil];
    } else if (_chatObj.type == 2) {
        [self.data onTagThumb:nil];
    }
}

- (void)getVoiceLengthInCell:(NSNotification*)sender {
    NSDictionary* dic = (NSDictionary*)sender.object;
    [self updateVoiceLabel:[dic objectForKey:@"path"] withID:[[dic objectForKey:@"chatid"]intValue]];
}

- (void)updateVoiceLabel:(NSString*)path withID:(int)chatid {
    if (_chatObj.type != 3) {
        return ;
    } 
    if (chatid == _chatObj.chatid) {
        labelVoiceLength.hidden = NO;
        float length = [[YXSoundManager sharedManager]getVoiceLength:path];
        if (length < 1) {
            length = 1;
        }
        labelVoiceLength.text = [NSString stringWithFormat:@"%d",(int)length];
        labelVoiceLength.width = [labelVoiceLength.text sizeWithFont:labelVoiceLength.font].width;
        labelVoiceLength.width = 100;
        self.btBubbleImage.width += (length-1)*10;
        if (self.btBubbleImage.width > 200) {
            self.btBubbleImage.width = 200;
        }
        if (self.data.type==BubbleTypeSomeoneElse) {
            self.btBubbleImage.left = bgPoint;
            labelVoiceLength.left = self.btBubbleImage.right+10;
        } else {
            self.btBubbleImage.right = bgPoint;
            labelVoiceLength.right = self.btBubbleImage.left-10;
        }
    }
}

#pragma mark 接受头像图片的回调函数
- (void)recvheadImg:(NSNotification*)sender {
    NSDictionary *dict = [sender userInfo];
    UIImage *img = [dict objectForKey:@"image"];
    int tag = [[dict objectForKey:@"tag"] intValue];    
    if (tag == _chatObj.userid) {
        UIImageView* imgView = (UIImageView*)[self viewWithTag:10101];
        imgView.image = img;
    }
}

#pragma mark 更新头像图片
- (void)updateImage {
    if (self.data==nil) {
        return;
    }    
    _chatObj = self.data.chatObj;
    self.btBubbleImage.myChatObj = _chatObj;
    if (self.data.type == BubbleTypeMine) {
        if ([[DataManager sharedManager]getUser].headImage) {
            self.avatarImage.image = [[DataManager sharedManager]getUser].headImage;
        } else {
            if ([[DataManager sharedManager]getUser].userHeadURL.length == 0) {
                set_default_portrait(self.avatarImage);
            } else {
                NSString *userURL = getPicNameALL([[DataManager sharedManager]getUser].userHeadURL);
                
                if (check_string_valid(userURL)) {
                    UIImage *img = [[DYTImageCache sharedManager] retrieveHeadImage:userURL tag:_chatObj.userid];
                    
                    if (!img) {
                        set_default_portrait(self.avatarImage);
                    }else{
                        self.avatarImage.image = img;
                    }
                } else {
                    set_default_portrait(self.avatarImage);
                }
            }
        }        
    } else {
        UserObject* user = [UserObject findByID:_chatObj.userid];
        if (user==nil) {
            set_default_portrait(self.avatarImage);
        } else {
            
            NSString *url = user.userHeadURL;
            if (!check_string_valid(url)) {
                set_default_portrait(self.avatarImage);
            } else {
                NSString *userURL = getPicNameALL(url);
                UIImage *img = [[DYTImageCache sharedManager] retrieveHeadImage:userURL tag:_chatObj.userid];
                if (img) {
                    self.avatarImage.image = img;
                }else {
                    set_default_portrait(self.avatarImage);
                }
            }
        }
    }
    UserObject* user = [UserObject findByID:_chatObj.userid];
    self.labelName.text = user.userName;
    //[self updateVoiceLabel:self.data.soundPath withID:_chatObj.chatid];
}

- (void)getSendMsgState:(NSNotification*)sender {
    NSDictionary* dic = (NSDictionary*)sender.object;
    ChatObject* chat = [dic objectForKey:@"obj"];
    int state = [[dic objectForKey:@"state"]intValue];
    //NSLog(@"%d:   %d-----%d",state,chat.chatKey,self.data.chatObj.chatKey);
    if (chat.chatKey == self.data.chatObj.chatKey) {
        if (state == 1) {
            if (btFailMark) {
                [btFailMark removeFromSuperview];
                btFailMark = nil;
            }
            if (actView) {
                [actView stopAnimating];
                [actView removeFromSuperview];
                actView = nil;
            }
            actView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            actView.frame = CGRectMake(0, 0, 15, 15);
            actView.centerY = self.btBubbleImage.centerY;
            actView.right = self.btBubbleImage.left-10;
            [actView startAnimating];
            [self.contentView addSubview:actView];
        } else if (state == 2) {
            if (actView) {
                [actView stopAnimating];
                [actView removeFromSuperview];
                actView = nil;
            }
            if (btFailMark) {
                [btFailMark removeFromSuperview];
                btFailMark = nil;
            }
            btFailMark = getButtonByImageName(@"failMark.png");
            btFailMark.centerY = self.btBubbleImage.centerY;
            btFailMark.right = self.btBubbleImage.left-10;
            [btFailMark addTarget:self action:@selector(reSend) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:btFailMark];
        } else {
            if (actView) {
                [actView stopAnimating];
                [actView removeFromSuperview];
                actView = nil;
            }
            if (btFailMark) {
                [btFailMark removeFromSuperview];
                btFailMark = nil;
            }
        }
    }
}

- (void)judgeStats {
    if (_chatObj.chatStatus == eChatObjectStatus_Fail ) {
        if (actView) {
            [actView removeFromSuperview];
            actView = nil;
        }
        if (btFailMark) {
            [btFailMark removeFromSuperview];
            btFailMark = nil;
        }
        btFailMark = getButtonByImageName(@"failMark.png");
        btFailMark.centerY = self.btBubbleImage.centerY;
        btFailMark.right = self.btBubbleImage.left-10;
        [btFailMark addTarget:self action:@selector(reSend) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:btFailMark];
    } else if (_chatObj.chatStatus == eChatObjectStatus_Sending) {
        if (btFailMark) {
            [btFailMark removeFromSuperview];
            btFailMark = nil;
        }
        if (actView) {
            [actView stopAnimating];
            [actView removeFromSuperview];
            actView = nil;
        }
        actView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        actView.frame = CGRectMake(0, 0, 15, 15);
        actView.centerY = self.btBubbleImage.centerY;
        actView.right = self.btBubbleImage.left-10;
        [actView startAnimating];
        [self.contentView addSubview:actView];
    }
}

- (void)writeToSql {
    if ([ChatObject findByChatid:_chatObj.groupid withChatid:_chatObj.chatid]==nil) {
        [ChatObject addOneChat:_chatObj];
    }    
}


//- (void)longPress:(UITapGestureRecognizer *)recognizer {
////    [self.btBubbleImage becomeFirstResponder];
////    UIMenuController *menu = [UIMenuController sharedMenuController];
////    NSLog(@"self.btBubbleImage=%f,%f,%f,%f",self.btBubbleImage.superview.left,self.btBubbleImage.superview.top,self.btBubbleImage.superview.width,self.btBubbleImage.superview.height);
////    [menu setTargetRect:self.btBubbleImage.frame inView:self.btBubbleImage.superview];
////    [menu setMenuVisible:YES animated:YES];
////    NSLog(@"menu=%f,%f,%f,%f",menu.menuFrame.origin.x,menu.menuFrame.origin.y,menu.menuFrame.size.width,menu.menuFrame.size.height);
//    if (recognizer.state == UIGestureRecognizerStateBegan) {
//        UIBubbleTableViewCell *cell = (UIBubbleTableViewCell *)recognizer.view;
//        [cell becomeFirstResponder];
//        UIMenuItem *flag = [[UIMenuItem alloc] initWithTitle:@"Flag"action:@selector(flag:)];
////        UIMenuItem *approve = [[UIMenuItem alloc] initWithTitle:@"Approve"action:@selector(approve:)];
////        UIMenuItem *deny = [[UIMenuItem alloc] initWithTitle:@"Deny"action:@selector(deny:)];
//
//        UIMenuController *menu = [UIMenuController sharedMenuController];
//        [menu setMenuItems:[NSArray arrayWithObjects:flag, /*approve, deny,*/ nil]];
//        [menu setTargetRect:cell.frame inView:cell.superview];
//        [menu setMenuVisible:YES animated:YES];
//    }
//}

////复制消息
//- (void)copy:(id)sender {
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideTextField" object:nil];
//    for (UIView* v in self.customView.subviews) {
//        if ([v isKindOfClass:[EmotionLabel class]]) {
//            EmotionLabel* label = (EmotionLabel*)v;
//            if ([label.orignText isKindOfClass:[NSString class]] && label.orignText.length>0) {
//                UIPasteboard *pboard = [UIPasteboard generalPasteboard];
//                pboard.string = label.orignText;
//            }
//            break;
//        } else if ([v isKindOfClass:[UIImageView class]]) {
//            //UIImageView* img = (UIImageView*)v;
//            UIPasteboard *pboard = [UIPasteboard generalPasteboard];
//            //pboard.image = img.image;
//            pboard.string = self.data.chatObj.content;
//            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//            NSString *documentsDirectory = [paths objectAtIndex:0];
//            NSString *str = [documentsDirectory stringByAppendingPathComponent:@"activity"];
//            str = [str stringByAppendingFormat:@"/%@",[pboard.string lastPathComponent]];
//            if (!file_exists(str)) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"gotoPicView" object:self.data.chatObj];
//                return ;
//            }
//            break;
//        }
//    }
//}
//
//- (void)paste:(id)sender {
//    NSLog(@"Cell was approved");
//}
//
////删除消息
//- (void)delete:(id)sender {
//    [[DataManager sharedManager] setDeleteObj:_chatObj];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"showAlertView" object:[NSNumber numberWithInt:1]];
//}
//
//重新发送
- (void)reSend {
    [[DataManager sharedManager] setDeleteObj:_chatObj];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showAlertView" object:[NSNumber numberWithInt:2]];
}













@end
