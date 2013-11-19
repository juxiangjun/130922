//
//  rtmpdump1.h
//  rtmpdumplib
//
//  Created by aftek aftek on 09/07/10.
//  Copyright 2010 aftek. All rights reserved.
//   Aftek Ltd (http://www.aftek.com).

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ApplicationInterface.h"

@protocol RtmpLibDelegate

-(void)gotAudioData:(rtmp_audio *)audio_data dataSize:(long)dataSize;
-(void)gotVideoData:(rtmp_video *)video_data dataSize:(long)dataSize;
-(void)gotStatusData:(NSString *)status_data;
@end


@interface RtmpLib : NSObject {
	id<RtmpLibDelegate> delegate;
}
@property (nonatomic,assign) id<RtmpLibDelegate> delegate;
-(void)callAudioDelegateMethod:(rtmp_audio *)audio_data dataSize:(long)dataSize;
-(void)callDelegateVideoMethod:(rtmp_video *)video_data dataSize:(long)dataSize;
-(void)callStatusMethod:(NSString *)status_data;
-(id)init;
-(void)start:(char *)url streamID:(int)streamID ;
-(int)getRtmpStreamId;
-(rtmp_metadata)getMetadata;
-(BOOL)isConnected;
-(BOOL)isPaused;
-(void)closeRtmpStream;
-(void)pauseRtmpStream;
-(void)playRtmpStream;
@end
