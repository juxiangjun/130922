//
//  SocketConn.m
//  ims
//
//  Created by Tony Ju on 10/16/13.
//  Copyright (c) 2013 Tony Ju. All rights reserved.
//

#define HOST @"192.168.7.96";
#define PORT 1974;

#import "SocketConn.h"
#import "Message.h"
#import "MessageCodec.h"
#import "Constants.h"
#import "MessageDelegate.h"

@implementation SocketConn
@synthesize socket;


-(id) initWithDelegate:(id) delegate {
    if (self != NULL) {
        socket = [[AsyncSocket alloc] initWithDelegate:self];
        messageDelegate = delegate;
    }
    return self;
}

-(BOOL) connect {
    
    BOOL result = FALSE;
    NSLog(@"ready to connect server.");
    
    if (socket != NULL) {
        [socket connectToHost:@"192.168.7.210" onPort:1974 error:NULL];
        [socket readDataWithTimeout:-1 tag:0];
        [self registration];
    }
    return result;
    
}

-(BOOL) isConnected {
    return [socket isConnected];
}

-(void) registration {
    Message *message = [[Message alloc] init];
    message.commandId = COMMAND_REGISTRATION;
    [self sendMessage:[MessageCodec encode:message:0]];
}

-(void) sendMessage: (NSData *) message {
    [socket writeData:message withTimeout:-1 tag:0];
    NSLog(@"send message...");
}


- (void) onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    [socket readDataWithTimeout:-1 tag:0];
    NSLog(@"connected to host");
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag {
    //[sock readDataToLength:2048*2048 withTimeout:-1 tag:tag];
}

- (void) onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"Message received.");
    
    messageDispatcher = [MessageDispatcher getInstance: messageDelegate];
    
    Message* message = [MessageCodec decode:data];
    [messageDispatcher dispatch:sock messageFromServer:message];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            [socket readDataWithTimeout:-1 tag:0];
        }
    });
    //
   
}

@end