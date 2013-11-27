//
//  NSBubbleData.h
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import <Foundation/Foundation.h>

typedef enum _NSBubbleType {
    BubbleTypeMine = 0,
    BubbleTypeSomeoneElse = 1
} NSBubbleType;

@class TKImageCache;
@interface NSBubbleData : NSObject
<YXSoundManagerDelegate>{
    TKImageCache* _recvImgOnChat;
    TKImageCache* _recvBigImgOnChat;
    UIImageView* lagreImg;
    UIImageView* _voiceImg;
    UIView* imgBackView;
    UILabel* voiceLabel;
    UIView* voiceView;
}

@property(readonly,nonatomic,strong)NSDate *date;   //时间
@property(readonly,nonatomic)NSBubbleType type;      //类型，是本人还是对方
@property(readonly,nonatomic,strong) UIView *view;
@property(readonly,nonatomic)UIEdgeInsets insets;    //偏移量
@property(nonatomic,strong)UIImage *avatar;          //头像
@property(nonatomic,strong)NSString* avatarURL;
@property(nonatomic,strong)ChatObject* chatObj;
@property(nonatomic,strong)NSString* soundPath;

- (void)onTagThumb:(UITapGestureRecognizer*)sender;
- (void)playVoice:(UITapGestureRecognizer*)sender;
- (id)initWithText:(NSString *)text withObj:(ChatObject*)obj withName:(NSString*)name date:(NSDate *)date type:(NSBubbleType)type;
+ (id)dataWithText:(NSString *)text withObj:(ChatObject*)obj withName:(NSString*)name date:(NSDate *)date type:(NSBubbleType)type;
- (id)initWithImage:(UIImage *)image withObj:(ChatObject*)obj date:(NSDate *)date type:(NSBubbleType)type;
+ (id)dataWithImage:(UIImage *)image withObj:(ChatObject*)obj date:(NSDate *)date type:(NSBubbleType)type;
- (id)initWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type insets:(UIEdgeInsets)insets;
+ (id)dataWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type insets:(UIEdgeInsets)insets;
- (id)initWithVoice:(NSString *)soundUrl withObj:(ChatObject*)obj withName:(NSString*)name date:(NSDate *)date type:(NSBubbleType)type;
+ (id)dataWithVoice:(NSString *)soundUrl withObj:(ChatObject*)obj withName:(NSString*)name date:(NSDate *)date type:(NSBubbleType)type;
+ (id)dataWithURLImage:(NSString *)imgUrl withObj:(ChatObject*)obj withName:(NSString*)name date:(NSDate *)date type:(NSBubbleType)type ;
- (id)initWithURLImage:(NSString *)imgUrl withObj:(ChatObject*)obj withName:(NSString*)name date:(NSDate *)date type:(NSBubbleType)type;

- (id)initWithVoiceNew:(NSString *)soundUrl withObj:(ChatObject*)obj withName:(NSString*)name date:(NSDate *)date type:(NSBubbleType)type withLen:(float)len;
+ (id)dataWithVoiceNew:(NSString *)soundUrl withObj:(ChatObject*)obj withName:(NSString*)name date:(NSDate *)date type:(NSBubbleType)type withLen:(float)len;

@end
