//
//  SocketConn.h
//  ims
//
//  Created by Tony Ju on 10/16/13.
//  Copyright (c) 2013 Tony Ju. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"
#import "MessageDispatcher.h"
#import "MessageDelegate.h"




@interface SocketConn : NSObject <AsyncSocketDelegate>{
    AsyncSocket *socket;
    MessageDispatcher* messageDispatcher;
    id messageDelegate;
}


@property (nonatomic, retain) AsyncSocket *socket;

-(BOOL) connect;
-(void) sendMessage:(NSData *) message;
-(id) initWithDelegate:(id) delegate;
-(BOOL) isConnected;
@end