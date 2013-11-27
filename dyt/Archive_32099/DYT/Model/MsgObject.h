//
//  MsgObject.h
//  DYT
//
//  Created by zhaoliang.chen on 13-6-7.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatObject.h"

@interface MsgObject : NSObject

@property(nonatomic,strong)NSString* msgTime;
@property(nonatomic,strong)NSString* content;
@property(nonatomic,assign)int groupid;
@property(nonatomic,strong)NSString* groupName;
@property(nonatomic,assign)int msgid;
@property(nonatomic,assign)int state;
@property(nonatomic,assign)int type;
@property(nonatomic,assign)int userid;
@property(nonatomic,strong)NSString* picURL;
@property(nonatomic,strong)NSMutableArray* arrayChat;
@property(nonatomic,assign)int numOfMember;
@property(nonatomic,strong)NSString* lastName;
@property(nonatomic,strong)NSString* lastContent;
@property(nonatomic,strong)NSString* lastTime;
@property(nonatomic,assign)int subGroupid;
@property(nonatomic,strong)NSString* subGroupName;
@property(nonatomic,strong)NSString* subGroupHead;
@property(nonatomic,assign)int newMsgCount;
@property(nonatomic,assign)int lastMilli;

+(MsgObject*)getOneMsg:(NSDictionary*)dic;

+(void)closeSql;
+(NSMutableArray *)findAll;
+(void)addOneLast:(MsgObject *)one;
+(void)deleteByID:(int)groupid;
+(MsgObject *)findByID:(int)groupid;
+(void)updateByID:(MsgObject *)one;
+(void)updateCount:(int)groupid withNewCount:(int)newCount;
+(int)findCountByID:(int)groupid;
+(void)sortMsg;

@end
