//
//  FLVFIle.h
//  SpeakHere
//
//  Created by Tony Ju on 11/20/13.
//
//

#import <Foundation/Foundation.h>
#import "FLVTag.h"

@interface FLVFIle : NSObject {
    NSString *localFileName;
    NSMutableData *tags;
}

-(id) initWithFileName :(NSString *)fileName;
-(void) addTag :(FLVTag *) tag;
-(void) close;

@property (nonatomic, retain) NSString *localFileName;


@end
