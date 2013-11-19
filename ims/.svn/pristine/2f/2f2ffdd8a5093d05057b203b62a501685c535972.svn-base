//
//  MessageHandler.h
//  ims
//
//  Created by Tony Ju on 10/18/13.
//  Copyright (c) 2013 Tony Ju. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"
#import "MessageDelegate.h"



@interface MessageHandler : NSObject {
    id messageHandlerDelegate;
}


+(MessageHandler *) getInstance: (id) delegate;

-(void) onReceivedMessage: (Message *) value;

- (id) initWithDelegate:(id) delegate;

@end
