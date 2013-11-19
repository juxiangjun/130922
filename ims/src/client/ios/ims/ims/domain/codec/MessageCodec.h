//
//  MessageCodec.h
//  ims
//
//  Created by Tony Ju on 10/16/13.
//  Copyright (c) 2013 Tony Ju. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"

@interface MessageCodec : NSObject


+(Message *) decode: (NSData *) data;
+(NSMutableData *) encode :(Message *) message :(int) capacity;


@end
