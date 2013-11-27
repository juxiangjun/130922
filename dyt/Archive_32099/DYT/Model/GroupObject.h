//
//  GroupObject.h
//  DYT
//
//  Created by zhaoliang.chen on 13-6-7.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupObject : NSObject

@property(nonatomic,assign)int groupid;
@property(nonatomic,strong)NSString* groupName;
@property(nonatomic,strong)NSString* remark;
@property(nonatomic,assign)int parentid;
@property(nonatomic,strong)NSString* groupHead;
@property(nonatomic,strong)NSMutableArray* subGroup;
@property(nonatomic,assign)int memberCount;
@property(nonatomic,strong)NSMutableArray* arrGroupPic;

+(GroupObject*)getOneGroup:(NSDictionary*)dic;

+ (void)closeSql;
+(GroupObject *)findByGroupid:(int)groupid;
+(NSMutableArray *)findByParentid:(int)parentid;
+(void)addOneGroup:(GroupObject *)one;
+(void)updateGroup:(GroupObject *)one;
+(void)deleteByGroupid:(int)groupid;
+(void)deleteAllGroupid;
+(UserObject *)findMemberByGroupAndUserid:(int)groupid withUserid:(int)userid;
+(NSMutableArray *)findMemberByGroup:(int)groupid;
+(void)addOneMember:(UserObject*)user withGroupid:(int)groupid;
+(void)updateOneMember:(UserObject*)user withGroupid:(int)groupid;

@end
