//
//  FLVTag.m
//  SpeakHere
//
//  Created by Tony Ju on 11/18/13.
//
//

#import "FLVTag.h"

@implementation FLVTag

@synthesize previous, len, timestamp, data;


-(id) initWithTagData :(int) previousTagSize  :(int) times :(NSData *)buffer {
    
    if ( self = [super init] ) {
        previous = previousTagSize;
        len = [buffer length]+1;
        timestamp = times;
        data = buffer;
    }
    return self;
    
}


-(NSMutableData *) getTagData  {
    NSMutableData *tag = [[NSMutableData alloc] init];
    //[tag appendData:[self getPreviousTagSize]];
    //[tag appendData:[self getTagHeader]];
    [tag appendBytes:(unsigned char[]){0xB2} length:1];
    [tag appendData:data];
    
    return tag;
}

-(NSData *) getFixedLengthData: (int) value : (int) fixedLength {
    NSMutableData *result = [[NSMutableData alloc] init];
    
    NSData *tmp = [NSData dataWithBytes:&value length:sizeof(value)];
    tmp = [self reverseNSDataOrder:tmp];
    int differencial = fixedLength - tmp.length;
    
    for (int i=0;i < differencial; i++) {
        [result appendBytes:"\x00" length:1];
    }


    [result appendData:tmp];
  
    if (result.length>fixedLength) {
        int start =result.length-fixedLength;
        NSData *truncated =  [result subdataWithRange:NSMakeRange(start, result.length-1)];
        return truncated;
    }
    
    return result;
}


- (NSData*) reverseNSDataOrder: (NSData*) value {
    
    const char *bytes = [value bytes];
    
    NSUInteger datalength = [value length];
    
    char *reverseBytes = malloc(sizeof(char) * datalength);
    
    NSUInteger index = datalength - 1;
    
    for (int i = 0; i < datalength; i++)
        reverseBytes[index--] = bytes[i];
    
    NSData *reversedData = [NSData dataWithBytesNoCopy:reverseBytes length: datalength freeWhenDone:YES];
    
    return reversedData;
    
}


-(NSData *) getPreviousTagSize {
    return [self getFixedLengthData:previous :4];
}

-(NSData *) getTagHeader {
    NSMutableData *result = [[NSMutableData alloc] init];
    [result appendBytes:"\x08" length:1];
    //body size
    [result appendData:[self getFixedLengthData:len :3]];
    
    //timestamp
    [result appendData:[self getFixedLengthData:timestamp :3]];
    
    [result appendData:[self getFixedLengthData:0 :4]];
    return result;
    //return [self reverseNSDataOrder:result];
}

@end
