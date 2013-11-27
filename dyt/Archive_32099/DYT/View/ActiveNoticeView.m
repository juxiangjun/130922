//
//  ActiveNoticeView.m
//  DYT
//
//  Created by zhaoliang.chen on 13-7-22.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "ActiveNoticeView.h"

@implementation ActiveNoticeView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createView];
    }
    return self;
}

- (void)createView {    
    UIView* backV = [[UIView alloc]initWithFrame:self.bounds];
    backV.backgroundColor = [UIColor blackColor];
    backV.alpha = 0.5f;
    [self addSubview:backV];
    
    UILabel* l = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, self.width-50, self.height-10)];
    l.centerY = self.height/2;
    l.textAlignment = NSTextAlignmentLeft;
    l.textColor = [UIColor whiteColor];
    l.font = [UIFont systemFontOfSize:l.height-6];
    l.backgroundColor = [UIColor clearColor];
    l.text = @"群活动有更新";
    [self addSubview:l];
    
    UIButton* b = [UIButton buttonWithType:UIButtonTypeCustom];
    b.frame = CGRectMake(0, 0, 30, 30);
    b.layer.cornerRadius = b.height/2;
    b.backgroundColor = [UIColor clearColor];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"notificationClose.png" ofType:nil];
    UIImage *img = [UIImage imageWithContentsOfFile:path];
    [b setImage:img forState:UIControlStateNormal];
    [b addTarget:self action:@selector(removeView) forControlEvents:UIControlEventTouchUpInside];
    b.centerY = self.height/2;
    b.right = self.width-10;
    [self addSubview:b];
}

- (void)removeView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"removeTimer" object:nil];
}

@end
