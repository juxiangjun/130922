//
//  YXSoundManager.h
//  Sound
//
//  Created by zhuang yihang on 6/5/13.
//  Copyright (c) 2013 YX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


////////////////////////////////////////////////////////////////////////////////////////
//
//
////////////////////////////////////////////////////////////////////////////////////////

@protocol YXSoundManagerDelegate <NSObject>

- (void)soudnManagerRecordFinish:(NSString *)soundDataPath;
- (void)soudnManagerPlayFinish;


- (void)soudnManagerError:(NSError *)error;

@end

@interface YXSoundManager : NSObject{
    id<YXSoundManagerDelegate> delegate_;
}

@property (nonatomic, strong) id<YXSoundManagerDelegate> delegate;

+(YXSoundManager *)sharedManager;

- (BOOL)recordStart;
- (void)recordStop;

//获取声音大小,分4个等级,0-3，数字越大，说明声音越大
- (int)getSoundLevel;
//获取录音的长度
- (float)getsoundLength;

- (BOOL)playStart:(NSString *)filePath;
- (BOOL)play:(NSData *)data;
- (void)playStop;
- (BOOL)isPlaying;

- (float)getVoiceLength:(NSString *)filePath;

@end
