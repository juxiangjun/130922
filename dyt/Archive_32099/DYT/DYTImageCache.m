//
//  DYTImageCache.m
//  DYT
//
//  Created by zhuang yihang on 6/19/13.
//  Copyright (c) 2013 zhaoliang.chen. All rights reserved.
//

#import "DYTImageCache.h"

#import "TKImageCache.h"

static DYTImageCache *_sharedManager = nil;

@interface DYTImageCache(){
    TKImageCache *_recvHeadImg;
}

@end

@implementation DYTImageCache

+(DYTImageCache *)sharedManager {
    @synchronized( [DYTImageCache class] ){
        if(!_sharedManager)
            _sharedManager = [[self alloc] init];
        return _sharedManager;
    }
    return nil;
}

+(id)alloc {
    @synchronized ([DYTImageCache class]){
        NSAssert(_sharedManager == nil,
                 @"Attempted to allocated a second instance");
        _sharedManager = [super alloc];
        return _sharedManager;
    }
    return nil;
}

-(id)init {
    self = [super init];
    if (self) {
        _recvHeadImg = [[TKImageCache alloc] initWithCacheDirectoryName:@"activity"];
        _recvHeadImg.notificationName = @"recvheadImg";
        
    }
    return self;
}

- (UIImage *)retrieveHeadImage:(NSString *)url tag:(int)tag{
    UIImage *img = [_recvHeadImg imageForKey:[url lastPathComponent] url:[NSURL URLWithString:url] queueIfNeeded:YES tag:tag];
    return img;
}

@end
