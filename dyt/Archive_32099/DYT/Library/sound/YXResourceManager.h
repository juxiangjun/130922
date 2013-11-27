//
//  YXResourceManager.h
//  Sound
//
//  Created by zhuang yihang on 6/5/13.
//  Copyright (c) 2013 YX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YXResourceManager : NSObject

+(YXResourceManager *)sharedManager;


- (NSString *)getImageDirectionary;
- (NSString *)getSoundDirectionary;
- (NSString *)getHistoryDicrectionry;

@end
