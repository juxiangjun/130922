//
//  MyButton.m
//  DYT
//
//  Created by zhaoliang.chen on 13-7-19.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "MyButton.h"
#import "EmotionLabel.h"

@implementation MyButton

@synthesize myChatObj;
@synthesize smallBT;
@synthesize myView;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        smallBT = [UIButton buttonWithType:UIButtonTypeCustom];
        smallBT.frame = self.bounds;
        [self addSubview:smallBT];
        
        UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(mylongPress:)];
        [self addGestureRecognizer:longPress];
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(reset) name:UIMenuControllerWillHideMenuNotification object:nil];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    smallBT.frame = self.bounds;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canResignFirstResponder{
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    return (action == @selector(copy:) || action == @selector(delete:));
}

-(void)copy:(id)sender {
    [self resignFirstResponder];
    for (UIView* v in myView.subviews) {
        if ([v isKindOfClass:[EmotionLabel class]]) {
            EmotionLabel* label = (EmotionLabel*)v;
            if ([label.orignText isKindOfClass:[NSString class]] && label.orignText.length>0) {
                UIPasteboard *pboard = [UIPasteboard generalPasteboard];
                pboard.string = label.orignText;
            }
            break;
        } else if ([v isKindOfClass:[UIImageView class]]) {
            UIPasteboard *pboard = [UIPasteboard generalPasteboard];
            pboard.string = myChatObj.content;
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *str = [documentsDirectory stringByAppendingPathComponent:@"activity"];
            str = [str stringByAppendingFormat:@"/%@",[pboard.string lastPathComponent]];
            if (!file_exists(str)) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"gotoPicView" object:myChatObj];
                return ;
            }
            break;
        }
    }
}

- (void)delete:(id)sender {
    [self resignFirstResponder];
    [[DataManager sharedManager] setDeleteObj:myChatObj];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showAlertView" object:[NSNumber numberWithInt:1]];
}

- (void)mylongPress:(UILongPressGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        //UIMenuItem *flag = [[UIMenuItem alloc] initWithTitle:@"复制"action:@selector(copy:)];
        //UIMenuItem *deny = [[UIMenuItem alloc] initWithTitle:@"删除"action:@selector(delete:)];
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:[NSArray arrayWithObjects: nil]];
        [menu setTargetRect:self.frame inView:self.superview];
        [menu setMenuVisible:YES animated:YES];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reset{
    [self resignFirstResponder];
}

@end
