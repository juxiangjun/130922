//
//  DirectoryUtils.m
//  ims
//
//  Created by Tony Ju on 10/22/13.
//  Copyright (c) 2013 Tony Ju. All rights reserved.
//

#import "PathUtils.h"

@implementation PathUtils

+(void) createDocuemntCacheFolder {
    [[NSFileManager defaultManager] createDirectoryAtPath:[self getHomeDirectory] withIntermediateDirectories:NO attributes:nil error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:[self getAudioDirectory] withIntermediateDirectories:NO attributes:nil error:nil];
}

+(NSURL *) getAudioFileURL:(NSString *) fileName {
    NSString* path = [[self getAudioDirectory] stringByAppendingPathComponent:fileName];
    return [self getURL:path];
}

+(NSURL *) getImageFileURL:(NSString *) fileName {
    NSString* path = [[self getImageDirectory] stringByAppendingPathComponent:fileName];
    return [self getURL:path];
}

+(NSURL *) getVedioFileURL:(NSString *) fileName{
    NSString* path = [[self getVedioDirectory] stringByAppendingPathComponent:fileName];
    return [self getURL:path];
}

+(NSString *) getHomeDirectory {

    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) lastObject];
    return [dir stringByAppendingPathComponent:@"caches"];
}

+(NSString *) getImageDirectory {
    NSString*  dir = [self getHomeDirectory];
    return [dir stringByAppendingPathComponent:@"image"];
}

+(NSString *) getAudioDirectory;{
    NSString*  dir = [self getHomeDirectory];
    return [dir stringByAppendingPathComponent:@"audio"];
}

+(NSString *) getVedioDirectory {
    NSString*  dir = [self getHomeDirectory];
    return [dir stringByAppendingPathComponent:@"vedio"];
}

+(NSURL *) getURL: (NSString *) path {
    NSURL *url = [NSURL fileURLWithPath:path];
    return url;
}

+(NSURL *) getURLByFileName :(NSString *) path :(NSString *) fileName {
    path = [path stringByAppendingPathComponent:fileName];
    NSURL *url = [NSURL fileURLWithPath:path];
    return url;
}


@end
