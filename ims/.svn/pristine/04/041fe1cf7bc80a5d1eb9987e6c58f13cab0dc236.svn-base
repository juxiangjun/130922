//
//  MessageHandler.m
//  ims
//
//  Created by Tony Ju on 10/18/13.
//  Copyright (c) 2013 Tony Ju. All rights reserved.
//

#import "MessageHandler.h"
#import "Message.h"

@implementation MessageHandler

+(MessageHandler *) getInstance:  (id) delegate {
    
    static MessageHandler* instance;
    
    @synchronized(self) {
        if (!instance) {
            instance = [[MessageHandler alloc] initWithDelegate:delegate ];
            
        }
        return instance;
    }
}

- (id) initWithDelegate:(id) delegate {
    
    if (self != NULL) {
        messageHandlerDelegate = delegate;
    }
    return self;
 }
- (void) onReceivedMessage: (Message*) message {
    
    [messageHandlerDelegate addReceivedMessage: message];
    
}


@end
