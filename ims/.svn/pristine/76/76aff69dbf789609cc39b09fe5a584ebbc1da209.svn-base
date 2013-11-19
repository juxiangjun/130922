//
//  Message.h
//  ims
//
//  Created by Tony Ju on 10/16/13.
//  Copyright (c) 2013 Tony Ju. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject {
    
    
    NSString *uid;
    NSString *from;
    NSString *to;
    NSString *groupId;
    NSString *contents;
    
    int commandId;
    int type;
    int status;
    int direction;
    int error;
    int capacity;
    
    NSDate *eventDate;
}



@property (nonatomic, retain) NSString *uid;
@property (nonatomic, retain) NSString *from;
@property (nonatomic, retain) NSString *to;
@property (nonatomic, retain) NSString *groupId;
@property (nonatomic, retain) NSString *contents;

@property (nonatomic) int commandId;
@property (nonatomic) int type;
@property (nonatomic) int status;
@property (nonatomic) int direction;
@property (nonatomic) int error;

@property (nonatomic, retain) NSDate *eventDate;


- (id)init;

@end
