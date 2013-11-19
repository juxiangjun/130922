//
//  MessageDispatcher.h
//  ims
//
//  Created by Tony Ju on 10/17/13.
//  Copyright (c) 2013 Tony Ju. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"
#import "AsyncSocket.h"
#import "MessageHandler.h"
#import "MessageDelegate.h"


@interface MessageDispatcher : NSObject {
    MessageHandler* messageHandler;
    id messageDelegate;
}


+ (MessageDispatcher *)  getInstance: (id) delegate;

-(id) initWithMessageHandlerDelegate: (id) delegate ;

- (NSString *)dispatch:(AsyncSocket*)socket messageFromServer:(Message*)message;


@end