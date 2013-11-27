//
//  Global.m
//  DYT
//
//  Created by zhuang yihang on 6/15/13.
//  Copyright (c) 2013 zhaoliang.chen. All rights reserved.
//

#import "Global.h"

static Global *_sharedManager = nil;

@implementation Global

+(Global *)sharedInstance{
    @synchronized( [Global class] ){
        if(!_sharedManager)
            _sharedManager = [[self alloc] init];
        return _sharedManager;
    }
    return nil;
}

+(id)alloc {
    @synchronized ([Global class]){
        NSAssert(_sharedManager == nil,
                 @"Attempted to allocated a second instance");
        _sharedManager = [super alloc];
        return _sharedManager;
    }
    return nil;
}

- (void)setDeviceToken:(NSString *)token{
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    [defs setObject:token forKey:@"deviceToken"];
    [defs synchronize];
}

- (NSString *)getDeviceToken{
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    return [defs objectForKey:@"deviceToken"];
}

- (NSString *)uuid
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    
    NSString *res = [NSString stringWithString:(__bridge NSString *)uuidStringRef];
    CFRelease(uuidStringRef);

    return res;
}

- (NSString *)saveChatPicture:(UIImage *)img{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *str = [documentsDirectory stringByAppendingPathComponent:@"activity"];

    
    NSString *filename = [[self uuid] stringByAppendingPathExtension:@"jpg"];
    
    NSString *filePath = [str stringByAppendingPathComponent:filename];

    NSData *d = UIImageJPEGRepresentation(img, 0.7);

    [d writeToFile:filePath atomically:YES];
    
    return filePath;
}

- (NSString *)saveChatSound:(NSString *)path{
    NSString *soundPath = [[YXResourceManager sharedManager] getSoundDirectionary];
    
    NSString *filename = [[self uuid] stringByAppendingPathExtension:@"amr"];
    
    NSString *filepath = [soundPath stringByAppendingPathComponent:filename];
    
    [[NSFileManager defaultManager] copyItemAtPath:path toPath:filepath error:nil];
    
    return filepath;
}

- (NSString *)saveChatPictureThumb:(UIImage *)img{
    
    UIImage *imgThumb = [self imageWithImage:img scaledToSize:CGSizeMake(128, 128/img.size.width*img.size.height)];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *str = [documentsDirectory stringByAppendingPathComponent:@"activity"];
    
    
    NSString *filename = [[[self uuid] stringByAppendingString:@"_thumb"] stringByAppendingPathExtension:@"jpg"];
    
    NSString *filePath = [str stringByAppendingPathComponent:filename];
    
    NSData *d = UIImageJPEGRepresentation(imgThumb, 1);
    [d writeToFile:filePath atomically:YES];
    
    return filePath;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
