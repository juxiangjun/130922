//
//  Message.m
//  ims
//
//  Created by Tony Ju on 10/16/13.
//  Copyright (c) 2013 Tony Ju. All rights reserved.
//

#import "Message.h"

@implementation Message

@synthesize uid, from, to, eventTime, commandId, groupId, type, status, direction, error, contents;


- (NSStream*) encode {
    return NULL;
}


- (Message *) decode: (NSStream*) stream {
    return NULL;
}

@end
