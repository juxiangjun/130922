//
//  YXResourceManager.m
//  Sound
//
//  Created by zhuang yihang on 6/5/13.
//  Copyright (c) 2013 YX. All rights reserved.
//

#import "YXResourceManager.h"

static YXResourceManager *_sharedManager = nil;
@implementation YXResourceManager

+(YXResourceManager *)sharedManager{
    @synchronized( [YXResourceManager class] ){
        if(!_sharedManager)
            _sharedManager = [[self alloc] init];
        
    }
    return nil;
}

+(id)alloc
{
    @synchronized ([YXResourceManager class]){
        NSAssert(_sharedManager == nil,
                 @"Attempted to allocated a second instance");
        _sharedManager = [super alloc];
        return _sharedManager;
    }
    return nil;
}

-(id)init{
    self = [super init];
    if (self) {
        
        NSString *path = [self getAppCacheDirectionary];
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:NO attributes:nil error:&error];
        
        path = [self getHistoryDicrectionry];
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:NO attributes:nil error:&error];
        
        path = [self getSoundDirectionary];
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:NO attributes:nil error:&error];
        
        path = [self getImageDirectionary];
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:NO attributes:nil error:&error];
        
    }
    return self;
}


#pragma mark 获取存放数据的目录，所有相关的缓存数据都在该目录下
- (NSString *)getAppCacheDirectionary{
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) lastObject];
    return [cacheDir stringByAppendingPathComponent:@"dyt"];
}

#pragma mark 获取图片缓存文件目录
- (NSString *)getImageDirectionary{
    return [[self getAppCacheDirectionary] stringByAppendingPathComponent:@"image"];
}

#pragma mark 获取声音缓存文件目录
- (NSString *)getSoundDirectionary{
    return [[self getAppCacheDirectionary] stringByAppendingPathComponent:@"sound"];    
}

#pragma mark 获取聊天记录文件目录
- (NSString *)getHistoryDicrectionry{
    return [[self getAppCacheDirectionary] stringByAppendingPathComponent:@"history"];
}

@end
