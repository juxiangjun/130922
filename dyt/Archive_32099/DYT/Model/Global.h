//
//  Global.h
//  DYT
//
//  Created by zhuang yihang on 6/15/13.
//  Copyright (c) 2013 zhaoliang.chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Global : NSObject

+(Global *)sharedInstance;


- (void)setDeviceToken:(NSString *)token;
- (NSString *)getDeviceToken;

- (NSString *)saveChatPicture:(UIImage *)img;
- (NSString *)saveChatPictureThumb:(UIImage *)img;
- (NSString *)saveChatSound:(NSString *)path;
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize ;
@end
