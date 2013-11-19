//
//  NSDataUtils.m
//  ims
//
//  Created by Tony Ju on 10/17/13.
//  Copyright (c) 2013 Tony Ju. All rights reserved.
//

#import "NSDataUtils.h"

@implementation NSDataUtils


+(NSData *) convertIntToNSData: (int) value {
    NSData* data =  [NSData dataWithBytes:&value length:sizeof(value)];
    return [self reverseNSDataOrder:data];
}

+(NSData *) convertLongToNSData: (long) value {
    NSData* data =   [NSData dataWithBytes:&value length:sizeof(value)];
    return [self reverseNSDataOrder:data];
    //return data;
}

+(NSData *) convertNSNumberAsIntToNSData: (NSNumber*) value{
    int tmp = [value intValue];
    NSData* data =   [NSData dataWithBytes:&tmp length:sizeof(tmp)];
    return [self reverseNSDataOrder:data];
    
}

+(NSData *) convertNSNumberAsLongToNSData: (NSNumber*) value {
    long tmp = [value longValue];
    NSData* data =   [NSData dataWithBytes:&tmp length:sizeof(tmp)];
    return [self reverseNSDataOrder:data];
}

+(NSString *) getNSStringFromNSData: (NSData *) data :(int) from : (int) to {
    //NSData* particial = [data subdataWithRange:NSMakeRange(from, [data length] - to)];
    NSData* particial = [data subdataWithRange:NSMakeRange(from, to)];
    return [[NSString alloc] initWithData:particial encoding:NSUTF8StringEncoding];
}

+(int) getIntvalueFromChar: (char*) value {
    NSData* data = [[NSData alloc] initWithBytes:value length:4];
    return CFSwapInt32BigToHost(*(int*)([data bytes]));
}

+(NSData*) reverseNSDataOrder: (NSData*) data {

        const char *bytes = [data bytes];
        
        NSUInteger datalength = [data length];
        
        char *reverseBytes = malloc(sizeof(char) * datalength);
    
        NSUInteger index = datalength - 1;
        
        for (int i = 0; i < datalength; i++)
            reverseBytes[index--] = bytes[i];
        
        NSData *reversedData = [NSData dataWithBytesNoCopy:reverseBytes length: datalength freeWhenDone:YES];
        
        return reversedData;
    
}


@end
