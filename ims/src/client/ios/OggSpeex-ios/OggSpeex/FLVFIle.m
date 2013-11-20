//
//  FLVFIle.m
//  SpeakHere
//
//  Created by Tony Ju on 11/20/13.
//
//

#import "FLVFIle.h"

@implementation FLVFIle
@synthesize localFileName;



-(id) initWithFileName:(NSString *)fileName  {
    if (self = [super init]) {
        
        NSData *data = [[NSData alloc] initWithBytes: (unsigned char[]) {0x46,0x4c,0x56,0x01,0x04,0x00,0x00,0x00,0x09} length:9];
        
        tags = [[NSMutableData alloc] init];
        [tags appendData:data];
        
    }
    return self;
}


-(void) addTag:(FLVTag *)tag {
    [tags appendData:[tag getTagData]];

}


-(void) close {
    
    //create file if it doesn't exist
    
    NSString *fileName = [[self getHomeDirectory] stringByAppendingPathComponent:@"test.flv"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:fileName])
        [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
    
    
    //append text to file (you'll probably want to add a newline every write)
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForWritingAtPath:fileName];
    
    [fileHandler seekToEndOfFile];
    [fileHandler writeData:tags];

    [fileHandler closeFile];
}

-(NSString *) getHomeDirectory {
    
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES) lastObject];
    //return [dir stringByAppendingPathComponent:@"caches"];
    return dir;
}

@end
