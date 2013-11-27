//
//  EmotionLabel.m
//  Jacky <newbdez33@gmail.com>
//
//  Created by Jacky on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EmotionLabel.h"

@implementation EmotionLabel

@synthesize orignText = _orignText;
@synthesize text = _text;
@synthesize font = _font;
@synthesize textColor;
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //_font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
        _font = [UIFont systemFontOfSize:20];
        //[self attachTapHandler];
        textColor = [UIColor whiteColor];
    }
    return self;
}

- (NSDictionary *)getEmotions {
    static NSDictionary *ems;
    if (!ems) {
        NSString *plistPath;
        
        //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
        //if ([[languages objectAtIndex:0] hasPrefix:@"zh"]) {
        //    plistPath = [[NSBundle mainBundle] pathForResource:@"faceMap_ch" ofType:@"plist"];
        //} else {
            plistPath = [[NSBundle mainBundle] pathForResource:@"faceMap_en" ofType:@"plist"];
        //}
        ems = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    }    
    return ems;    
}

- (void)setText:(NSString *)text {
    emotions = [self getEmotions];
    
    _orignText = text;
    NSString *replaced;
    NSMutableString *formatedResponse = [NSMutableString string];

    NSScanner *emotionScanner = [NSScanner scannerWithString:text];
    [emotionScanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@""]];
    while ([emotionScanner isAtEnd] == NO) {

        if([emotionScanner scanUpToString:@"[" intoString:&replaced]) {
            [formatedResponse appendString:replaced];
        }
        if(![emotionScanner isAtEnd]) {
            [emotionScanner scanString:@"[" intoString:nil];
            replaced = @"";
            [emotionScanner scanUpToString:@"]" intoString:&replaced];
            NSString* scrStr = [NSString stringWithFormat:@"[%@]",replaced];
            NSString *em ;
            NSArray* array = emotions.allValues;
            int index = 0;
            for (NSString *val in array) {
                if ([val isEqualToString:scrStr]) {
                    break;
                }
                index++;
            }
            if (index>=array.count) {
                em = nil ;
            } else {
                NSArray *keys = emotions.allKeys;
                em = [keys objectAtIndex:index];
                em = [em stringByAppendingString:@".png"];
            }
            

            
            if (em) {
                [formatedResponse appendFormat:@"<img src='%@' />", em];
            }else {
                [formatedResponse appendFormat:@"[%@]", replaced];
            }

            [emotionScanner scanString:@"]" intoString:nil];
        }
        
    }
    
    float r,g,b,a;
    [self.textColor getRed:&r green:&g blue:&b alpha:&a];
    NSString *c = [NSString stringWithFormat:@"rgb(%d, %d, %d)",(int)(r*a*255),(int)(g*a*255),(int)(b*a*255)];
    [formatedResponse replaceOccurrencesOfString:@"\n" withString:@"<br />" options:0 range:NSMakeRange(0, formatedResponse.length)];
    NSData *data = [[NSString stringWithFormat:@"<p style='font-size:%fpt;color:%@'>%@</p>", _font.pointSize,c, formatedResponse] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithCGSize:CGSizeMake(_font.lineHeight, _font.lineHeight)], DTMaxImageSize, @"System", DTDefaultFontFamily, nil];
    NSAttributedString *string = [[NSAttributedString alloc] initWithHTML:data options:options documentAttributes:NULL];
    self.attributedString = string;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    return (action == @selector(copy:));
}

//针对于copy的实现
-(void)copy:(id)sender{
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = self.text;
}

-(void)attachTapHandler{
    self.userInteractionEnabled = YES;  //用户交互的总开关
    //UILongPressGestureRecognizer *touch = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    UITapGestureRecognizer *touch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    touch.numberOfTapsRequired = 2;
    [self addGestureRecognizer:touch];
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self attachTapHandler];
}

-(void)handleTap:(UIGestureRecognizer*) recognizer{
    [self becomeFirstResponder];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setTargetRect:self.frame inView:self.superview.superview.superview];
    [menu setMenuVisible:YES animated:YES];
}

@end
