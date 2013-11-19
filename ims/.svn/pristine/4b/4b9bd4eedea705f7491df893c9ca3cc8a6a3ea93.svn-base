//
//  MessageDispatcher.m
//  ims
//
//  Created by Tony Ju on 10/17/13.
//  Copyright (c) 2013 Tony Ju. All rights reserved.
//

#import "MessageDispatcher.h"
#import "MessageHandler.h"
#import "Constants.h"


@implementation MessageDispatcher


+(MessageDispatcher *) getInstance: (id) delegate {
    
    static MessageDispatcher* instance;
    
    @synchronized(self) {
        if (!instance) {
            instance  = [[MessageDispatcher alloc] initWithMessageHandlerDelegate:delegate];
        }
        return instance;
    }
    
}


-(id) initWithMessageHandlerDelegate:(id) delegate {
    
    if (self != NULL) {
        
        messageDelegate = delegate;
    }
    return self;
}


- (NSString *)dispatch:(AsyncSocket*)socket messageFromServer:(Message*)message {
    
    [self onReceivedP2PMessage:message];
    
    switch (message.commandId) {
        case COMMAND_ON_RECEIVED_P2P_MESSAGE:
            [self onReceivedP2PMessage:message];
            break;
            
        default:
            break;
    }
    
    return NULL;
}


-(void) onReceivedP2PMessage: (Message *) message{
    messageHandler = [MessageHandler getInstance:messageDelegate];
    [messageHandler onReceivedMessage:message];
}





@end
