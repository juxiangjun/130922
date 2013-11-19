//
//  ViewController.h
//  ims
//
//  Created by Tony Ju on 10/16/13.
//  Copyright (c) 2013 Tony Ju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocketConn.h"
#import "AudioManager.h"
#import "AudioManagerDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "rtmp.h"
#import "AQRecorder.h"

@interface MessageViewController : UIViewController<
                                    MessageHandlerDelegate,
                                    AudioManagerDelegate>
{
    RTMP *connConsume;
    RTMP *connPublish;
    SocketConn *conn;
    AudioManager* audioManager;
    AQRecorder *aqRecorder;
}

@property (weak, nonatomic) IBOutlet UITextField *etReceivedMessage;

@property (weak, nonatomic) IBOutlet UITextField *etMessage;

- (IBAction)btnStartRecordClick:(id)sender;

- (IBAction)btnSendMessageClick:(id)sender;

- (IBAction)btnStopRecordClick:(id)sender;

- (IBAction)btnPlayAudioClick:(id)sender;

- (IBAction)btnSendAudioData:(id)sender;

- (IBAction)btnReconnectToServer:(id)sender;

- (IBAction)btnPublishClick:(id)sender;

@end
