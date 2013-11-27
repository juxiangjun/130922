//
//  GroupPicData.h
//  DYT
//
//  Created by zhaoliang.chen on 13-6-27.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupPicData : NSObject

@property(nonatomic,assign)int groupid;
@property(nonatomic,assign)int picid;
@property(nonatomic,assign)int userid;
@property(nonatomic,strong)NSString* thumbURL;
@property(nonatomic,strong)NSString* picURL;
@property(nonatomic,strong)NSString* uptime;

+ (GroupPicData*)getOnePic:(NSDictionary*)dic ;
+ (void)closeSql;
+ (void)addOneGroupPic:(GroupPicData *)one;
+ (GroupPicData *)findByGroupPic:(int)groupid withPicid:(int)picid;
+ (NSMutableArray*)loadGroupPic:(int)groupid ;

@end
