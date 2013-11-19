//
//  FLVTag.h
//  SpeakHere
//
//  Created by Tony Ju on 11/18/13.
//
//

#import <Foundation/Foundation.h>

@interface FLVTag : NSObject {
//    int previous;
//    int len;
//    int timestamp;
//    NSData *data;
}

@property (nonatomic, assign) int previous;
@property (nonatomic, assign) int len;
@property (nonatomic, assign) int timestamp;
@property (nonatomic, assign) NSData *data;


-(id) initWithTagData :(int) previousTagSize  :(int) times :(NSData *)buffer;
-(NSMutableData *) getTagData ;

@end
