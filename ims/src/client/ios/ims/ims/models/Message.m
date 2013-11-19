//
//  Message.m
//  ims
//
//  Created by Tony Ju on 10/16/13.
//  Copyright (c) 2013 Tony Ju. All rights reserved.
//

#import "Message.h"
#import "StringUtils.h"
#import "DateUtils.h"
#import "Constants.h"


@implementation Message

@synthesize uid, from, to, groupId, contents, eventDate, commandId, type, error, direction, status;

#pragma mark intialization

-(id) init {
    
    if (self != NULL) {
        
        uid = [StringUtils getUUID ];
        from = [StringUtils getFixedUUId];
        to = @"2f1b78c6-0fc3-46c8-8e71-8cefc8f866df";
        //to = @"be87a6fa-892c-4952-be93-d32e202525ea";
        groupId = [StringUtils getEmptyUUID];
        contents = @"";
        
        commandId = COMMAND_UNKNOWN;
        type = MSG_TYPE_UNKNOWN;
        error = ERROR_UNKNOWN;
        direction = MSG_DIRECTION_UNKNOWN;
        status = MSG_STATUS_UNKNOWN;
        
        eventDate = [DateUtils getNow];
        
    }
    
    return self;
    
}




@end
