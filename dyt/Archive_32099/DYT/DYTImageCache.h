//
//  DYTImageCache.h
//  DYT
//
//  Created by zhuang yihang on 6/19/13.
//  Copyright (c) 2013 zhaoliang.chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DYTImageCache : NSObject

+(DYTImageCache *)sharedManager;

- (UIImage *)retrieveHeadImage:(NSString *)url tag:(int)tag;

@end
