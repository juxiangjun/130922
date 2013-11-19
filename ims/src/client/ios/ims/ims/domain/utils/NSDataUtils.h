//
//  NSDataUtils.h
//  ims
//
//  Created by Tony Ju on 10/17/13.
//  Copyright (c) 2013 Tony Ju. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDataUtils : NSObject

+(NSData *) convertIntToNSData: (int) value;
+(NSData *) convertLongToNSData: (long) value;
+(NSData *) convertNSNumberAsIntToNSData: (NSNumber*) value;
+(NSData *) convertNSNumberAsLongToNSData: (NSNumber*) value;
+(int) getIntvalueFromChar: (char*) data;


@end
