//
//  ViewController.m
//  ims
//
//  Created by Tony Ju on 10/16/13.
//  Copyright (c) 2013 Tony Ju. All rights reserved.
//

#import "MessageViewController.h"
#import "SocketConn.h"
#import "Message.h"
#import "MessageCodec.h"
#import "Constants.h"
#import "AudioManager.h"
#import "PathUtils.h"

@interface MessageViewController ()

@end



@implementation MessageViewController
@synthesize  etMessage;


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *audioFileName = @"test.caf";
    [self connectToServer];
    audioManager = [AudioManager getInstance :audioFileName audioManagerDelegate :self];
    [PathUtils createDocuemntCacheFolder];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) connectToServer {
    
    if (conn != NULL || !conn.isConnected) {
        conn = [[SocketConn alloc] initWithDelegate:self];
        [conn connect];
    } else {
        NSLog(@"this client has been connected to server.");
    }

}


- (IBAction)btnSendMessageClick:(id)sender {
    
    Message *message = [[Message alloc]  init];
    message.commandId = COMMAND_SEND_P2P_MESSAGE;
    message.direction = MSG_DIRECTION_CLIENT_TO_SERVER;
    message.type = MSG_TYPE_TEXT;
    message.error = ERROR_UNKNOWN;
    message.status = MSG_STATUS_SENDING;
    message.contents = [etMessage text];
    NSData *data = [MessageCodec encode:message:0];
    
    NSLog(@"data size: %d", [data length]);
    [conn sendMessage:data];
    
}

#pragma mark ---audio actions---
- (IBAction)btnStartRecordClick:(id)sender {
    NSLog(@"btnStartRecordClick...");
    [audioManager startRecord];
    NSLog(@"...btnStartRecordClick");

}

-(void) startRecord {
}

- (IBAction)btnStopRecordClick:(id)sender {
    NSLog(@"btnStopRecordClick...");
    [audioManager stopRecord];
    NSLog(@"...btnStopRecordClick ");

}

- (IBAction)btnPlayAudioClick:(id)sender {
    NSLog(@"btnPlayAudioClick...");
    //[audioManager play:@"test.wav"];
    [audioManager testPlay];
    NSLog(@"...btnPlayAudioClick");
}

- (IBAction)btnSendAudioData:(id)sender {
    [self sendAudioData];
}

- (IBAction)btnReconnectToServer:(id)sender {
    [self connectToServer];
}



- (IBAction)btnPublishClick:(id)sender {

//    NSString *tmp = @"rtmp://192.168.7.96:1935/oflaDemo/998";
//    const char *url = [tmp UTF8String];
//    connPublish = RTMP_Alloc();
//    RTMP_Init(connPublish);
//    RTMP_SetupURL(connPublish, (char*) url);
//    RTMP_EnableWrite(connPublish);
//    RTMP_Connect(connPublish, NULL);
//    RTMP_ConnectStream(connPublish,0);
    aqRecorder = [AQRecorder getInstance];
    [aqRecorder startRecording];
    
}

-(void) sendAudioData {
    
    NSString* path= [[PathUtils getAudioDirectory] stringByAppendingPathComponent:@"test.wav"];
    
    if ([[NSFileManager defaultManager] isReadableFileAtPath:path]) {
        NSMutableData *audioData  = [NSMutableData dataWithContentsOfFile:path];
        Message* message = [[Message alloc] init];
        message.commandId = COMMAND_SEND_P2P_MESSAGE;
        message.direction = MSG_DIRECTION_CLIENT_TO_SERVER;
        message.type = MSG_TYPE_VOICE;
        message.error = ERROR_UNKNOWN;
        message.status = MSG_STATUS_SENDING;
        NSMutableData* data = [MessageCodec encode :message :[audioData length]];
        [data appendData:audioData];
        NSLog(@"data size: %d", [data length]);
        [conn sendMessage:data];
        
    } else {
        NSLog(@"file does not exist.");
    }

}

#pragma mark --- Audio Manager Delegate ---
-(void) onRecorderFinished {
    NSLog(@"onRecordVoiceFinished...");
    NSLog(@"...onRecordVoiceFinished.");
}

-(void) onPlayFinished {
    NSLog(@"");
}

#pragma mark --- Message Delegate ---

-(void) addReceivedMessage:(Message *) message  {
    
    NSLog(@"%d", message.type);
    NSLog(@"%d", MSG_TYPE_VOICE);
    if (message.type == MSG_TYPE_VOICE) {
        [audioManager playOnlineAudio:[message contents]];
    } else {
        self.etReceivedMessage.text = message.contents;
    }

}


@end
