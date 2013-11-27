//
//  ActiveObject.h
//  DYT
//
//  Created by qucheng on 6/27/13.
//  Copyright (c) 2013 zhaoliang.chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActiveObject : NSObject

@property(nonatomic,strong)NSString* eventTitle;
@property(nonatomic,strong)NSString* eventDate;
@property(nonatomic,strong)NSString* eventAddr;
@property(nonatomic,strong)NSString* eventContent;
@property(nonatomic,assign)int eventID;

+ (ActiveObject*)getActiveObject:(NSDictionary*)dic;


@end
