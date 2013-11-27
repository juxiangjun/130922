//
//  UserObject.h
//  DYT
//
//  Created by zhaoliang.chen on 13-6-5.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserObject : NSObject

@property(nonatomic,assign)int userid;
@property(nonatomic,strong)NSString* account;
@property(nonatomic,strong)NSString* userName;
@property(nonatomic,strong)NSString* password;
@property(nonatomic,assign)int sex;
@property(nonatomic,strong)NSString* location;
@property(nonatomic,strong)NSString* pos;
@property(nonatomic,strong)NSString* hometown;
@property(nonatomic,strong)NSString* explain;
@property(nonatomic,strong)NSString* userHeadURL;
@property(nonatomic,strong)UIImage* headImage;
@property(nonatomic,strong)NSString* encodeStr;
@property(nonatomic,strong)NSString*userHeadLargeURL;

+(UserObject*)getUserObj:(NSDictionary*)dic;
+(UserObject*)getUserObjByOne:(NSDictionary*)dic;

+ (void)closeSql;
-(id)initWithName:(NSString *)name head:(NSString *)head sex:(int)aSex ID:(int)ID;
+(NSMutableArray *)findAll;
+(int)count;
+(UserObject *)findByID:(int)ID;
+(void)addName:(UserObject *)user ;
+(void)deleteByID:(int)ID;
+(void)updataName:(UserObject *)user;








@end
