//
//  AnnObject.h
//  DYT
//
//  Created by zhaoliang.chen on 13-6-7.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnnObject : NSObject

@property(nonatomic,strong)NSString* publishTime;
@property(nonatomic,strong)NSString* content;
@property(nonatomic,assign)int annID;
@property(nonatomic,strong)NSString* picURL;
@property(nonatomic,assign)int state;
@property(nonatomic,strong)NSString* title;
@property(nonatomic,strong)NSString* videoURL;
@property(nonatomic,strong)NSString* videoPic;

+ (AnnObject*)getOneAnnObject:(NSDictionary*)dic;

+(AnnObject *)findAnnByID:(int)annID;
+(void)addOneAnn:(AnnObject *)one;
+(NSMutableArray*)loadAnnList:(int)point;
+(int)getAnnCount;
+(AnnObject*)getFirstAnn;

@end
