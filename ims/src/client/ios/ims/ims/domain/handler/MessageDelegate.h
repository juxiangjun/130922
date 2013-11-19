//
//  MessageDelegate.h
//  ims
//
//  Created by Tony Ju on 10/18/13.
//  Copyright (c) 2013 Tony Ju. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"

@protocol MessageHandlerDelegate
@required
- (void) addReceivedMessage: (Message *) message;
@end;


@interface MessageDelegate : NSObject

@end
