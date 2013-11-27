//
//  DataManager.h
//  DYT
//
//  Created by zhaoliang.chen on 13-5-31.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebServiceManager.h"

@interface DataManager : NSObject {
    UserObject* userObject;
    NSArray* msgArray;
    int allNewMsgCount;
    ChatObject* deleteChat;
}

+(DataManager *)sharedManager;

- (UserObject*)getUser;
- (void)setUser:(UserObject*)user;

- (NSArray*)getMsgArray;
- (void)setMsgArray:(NSArray*)arr;

- (int)getMsgCount;
- (void)setMsgCount:(int)count;

+ (void)exChangeOut:(UIView *)changeOutView dur:(CFTimeInterval)dur;
+ (void)exChangeDelete:(UIView *)changeOutView dur:(CFTimeInterval)dur;

- (ChatObject*)getDeleteObj;
- (void)setDeleteObj:(ChatObject*)obj;

@end
