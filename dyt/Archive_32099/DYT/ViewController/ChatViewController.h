//
//  ChatViewController.h
//  DYT
//
//  Created by zhaoliang.chen on 13-5-31.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBubbleTableViewDataSource.h"
#import "CameraViewController.h"
#import "UIExpandingTextView.h"
#import "MyPicViewController.h"

@class ChatChooseView;
@class FaceBoard;
@class ActiveNoticeView;
@interface ChatViewController : UIViewController
<UIBubbleTableViewDataSource,UITextFieldDelegate,
CameraDelegate,UIImagePickerControllerDelegate,
UINavigationControllerDelegate,UIActionSheetDelegate,
YXSoundManagerDelegate,UIScrollViewDelegate,
UITableViewDelegate,UITableViewDataSource,
UITextViewDelegate,UIExpandingTextViewDelegate,
MyPicViewDelete,UIAlertViewDelegate> {
    UIView* theView_;
    UIExpandingTextView* chatTextField;
    UIImageView* textBG;
    ChatChooseView* chooseView;
    BOOL isVoice;
    BOOL isShowChooseView;
    UIButton* btKeepTalk;
    UIImageView* chatImg;
    UIImage *photo_;
    int m_nGroupid;
    NSArray* oldMsgArray;
    BOOL isLoadSql;
    int startPoint;
    int allMsgCount;
    NSTimer *timer;
    UIImageView* imgSound;
    UIButton* btVoice;                  //声音按钮
    UIButton* btExpression;             //表情按钮
    UIButton* btAdd;
    FaceBoard* faceView;                //表情键盘
    BOOL isShowFaceView;                //是否显示表情键盘
    
    BOOL hasRefresh;
    UIAlertView *reSendAlert;
    UIAlertView *deleteAlert;
    UIAlertView *pasteAlert;
    
    ActiveNoticeView* actView;
    NSTimer* actTimer;
}

@property(nonatomic,strong)UIBubbleTableView* chatTableView;
@property(nonatomic,strong)NSMutableArray* arrayBubbleData;

-(id)initWithData:(NSArray*)array;
-(id)initWithGroupid:(int)groupid;

@end
