//
//  ChatObject.h
//  DYT
//
//  Created by zhaoliang.chen on 13-6-8.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "config.h"

typedef enum {
    eChatObjectStatus_Sending=1,
    eChatObjectStatus_Fail,
    eChatObjectStatus_Success,
}eChatObjectStatus;

@interface ChatObject : NSObject

@property(nonatomic,strong)NSDate* chatTime;
@property(nonatomic,strong)NSString* strTime;
@property(nonatomic,assign)int groupid;
@property(nonatomic,assign)int chatid;
@property(nonatomic,assign)eMessageType type;
@property(nonatomic,assign)int userid;
@property(nonatomic,strong)NSString* content;
@property(nonatomic,strong)NSString* thumbURL;
@property(nonatomic,assign)eChatObjectStatus chatStatus;
@property(nonatomic,assign)int chatKey;
@property(nonatomic,strong)NSString* userName;
@property(nonatomic,strong)UIImage* sendImg;
@property(nonatomic,assign)int millisecond;

+(ChatObject*)getOneChat:(NSDictionary*)dic;

+ (void)closeSql;
+(NSMutableArray *)findByGroupid:(int)groupid withType:(int)type;
+(ChatObject *)findByChatid:(int)groupid withChatid:(int)chatid;
+(int)addOneChat:(ChatObject *)one;
+(void)sortChat:(int)groupid;
+(void)updateOneChatState:(ChatObject *)one;
+(NSArray*)loadChatList:(int)groupid withPT:(int)point withALL:(BOOL)isAll;
+(NSMutableArray *)findPicByGroupid:(int)groupid;
+(void)deleteOneChatList:(int)groupid ;
+(void)deleteOneChatByChatid:(int)groupid withChatid:(int)chatid;
+(void)deleteOneChatByChatkey:(int)groupid withChatkey:(int)chatkey;

@end
