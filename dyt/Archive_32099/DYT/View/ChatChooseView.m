//
//  ChatChooseView.m
//  DYT
//
//  Created by zhaoliang.chen on 13-6-5.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "ChatChooseView.h"

@implementation ChatChooseView

#define CHOOSEBTTAG 100

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithPatternImage:getBundleImage(@"chooseBG.png")];
        
        //NSString* btName[5] = {@"picture.png", @"camera.png", @"location.png", @"historyList.png", @"plus.png"};
        NSString* btName[2] = {@"picture.png", @"camera.png"};
        for (int i=0; i<2; i++) {
            UIButton* b = getButtonByImageName(btName[i]);
            b.tag = CHOOSEBTTAG+i;
            [b addTarget:self action:@selector(onClickbt:) forControlEvents:UIControlEventTouchUpInside];
            b.top = 20+(20+b.height)*(i/4);
            b.left = 20+(20+b.width)*(i%4);
            [self addSubview:b];
        }
    }
    return self;
}

- (void)onClickbt:(id)sender {
    UIButton* b = (UIButton*)sender;
    switch (b.tag) {
        case CHOOSEBTTAG+0: {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"onChoosePic" object:nil];
        }
            break;
        case CHOOSEBTTAG+1: {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"onCamera" object:nil];
        }
            break;
        case CHOOSEBTTAG+2: {
            
        }
            break;
        case CHOOSEBTTAG+3: {
            
        }
            break;
        case CHOOSEBTTAG+4: {
            
        }
            break;
        default:
            break;
    }
}

@end
