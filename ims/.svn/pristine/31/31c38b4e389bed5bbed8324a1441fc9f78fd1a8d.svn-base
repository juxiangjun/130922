//
//  MessageCodec.m
//  ims
//
//  Created by Tony Ju on 10/16/13.
//  Copyright (c) 2013 Tony Ju. All rights reserved.
//

#import "MessageCodec.h"
#import "NSString+base64.h"
#import "NSDataUtils.h"

@implementation MessageCodec


+(Message *) decode: (NSData *) data {
    
    Message* message = [[Message alloc] init];
    
    int capacity = [data length] -4;
    
    NSData* tmp = [data subdataWithRange:NSMakeRange(4, capacity)];
    
    
    const char *bytes = [tmp bytes];
    
    NSLog(@"%s", bytes);
    
    char* uidBytes = malloc(sizeof(char) * 36);
    char* fromBytes = malloc(sizeof(char) * 36);
    char* toBytes = malloc(sizeof(char) * 36);
    char* groupIdBytes = malloc(sizeof(char) * 36);
    
    char* commandIdBytes = malloc(sizeof(int));
    char* typeBytes = malloc(sizeof(int));
    char* errorBytes = malloc(sizeof(int));
    char* statusBytes = malloc(sizeof(int));
    char* directionBytes = malloc(sizeof(int));
    
    int start = 0;
    
    for (int i=start; i<36+start; i++) {
        uidBytes[i] = bytes[i+start];
    }
    
    for (int i=36+start; i<72+start; i++) {
        fromBytes[i-36] = bytes[i+start];
    }
    
    for (int i=72+start; i<108+start; i++) {
        toBytes[i-72] = bytes[i+start];
    }
    
    
    for (int i=108+start; i<144+start; i++) {
        groupIdBytes[i-108] = bytes[i+start];
    }
    
    
    for (int i=144+start; i<148+start; i++) {
        commandIdBytes[i-144] = bytes[i+start];
    }
    
    
    for (int i=148+start; i<152+start ; i++) {
        typeBytes[i-148] = bytes[i+start];
    }
    
    for (int i=152+start; i<156+start; i++) {
        errorBytes[i-152] = bytes[i+start];
    }
    
    for (int i=156+start; i<160+start; i++) {
        statusBytes[i-156] = bytes[i+start];
    }
    
    for (int i=160+start; i<=164+start; i++) {
        directionBytes[i-160] = bytes[i+start];
    }
    
    int content = capacity - 164;
    
    
    if (content>0) {
        char *contentsBytes = malloc(sizeof(char) * content);
        for (int i=164; i<=capacity; i++) {
            contentsBytes[i-164] = bytes[i];
        }
        message.contents =[[NSString alloc] initWithBytes:contentsBytes length:content encoding:NSUTF8StringEncoding];
    }
    

    message.uid = [[NSString alloc] initWithBytes:uidBytes length:36 encoding:NSUTF8StringEncoding];
    message.from = [[NSString alloc] initWithBytes:fromBytes length:40 encoding:NSUTF8StringEncoding];
    message.to = [[NSString alloc] initWithBytes:toBytes length:36 encoding:NSUTF8StringEncoding];
    message.groupId = [[NSString alloc] initWithBytes:groupIdBytes length:36 encoding:NSUTF8StringEncoding];
    message.commandId = [NSDataUtils getIntvalueFromChar:commandIdBytes];
    
    message.type = [NSDataUtils getIntvalueFromChar:typeBytes];
    message.error = [NSDataUtils getIntvalueFromChar:errorBytes];
    message.status = [NSDataUtils getIntvalueFromChar:statusBytes];
    message.direction = [NSDataUtils getIntvalueFromChar:directionBytes];
    
    return message;
}





+ (NSMutableData *) encode :(Message *)message :(int)capacity {
    
    capacity = capacity + 168;
    
    NSMutableData* result = [[NSMutableData alloc] init];
    
    
    NSData* contents = NULL;
    NSString* msgContents =  message.contents;
    if (msgContents != NULL && [msgContents length] >1) {
        contents = [msgContents dataUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"contents:%@", contents);
        capacity = capacity + [contents length];
    }
    
    [result appendData:[NSDataUtils convertIntToNSData:capacity]];
    
    NSData* uid  = [message.uid dataUsingEncoding:NSUTF8StringEncoding];
    NSData* from  = [message.from dataUsingEncoding:NSUTF8StringEncoding];
    NSData* to  = [message.to dataUsingEncoding:NSUTF8StringEncoding];
    NSData* groupId  = [message.groupId dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData* commandId = [NSDataUtils convertIntToNSData:message.commandId];
    NSLog(@"%d", message.commandId);
    NSData* type = [NSDataUtils convertIntToNSData:message.type];
    NSLog(@"type:%@", type);
    NSData* error = [NSDataUtils convertIntToNSData:message.error];
    NSLog(@"error:%@", error);
    NSData* status = [NSDataUtils convertIntToNSData:message.status];
    NSLog(@"status:%@", status);
    NSData* direction = [NSDataUtils convertIntToNSData:message.direction];
    NSLog(@"direction:%@", direction);
    
    [result appendData:uid];
    [result appendData:from];
    [result appendData:to];
    [result appendData:groupId];
    [result appendData:commandId];
    [result appendData:type];
    [result appendData:error];
    [result appendData:status];
    [result appendData:direction];
    
    if (contents != NULL) {
        [result appendData:contents];
    }
   
    
    return  result;
    
}


@end