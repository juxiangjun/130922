//
//  NSString+Base64.m
//  ims
//
//  Created by Tony Ju on 10/16/13.
//  Copyright (c) 2013 Tony Ju. All rights reserved.
//

#import "NSString+Base64.h"

@implementation NSString (Base64)

+ (NSString *)encode:(const uint8_t *)input length:(NSInteger)length {
    // this code seems to be floating on a lot of stackoverflow posts.
    // i'm not aware of any license issues but let me know in case there are
    // problems including the source in this project.
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData *data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t *output = (uint8_t *)data.mutableBytes;
    
    for (NSInteger i = 0; i < length; i += 3) {
        NSInteger value = 0;
        for (NSInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger index = (i / 3) * 4;
        output[index + 0] =                    table[(value >> 18) & 0x3F];
        output[index + 1] =                    table[(value >> 12) & 0x3F];
        output[index + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[index + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

+ (NSString *) base64StringFromData: (NSData *)data {
    return [self encode:data.bytes length:data.length];
}

- (NSString *)base64String {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [NSString base64StringFromData:data];
}

@end

