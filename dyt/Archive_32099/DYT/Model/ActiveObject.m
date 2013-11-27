//
//  ActiveObject.m
//  DYT
//
//  Created by qucheng on 6/27/13.
//  Copyright (c) 2013 zhaoliang.chen. All rights reserved.
//

#import "ActiveObject.h"

@implementation ActiveObject


@synthesize eventAddr;
@synthesize eventContent;
@synthesize eventDate;
@synthesize eventID;
@synthesize eventTitle;

+ (ActiveObject*)getActiveObject:(NSDictionary*)dic {
    
    ActiveObject* one = [[ActiveObject alloc]init];
    
    one.eventTitle = [dic objectForKey:@"event_title"];
    one.eventContent = [dic objectForKey:@"event_content"];
    one.eventAddr = [dic objectForKey:@"event_address"];
    one.eventDate = [dic objectForKey:@"event_date"];
    one.eventID = [[dic objectForKey:@"id"]intValue];
    
    return one;
    
}

@end
