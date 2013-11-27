//
//  ChatViewController.m
//  DYT
//
//  Created by zhaoliang.chen on 13-5-31.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "ChatViewController.h"
#import "UIBubbleTableView.h"
#import "UserDetailViewController.h"
#import "ChatChooseView.h"
#import "FaceBoard.h"
#import "GroupSettingViewController.h"
#import "PictureViewController.h"
#import "ChoosePicViewController.h"
#import "ActiveNoticeView.h"
#import "config.h"
#import "Global.h"

#define KEYBOARD_DISMISS_TIME 0.25

@interface ChatViewController (){
    BOOL bFirst;
}

@end

@implementation ChatViewController

@synthesize chatTableView;
@synthesize arrayBubbleData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lookUser:) name:@"lookUser" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChoosePic:) name:@"onChoosePic" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCamera:) name:@"onCamera" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRecvMsgOnChat:) name:@"onRecvMsgOnChat" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLoadMore:) name:@"onLoadMore" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRecvEmjoy:) name:@"onRecvEmjoy" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRecvDeleteEmjoy:) name:@"onRecvDeleteEmjoy" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendChatMsg:) name:@"sendChatMsg" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoPicView:) name:@"gotoPicView" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publishImg:) name:@"publishImg" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardDidChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeleteOneChat:) name:@"onDeleteOneChat" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadChatTableView:) name:@"reloadChatTableView" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideTextField:) name:@"hideTextField" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendPasteImg:) name:@"sendPasteImg" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendPasteText:) name:@"sendPasteText" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addOneCell:) name:@"addOneCell" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAlertView:) name:@"showAlertView" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeTimer:) name:@"removeTimer" object:nil];
        
        arrayBubbleData = [NSMutableArray new];
        startPoint = 1;
        allMsgCount = -1;
        isShowFaceView = NO;
        
        bFirst = YES;
        hasRefresh = NO;
    }
    return self;
}

-(id)initWithData:(NSArray*)array {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        oldMsgArray = array;
        if (oldMsgArray.count>0) {
            ChatObject* obj = [oldMsgArray objectAtIndex:0];
            m_nGroupid = obj.groupid;
        }
        isLoadSql = NO;
        hasRefresh = NO;
    }
    return self;
}

-(id)initWithGroupid:(int)groupid {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        m_nGroupid = groupid;
        //[ChatObject sortChat:groupid];
        oldMsgArray = [ChatObject findByGroupid:m_nGroupid withType:0];
        isLoadSql = YES;
        hasRefresh = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.navigationController.navigationBar setBackgroundImage:getBundleImage(@"navBG.png") forBarMetrics:UIBarMetricsDefault];
    self.view.backgroundColor = [UIColor colorWithPatternImage:getBundleImage(@"loginBG.png")];
    GroupObject* thisGroup = [GroupObject findByGroupid:m_nGroupid];
    self.title = thisGroup.groupName;
    isVoice = NO;
    isShowChooseView = NO;
    
    UIButton *button1 = getButtonByImageName(@"btBack.png");
    [button1 addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn1 = [[UIBarButtonItem alloc] initWithCustomView:button1];
    self.navigationItem.leftBarButtonItem = btn1;
    
    UIButton *button2 = getButtonByImageName(@"btLook.png");
    [button2 addTarget:self action:@selector(goLook) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn2 = [[UIBarButtonItem alloc] initWithCustomView:button2];
    self.navigationItem.rightBarButtonItem = btn2;
    
    theView_ = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-self.navigationController.navigationBar.height)];
    [self.view addSubview:theView_];
    
    chatImg = getImageViewByImageName(@"myChatBG.png");
    chatImg.userInteractionEnabled = YES;
    chatImg.bottom = theView_.height;
    [theView_ addSubview:chatImg];
    
    textBG = getImageViewByImageName(@"inputText.png");
    textBG.height = 38;
    textBG.centerY = chatImg.height/2;
    textBG.left = 40;
    textBG.userInteractionEnabled = YES;
    [chatImg addSubview:textBG];
    
    chatTextField = [[UIExpandingTextView alloc]initWithFrame:CGRectMake(0, 0, textBG.width, textBG.height)];    
    chatTextField.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(4.0f, 10.0f, 4.0f, 10.0f);
    chatTextField.centerY = textBG.height/2;
    
    chatTextField.backgroundColor = [UIColor clearColor];
    chatTextField.font = [UIFont systemFontOfSize:18];
    chatTextField.text = @"";
    chatTextField.returnKeyType = UIReturnKeySend;
    chatTextField.delegate = self;
    chatTextField.userInteractionEnabled = YES;
    [textBG addSubview:chatTextField];
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(onPasteImg:)];
    longPress.minimumPressDuration = 1.0f;
    [chatTextField addGestureRecognizer:longPress];
    
    btVoice = getButtonByImageName(@"btVoiceOnChat.png");
    btVoice.centerY = chatImg.height/2;
    btVoice.left = 8;
    [btVoice addTarget:self action:@selector(onVoice:) forControlEvents:UIControlEventTouchUpInside];
    [chatImg addSubview:btVoice];
    textBG.left = btVoice.right+5;
    
    btAdd = getButtonByImageName(@"btAddOnChat.png");
    btAdd.centerY = chatImg.height/2;
    btAdd.right = chatImg.width-8;
    [btAdd addTarget:self action:@selector(onAdd) forControlEvents:UIControlEventTouchUpInside];
    [chatImg addSubview:btAdd];
    
    btExpression = getButtonByImageName(@"btExpressionOnChat.png");
    btExpression.centerY = chatImg.height/2;
    btExpression.right = btAdd.left-5;
    [btExpression addTarget:self action:@selector(onExpression) forControlEvents:UIControlEventTouchUpInside];
    [chatImg addSubview:btExpression];
    
    chatTableView = [[UIBubbleTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, theView_.height-chatImg.height)];
    chatTableView.bubbleDataSource = self;
    chatTableView.snapInterval = 120;
    chatTableView.showAvatars = YES;
    chatTableView.typingBubble = NSBubbleTypingTypeSomebody;
    [chatTableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
//    UIPanGestureRecognizer* tap1 = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(onHideKey1:)];
//    [chatTableView addGestureRecognizer:tap1];
    UITapGestureRecognizer* tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onHideKey2:)];
    [chatTableView addGestureRecognizer:tap2];
    [theView_ addSubview:chatTableView];
    
    
    [self resetChatImg];
    
    imgSound = getImageViewByImageName(@"sound1.png");
    imgSound.center = CGPointMake(self.view.width/2, self.view.height/2);
    [self.view addSubview:imgSound];
    imgSound.hidden = YES;
}

- (void)onHideKey1:(UIPanGestureRecognizer*)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        if (isShowChooseView) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.2f];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(onDidStop)];
            theView_.bottom=self.view.height;
            chooseView.top=self.view.height;
            [UIView commitAnimations];
            isShowChooseView = NO;
        }
        if ([chatTextField isFirstResponder]) {
            [chatTextField resignFirstResponder];
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:KEYBOARD_DISMISS_TIME];
            theView_.bottom=self.view.height;
            [UIView commitAnimations];
            
            [self resetChatImg];
        }
    }
}

- (void)onHideKey2:(UITapGestureRecognizer*)gestureRecognizer {
    [chatTextField resignFirstResponder];
    if (theView_.bottom!=self.view.height) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:KEYBOARD_DISMISS_TIME];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(onDidStop)];
        theView_.bottom=self.view.height;
        chooseView.top=self.view.height;
        [UIView commitAnimations];
        
        [self resetChatImg];
        
        [btExpression setBackgroundImage:getBundleImage(@"btExpressionOnChat.png") forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[YXSoundManager sharedManager] playStop];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    allMsgCount = -1;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    if (bFirst) {
        bFirst = NO;
        
        [[WebServiceManager sharedManager] getLastAction:m_nGroupid encodeStr:[[DataManager sharedManager]getUser].encodeStr completion:^(NSDictionary* dic) {
            //[WaitTooles removeHUD];
            int success = [[dic objectForKey:@"success"]intValue];
            if (success == 1) {
                NSDictionary* dic2 = [dic objectForKey:@"obj"];
                if ([dic2 allKeys].count > 0) {
                    
                    NSString* actTime = [dic2 objectForKey:@"update_time"];
                    
                    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                    NSString *str = [def objectForKey:[NSString stringWithFormat:@"%d_%d_actTime",[[DataManager sharedManager]getUser].userid,m_nGroupid]];
                    if (([str isKindOfClass:[NSString class]]&&str.length==0) || str==nil) {
//                        [def setObject:actTime forKey:[NSString stringWithFormat:@"%d_%d_actTime",[[DataManager sharedManager]getUser].userid,m_nGroupid]];
//                        [def synchronize];
                        actView = [[ActiveNoticeView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 30)];
                        actTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(removeActView) userInfo:nil repeats:NO];
                        [self.view addSubview:actView];
                    } else {
                        if ([formatStringToDateEx(actTime) compare:formatStringToDateEx(str)]==NSOrderedDescending) {
//                            [def setObject:actTime forKey:[NSString stringWithFormat:@"%d_%d_actTime",[[DataManager sharedManager]getUser].userid,m_nGroupid]];
//                            [def synchronize];
                            actView = [[ActiveNoticeView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 30)];
                            actTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(removeActView) userInfo:nil repeats:NO];
                            [self.view addSubview:actView];
                        }
                    }
                }
            }
        }];

        oldMsgArray = nil;
        startPoint = 1;
        if (allMsgCount == -1) {
            oldMsgArray = [ChatObject loadChatList:m_nGroupid withPT:startPoint withALL:NO];
            allMsgCount+=ONECHATINPAGE;
        } else {
            oldMsgArray = [ChatObject loadChatList:m_nGroupid withPT:allMsgCount withALL:YES];
            startPoint=allMsgCount/ONECHATINPAGE+1;
        }
        [arrayBubbleData removeAllObjects];
        for (int i=0; i<oldMsgArray.count; i++) {
            ChatObject* one = [oldMsgArray objectAtIndex:i];
            //        if (one.chatid == 0) {
            //            continue ;
            //        }
            NSBubbleType whoChat;
            if (one.userid == [[DataManager sharedManager] getUser].userid) {
                whoChat = BubbleTypeMine;
            } else {
                whoChat = BubbleTypeSomeoneElse;
            }
            UserObject* _user = [UserObject findByID:one.userid];
            NSString* str = nil;
            if (one.userid == [[DataManager sharedManager] getUser].userid) {
                str = @"我";
            } else {
                str = _user.userName;
            }
            
            if (one.type == 1) {
                NSBubbleData *heyBubble = [NSBubbleData dataWithText:one.content withObj:one withName:str date:isLoadSql?formatStringToDateEx(one.strTime):one.chatTime type:whoChat];
                //[arrayBubbleData addObject:heyBubble];
                [arrayBubbleData insertObject:heyBubble atIndex:0];
                if (one.chatStatus == eChatObjectStatus_Sending && one.userid == [[DataManager sharedManager]getUser].userid) {
                    [[WebServiceManager sharedManager] sendText:one.userid groupid:m_nGroupid content:one.content msgTag:[NSString stringWithFormat:@"%d",one.chatKey] completion:^(NSDictionary* dic) {
                        if (dic==nil) {
                            NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:one, @"obj", [NSNumber numberWithInt:2], @"state", nil];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                            one.chatStatus = eChatObjectStatus_Fail;
                            [ChatObject updateOneChatState:one];
                        } else {
                            if ([[dic objectForKey:@"success"]intValue]==1) {
                                NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:one, @"obj", [NSNumber numberWithInt:3], @"state", nil];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                                one.chatStatus = eChatObjectStatus_Success;
                                [ChatObject updateOneChatState:one];
                            } else {
                                NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:one, @"obj", [NSNumber numberWithInt:2], @"state", nil];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                                one.chatStatus = eChatObjectStatus_Fail;
                                [ChatObject updateOneChatState:one];
                                if ([[dic objectForKey:@"returnCode"]intValue]==101) {
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息" message:@"你的账号已经在别处登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                                    [alert show];
                                    [self.navigationController popToRootViewControllerAnimated:YES];
                                }
                            }
                        }
                    }];
                }
            } else if (one.type == 2) {
                NSBubbleData *photoBubble = [NSBubbleData dataWithURLImage:getPicNameALL(one.thumbURL) withObj:one withName:str date:isLoadSql?formatStringToDateEx(one.strTime):one.chatTime type:whoChat];
                //[arrayBubbleData addObject:photoBubble];
                [arrayBubbleData insertObject:photoBubble atIndex:0];                
                if (one.chatStatus == eChatObjectStatus_Sending && one.userid == [[DataManager sharedManager]getUser].userid) {
                    NSData* dataObj = [NSData dataWithContentsOfFile:one.content];
                    [[WebServiceManager sharedManager] sendImg:one.userid groupid:m_nGroupid imgData:dataObj imgtype:@"jpg" msgTag:0 completion:^(NSDictionary* dic) {
                        if (dic==nil) {
                            NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:one, @"obj", [NSNumber numberWithInt:2], @"state", nil];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                            one.chatStatus = eChatObjectStatus_Fail;
                            [ChatObject updateOneChatState:one];
                        } else {
                            if ([[dic objectForKey:@"success"]intValue]==1) {
                                NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:one, @"obj", [NSNumber numberWithInt:3], @"state", nil];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                                one.chatStatus = eChatObjectStatus_Success;
                                [ChatObject updateOneChatState:one];
                            } else {
                                NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:one, @"obj", [NSNumber numberWithInt:2], @"state", nil];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                                one.chatStatus = eChatObjectStatus_Fail;
                                [ChatObject updateOneChatState:one];
                                if ([[dic objectForKey:@"returnCode"]intValue]==101) {
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息" message:@"你的账号已经在别处登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                                    [alert show];
                                    [self.navigationController popToRootViewControllerAnimated:YES];
                                }
                            }
                        }
                    }];
                }
            } else if (one.type == 3) {
                NSBubbleData *voiceBubble = [NSBubbleData dataWithVoice:getPicNameALL(one.content) withObj:one withName:str date:isLoadSql?formatStringToDateEx(one.strTime):one.chatTime type:whoChat];
                //[arrayBubbleData addObject:voiceBubble];
                [arrayBubbleData insertObject:voiceBubble atIndex:0];
                if (one.chatStatus == eChatObjectStatus_Sending && one.userid == [[DataManager sharedManager]getUser].userid) {
                    NSData * reader = [NSData dataWithContentsOfFile:one.content];
                    [[WebServiceManager sharedManager] sendVoice:one.userid groupid:m_nGroupid voiceData:reader msgTag:[NSString stringWithFormat:@"%d",one.chatKey] completion:^(NSDictionary* dic) {
                        if (dic==nil) {
                            NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:one, @"obj", [NSNumber numberWithInt:2], @"state", nil];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                            one.chatStatus = eChatObjectStatus_Fail;
                            [ChatObject updateOneChatState:one];
                        } else {
                            if ([[dic objectForKey:@"success"]intValue]==1) {
                                NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:one, @"obj", [NSNumber numberWithInt:3], @"state", nil];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                                one.chatStatus = eChatObjectStatus_Success;
                                [ChatObject updateOneChatState:one];
                            } else {
                                NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:one, @"obj", [NSNumber numberWithInt:2], @"state", nil];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                                one.chatStatus = eChatObjectStatus_Fail;
                                [ChatObject updateOneChatState:one];
                                if ([[dic objectForKey:@"returnCode"]intValue]==101) {
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息" message:@"你的账号已经在别处登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                                    [alert show];
                                    [self.navigationController popToRootViewControllerAnimated:YES];
                                }
                            }
                        }
                    }];
                }
            }
        }
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [self getGroupMember];
    [super viewDidAppear:animated];
}

- (void)removeTimer:(NSNotification*)sender {
    [self removeActView];
}

- (void)removeActView {
    if (actView) {
        [actView removeFromSuperview];
        actView = nil;
    }
    if (actTimer) {
        [actTimer invalidate];
        actTimer = nil;
    }
}

#pragma mark 刷新组的成员
- (void)getGroupMember {
    if (hasRefresh) {
        return;
    }
    hasRefresh = YES;
    [[WebServiceManager sharedManager] getGroupMember:m_nGroupid encodeStr:[[DataManager sharedManager]getUser].encodeStr completion:^(NSDictionary* dic) {
        if ([[dic objectForKey:@"success"]intValue]==1) {
            NSArray* array = [dic objectForKey:@"obj"];
            if ([array isKindOfClass:[NSArray class]]) {
                for (int i=0; i<array.count; i++) {
                    NSDictionary* dic = [array objectAtIndex:i];
                    UserObject* one = [UserObject getUserObj:dic];
                    
                    if ([GroupObject findMemberByGroupAndUserid:m_nGroupid withUserid:one.userid]==nil) {
                        [GroupObject addOneMember:one withGroupid:m_nGroupid];
                    } else {
                        [GroupObject updateOneMember:one withGroupid:m_nGroupid];
                    }
                    
                    if ([UserObject findByID:one.userid]==nil) {
                        [UserObject addName:one];
                    } else {
                        [UserObject updataName:one];
                    }
                }
            }
            [chatTableView reloadData];
        }        
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];    
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"keyboardWasShown" object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"keyboardWillBeHidden" object:nil];    
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)goLook {
    GroupSettingViewController* v = [[GroupSettingViewController alloc]initWithGroupid:m_nGroupid];
    [self.navigationController pushViewController:v animated:YES];
}

#pragma mark 点击声音按钮
- (void)onVoice:(id)sender {
    if (isShowFaceView) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(onDidStop)];
        theView_.bottom=self.view.height;
        faceView.top=self.view.height;
        [UIView commitAnimations];
        isShowFaceView = NO;
    }
    if (isShowChooseView) {        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(onDidStop)];
        theView_.bottom=self.view.height;
        chooseView.top=self.view.height;
        [UIView commitAnimations];
        isShowChooseView = NO;
    }
    if ([chatTextField.internalTextView isFirstResponder]) {
        [chatTextField resignFirstResponder];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:KEYBOARD_DISMISS_TIME];
        theView_.bottom=self.view.height;
        [UIView commitAnimations];
        chatTextField.text = @"";
        
        [self resetChatImg];
    }
    [btExpression setBackgroundImage:getBundleImage(@"btExpressionOnChat.png") forState:UIControlStateNormal];
    UIButton* b = (UIButton*)sender;
    if (!isVoice) {
        [b setBackgroundImage:getBundleImage(@"keyboard.png") forState:UIControlStateNormal];
        btKeepTalk = getButtonByImageName(@"keepTalk.png");
        btKeepTalk.centerY = chatImg.height/2;
        btKeepTalk.left = textBG.left;
        [btKeepTalk addTarget:self action:@selector(btnLong:) forControlEvents:UIControlEventTouchDown];
        [btKeepTalk addTarget:self action:@selector(btnStop:) forControlEvents:UIControlEventTouchUpInside];
        [btKeepTalk addTarget:self action:@selector(btnCancel:) forControlEvents:UIControlEventTouchUpOutside];
        [btKeepTalk addTarget:self action:@selector(btnDragOut:) forControlEvents:UIControlEventTouchDragOutside];
        [chatImg addSubview:btKeepTalk];
        textBG.hidden = YES;
        
    } else {
        [b setBackgroundImage:getBundleImage(@"btVoiceOnChat.png") forState:UIControlStateNormal];
        if (btKeepTalk) {
            [btKeepTalk removeFromSuperview];
            btKeepTalk = nil;
        }
        textBG.hidden = NO;
    }
    isVoice = !isVoice;
}

- (void)btnLong:(id)sender {
    UIButton* b = (UIButton*)sender;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pauseAudio" object:nil];
    [b setBackgroundImage:getBundleImage(@"stopTalk.png") forState:UIControlStateNormal];
    [[YXSoundManager sharedManager] recordStart];
    [YXSoundManager sharedManager].delegate = self;
    timer = [NSTimer scheduledTimerWithTimeInterval: 0.5// 当函数正在调用时，及时间隔时间到了 也会忽略此次调用
                                             target: self
                                           selector: @selector(handleTimer:)
                                           userInfo: nil
                                            repeats: YES]; // 如果是NO 不重复，则timer在触发了回调函数调用完成之后 会自动释放这个timer，以免timer被再一次的调用，如果是YES，则会重复调用函数，调用完函数之后，会将这个timer加到RunLoop中去，等待下一次的调用，知道用户手动释放timer( [timer invalidate];)。
}

- (void)btnStop:(id)sender {
    UIButton* b = (UIButton*)sender;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"continueAudio" object:nil];
    [b setBackgroundImage:getBundleImage(@"keepTalk.png") forState:UIControlStateNormal];
    [[YXSoundManager sharedManager] recordStop];
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    imgSound.hidden = YES;
}

- (void)btnCancel:(id)sender {
    UIButton* b = (UIButton*)sender;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"continueAudio" object:nil];
    if (!imgSound.isHidden) {
        imgSound.hidden = YES;
        [b setBackgroundImage:getBundleImage(@"keepTalk.png") forState:UIControlStateNormal];        
    }
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    if (btKeepTalk) {
        [btKeepTalk removeFromSuperview];
        btKeepTalk = nil;
        [btVoice setBackgroundImage:getBundleImage(@"btVoiceOnChat.png") forState:UIControlStateNormal];
    }
    isVoice = NO;
    textBG.hidden = NO;
}

- (void)btnDragOut:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"continueAudio" object:nil];
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    imgSound.image = getBundleImage(@"soundcancel.png");
}

- (void)handleTimer:(NSTimer *) _timer  {    
    imgSound.hidden = NO;
    int level = [[YXSoundManager sharedManager]getSoundLevel];
    imgSound.image = getBundleImage([NSString stringWithFormat:@"sound%d.png",level+1]);
}

#pragma mark YXSoundManager的代理
#pragma mark 发送声音
- (void)soudnManagerRecordFinish:(NSString *)soundDataPath {
    float len = [[YXSoundManager sharedManager] getVoiceLength:soundDataPath];
    if (len < 1) {        
        return ;
    }
    
    
    UserObject *user = [[DataManager sharedManager] getUser];

    ChatObject *oneChat = [[ChatObject alloc] init];
    oneChat.userid = user.userid;
    oneChat.groupid = m_nGroupid;
    oneChat.chatStatus = eChatObjectStatus_Sending;
    oneChat.type = eMessageType_Voice;
    NSString *filepath = [[Global sharedInstance] saveChatSound:soundDataPath];
    oneChat.content = filepath;
    int tag = [ChatObject addOneChat:oneChat];
    oneChat.chatKey = tag;
    
    MsgObject *one = [[MsgObject alloc]init];
    one.subGroupid = m_nGroupid;
    GroupObject* g = [GroupObject findByGroupid:m_nGroupid];
    one.subGroupName = g.groupName;
    one.subGroupHead = g.groupHead;
    one.numOfMember = g.memberCount;
    one.lastName = [[DataManager sharedManager]getUser].userName;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    one.lastTime = [dateFormat stringFromDate:[NSDate date]];
    one.lastContent = @"语音";
    [self updateLastList:one];
    
    chatTableView.typingBubble = NSBubbleTypingTypeNobody;
    NSBubbleData *voiceBubble = [NSBubbleData dataWithVoice:getPicNameALL(oneChat.content) withObj:oneChat withName:[[DataManager sharedManager]getUser].userName date:oneChat.chatTime type:BubbleTypeMine];
    [arrayBubbleData addObject:voiceBubble];
    
    [self performSelector:@selector(reloadData) withObject:nil afterDelay:0.0];
    
    NSData * reader = [NSData dataWithContentsOfFile:soundDataPath];
    [[WebServiceManager sharedManager] sendVoice:user.userid groupid:m_nGroupid voiceData:reader msgTag:[NSString stringWithFormat:@"%d",tag] completion:^(NSDictionary* dic) {
        if (dic==nil) {
            NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:oneChat, @"obj", [NSNumber numberWithInt:2], @"state", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
            oneChat.chatStatus = eChatObjectStatus_Fail;
            [ChatObject updateOneChatState:oneChat];
        } else {
            if ([[dic objectForKey:@"success"]intValue]==1) {
                NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:oneChat, @"obj", [NSNumber numberWithInt:3], @"state", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                oneChat.chatStatus = eChatObjectStatus_Success;
                [ChatObject updateOneChatState:oneChat];
            } else {
                NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:oneChat, @"obj", [NSNumber numberWithInt:2], @"state", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                oneChat.chatStatus = eChatObjectStatus_Fail;
                [ChatObject updateOneChatState:oneChat];
                if ([[dic objectForKey:@"returnCode"]intValue]==101) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息" message:@"你的账号已经在别处登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alert show];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }
        }
    }];
}

- (void)soudnManagerPlayFinish {
    
}

- (void)soudnManagerError:(NSError *)error {
    
}

#pragma mark - UIBubbleTableViewDataSource implementation
- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView {
    return arrayBubbleData.count;
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row {
    //NSBubbleData *d = [arrayBubbleData objectAtIndex:row];
    return [arrayBubbleData objectAtIndex:row];
}

- (void)onAdd {
    if (!isShowChooseView) {
        [chatTextField resignFirstResponder];
        [self onDidStop];
        [btExpression setBackgroundImage:getBundleImage(@"btExpressionOnChat.png") forState:UIControlStateNormal];
        chooseView = [[ChatChooseView alloc]initWithFrame:CGRectMake(0, 0, self.view.height, 205)];
        chooseView.top = self.view.height;
        [self.view addSubview:chooseView];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:KEYBOARD_DISMISS_TIME];
        chooseView.bottom = self.view.height;
        theView_.bottom=chooseView.top;
        [UIView commitAnimations];
    } else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(onDidStop)];
        theView_.bottom=self.view.height;
        chooseView.top=self.view.height;
        [UIView commitAnimations];
    }
    isShowChooseView = !isShowChooseView;
}

- (void)onDidStop {    
    if (chooseView) {
        [chooseView removeFromSuperview];
        chooseView = nil;
    }
    if (faceView) {
        [faceView removeFromSuperview];
        faceView = nil;
    }
    isShowChooseView = NO;
    isShowFaceView = NO;
}

#pragma mark 点击表情按钮
- (void)onExpression {
    if (!isShowFaceView) {
        if (isVoice) {
            isVoice = NO;            
            [btVoice setBackgroundImage:getBundleImage(@"btVoiceOnChat.png") forState:UIControlStateNormal];
            if (btKeepTalk) {
                [btKeepTalk removeFromSuperview];
                btKeepTalk = nil;
            }
            textBG.hidden = NO;
        }
        [chatTextField resignFirstResponder];
        [btExpression setBackgroundImage:getBundleImage(@"keyboard.png") forState:UIControlStateNormal];
        [self onDidStop];
        faceView = [[FaceBoard alloc]initWithFrame:CGRectMake(0, 0, 320, 216)];
        faceView.top = self.view.height;
        [self.view addSubview:faceView];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:KEYBOARD_DISMISS_TIME];
        faceView.bottom = self.view.height;
        theView_.bottom=faceView.top;
        [UIView commitAnimations];
        isShowFaceView = YES;
    } else {
        [chatTextField.internalTextView becomeFirstResponder];
        [btExpression setBackgroundImage:getBundleImage(@"btExpressionOnChat.png") forState:UIControlStateNormal];
//        [UIView beginAnimations:nil context:nil];
//        [UIView setAnimationDuration:0.2f];
//        [UIView setAnimationDelegate:self];
//        [UIView setAnimationDidStopSelector:@selector(onDidStop)];
//        theView_.bottom=self.view.height;
//        faceView.top=self.view.height;
//        [UIView commitAnimations];
        [self onDidStop];
        isShowFaceView = NO;
    }
    isShowChooseView = NO;
}

- (void)onRecvEmjoy:(NSNotification*)sender {
    NSString* str = (NSString*)sender.object;
    chatTextField.text = [chatTextField.text stringByAppendingString:str];
}

- (void)onRecvDeleteEmjoy:(NSNotification*)sender {
    NSString *string = nil;
    NSInteger stringLength = chatTextField.text.length;
    if (stringLength > 0) {
        if ([@"]" isEqualToString:[chatTextField.text substringFromIndex:stringLength-1]]) {
            if ([chatTextField.text rangeOfString:@"["].location == NSNotFound){
                string = [chatTextField.text substringToIndex:stringLength - 1];
            } else {
                string = [chatTextField.text substringToIndex:[chatTextField.text rangeOfString:@"[" options:NSBackwardsSearch].location];
            }
        } else {
            string = [chatTextField.text substringToIndex:stringLength - 1];
        }
    }
    chatTextField.text = string;
}

- (void)sendChatMsg:(NSNotification*)sender {
    
    [btExpression setBackgroundImage:getBundleImage(@"btExpressionOnChat.png") forState:UIControlStateNormal];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(onDidStop)];
    theView_.bottom=self.view.height;
    faceView.top=self.view.height;
    [UIView commitAnimations];
    isShowFaceView = NO;
    
    if (chatTextField.text.length==0) {
        return ;
    }
    
    [self sendTextOnChat];
}

#pragma mark 进入查看详细照片的页面
- (void)gotoPicView:(NSNotification*)sender {
    ChatObject* obj = (ChatObject*)sender.object;
    NSArray* array = [ChatObject findByGroupid:obj.groupid withType:1];
    int index = 0;
    for (int i=0; i<array.count; i++) {
        ChatObject* one = [array objectAtIndex:i];
        if ([one.content isEqualToString:obj.content] && [one.thumbURL isEqualToString:obj.thumbURL] && one.chatid == obj.chatid && one.chatKey == obj.chatKey) {
            index = i;
            break;
        }
    }
    PictureViewController* v = [[PictureViewController alloc]initWithObj:array whitIndex:index];
    [self.navigationController pushViewController:v animated:YES];
}

- (void)keyboardWasShown:(NSNotification*)sender {
    NSDictionary* info = [sender userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2f];
    theView_.bottom=self.view.height-kbSize.height;
    [UIView commitAnimations];
}

- (void)keyboardWillBeHidden:(NSNotification*)sender {
    //NSDictionary* info = [sender userInfo];
    //CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2f];
    theView_.bottom=self.view.height;
    [UIView commitAnimations];
}

- (void)keyboardWillChange:(NSNotification*)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED>= __IPHONE_3_2
        NSValue *keyboardBoundsValue = [[sender userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
#else
        NSValue *keyboardBoundsValue = [[sender userInfo] objectForKey:UIKeyboardBoundsUserInfoKey];
#endif
        CGRect keyboardBounds;
        [keyboardBoundsValue getValue:&keyboardBounds];
        //NSInteger offset = self.view.size.height-keyboardBounds.origin.y;
        if (theView_.bottom != (self.view.height-keyboardBounds.size.height)
            && [chatTextField.internalTextView isFirstResponder]) {
            [UIView beginAnimations:@"anim" context:NULL];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:0.2f];
            //处理移动事件，将各视图设置最终要达到的状态
            theView_.bottom = self.view.height-keyboardBounds.size.height;
            [UIView commitAnimations];
        }
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (chooseView) {
        [chooseView removeFromSuperview];
        chooseView = nil;
        isShowChooseView = NO;
    }
    if (faceView) {
        [faceView removeFromSuperview];
        faceView = nil;
        isShowFaceView = NO;
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2f];
    theView_.bottom=self.view.height-216;
    [UIView commitAnimations];
    return YES;
}

#pragma mark -
#pragma mark UIExpandingTextView delegate

- (void)expandingTextViewDidBeginEditing:(UIExpandingTextView *)expandingTextView{
    if (chooseView) {
        [chooseView removeFromSuperview];
        chooseView = nil;
        isShowChooseView = NO;
    }
    if (faceView) {
        [faceView removeFromSuperview];
        faceView = nil;
        isShowFaceView = NO;
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2f];
    theView_.bottom=self.view.height-216;
    [UIView commitAnimations];
}

- (void)expandingTextViewDidEndEditing:(UIExpandingTextView *)expandingTextView{
    [chatTextField resignFirstResponder];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:KEYBOARD_DISMISS_TIME];
    theView_.bottom=self.view.height;
    [UIView commitAnimations];
}

-(void)expandingTextView:(UIExpandingTextView *)expandingTextView willChangeHeight:(float)height {
    /* Adjust the height of the toolbar when the input component expands */
    //float diff = (expandingTextView.frame.size.height - height);

    if (height+4<chatImg.image.size.height) {
        chatImg.frame = CGRectMake(0, 0, chatImg.width, chatImg.image.size.height);
    }else{
        chatImg.frame = CGRectMake(0, 0, chatImg.width, height+4);
    }
    
    textBG.frame = CGRectMake(textBG.left, textBG.top, textBG.width, height);
    textBG.centerY = chatImg.height/2;
    textBG.image = [textBG.image resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
    chatImg.bottom = theView_.height;
    chatTableView.bottom = chatImg.top;
}

- (BOOL)expandingTextViewShouldBeginEditing:(UIExpandingTextView *)expandingTextView {
    if (chooseView) {
        [chooseView removeFromSuperview];
        chooseView = nil;
        isShowChooseView = NO;
    }
    if (faceView) {
        [faceView removeFromSuperview];
        faceView = nil;
        isShowFaceView = NO;
    }
    [btExpression setBackgroundImage:getBundleImage(@"btExpressionOnChat.png") forState:UIControlStateNormal];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.1f];
    theView_.bottom=self.view.height-216;
    [UIView commitAnimations];
    return YES;
}

- (void)resetChatImg{
    chatImg.height = 50;
    textBG.height = 38;
    chatTextField.height = textBG.height;
    chatTextField.centerY = textBG.height/2;
    chatImg.bottom = theView_.height;
    
    btVoice.centerY = chatImg.height/2;
    btAdd.centerY = chatImg.height/2;
    btExpression.centerY = chatImg.height/2;

}

- (BOOL)expandingTextViewShouldReturn:(UIExpandingTextView *)expandingTextView {
    [btExpression setBackgroundImage:getBundleImage(@"btExpressionOnChat.png") forState:UIControlStateNormal];
    
    [chatTextField resignFirstResponder];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:KEYBOARD_DISMISS_TIME];
    theView_.bottom=self.view.height;
    [UIView commitAnimations];
    
    [self resetChatImg];
    
    if (chatTextField.text.length==0) {
        return YES;    
    }
    
    [self sendTextOnChat];
    
    return YES;
}

#pragma mark uitextView的代理
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (chooseView) {
        [chooseView removeFromSuperview];
        chooseView = nil;
        isShowChooseView = NO;
    }
    if (faceView) {
        [faceView removeFromSuperview];
        faceView = nil;
        isShowFaceView = NO;
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2f];
    theView_.bottom=self.view.height-216;
    [UIView commitAnimations];
    return YES;
}

- (BOOL)textView: (UITextView *)textview shouldChangeTextInRange: (NSRange)range replacementText: (NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        if (textview.text.length==0) {
            [chatTextField resignFirstResponder];
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:KEYBOARD_DISMISS_TIME];
            theView_.bottom=self.view.height;
            [UIView commitAnimations];
            return YES;
        }
        
        [chatTextField resignFirstResponder];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:KEYBOARD_DISMISS_TIME];
        theView_.bottom=self.view.height;
        [UIView commitAnimations];
        
        [self resetChatImg];
        
        [self sendTextOnChat];
        
        return YES;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    [textView flashScrollIndicators];   // 闪动滚动条
    
    static CGFloat maxHeight = 100.0f;
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(frame.size.width, MAXFLOAT);
    CGSize size = [textView sizeThatFits:constraintSize];
    //CGSize size = [textView.text sizeWithFont:textView.font constrainedToSize:CGSizeMake(frame.size.width, MAXFLOAT)];
//    if (size.height > textView.height) {
//        size.height = textView.height;
//    }
    if (size.height == 0) {
        return ;
    }

    if (size.height >= maxHeight) {
        size.height = maxHeight;
        textView.scrollEnabled = YES;   // 允许滚动
    } else {
        textView.scrollEnabled = NO;    // 不允许滚动，当textview的大小足以容纳它的text的时候，需要设置scrollEnabed为NO，否则会出现光标乱滚动的情况
    }
    textView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, size.height);
    textBG.frame = CGRectMake(textBG.origin.x, textBG.origin.y, textBG.size.width, size.height);
    textBG.image = [textBG.image resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
    chatImg.frame = CGRectMake(chatImg.origin.x, chatImg.origin.y, chatImg.size.width, size.height+10);
    chatImg.bottom = theView_.height;
    chatTableView.bottom = chatImg.top;
}


#pragma mark 发送文字消息
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length==0) {
        [chatTextField resignFirstResponder];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:KEYBOARD_DISMISS_TIME];
        theView_.bottom=self.view.height;
        [UIView commitAnimations];
        return YES;
    }
    
    [chatTextField resignFirstResponder];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:KEYBOARD_DISMISS_TIME];
    theView_.bottom=self.view.height;
    [UIView commitAnimations];
    
    [self sendTextOnChat];
    
    return YES;
}

- (void)lookUser:(NSNotification*)sender {
    int theUserid = [(NSNumber*)sender.object intValue];
    UserDetailViewController* v = [[UserDetailViewController alloc]initWithUserid:theUserid];
    [self.navigationController pushViewController:v animated:YES];
}

- (void)onChoosePic:(NSNotification*)sender {
//    [self addPicEvent];
//    return ;
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if (![UIImagePickerController isSourceTypeAvailable: sourceType]) {
        sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    //UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    //CameraViewController *picker = [[CameraViewController alloc] init];
    MyPicViewController *picker = [[MyPicViewController alloc] init];
    picker.MyPicViewDelete=self;
    picker.allowsEditing = NO;
    picker.sourceType = sourceType;
    [self.navigationController presentViewController:picker animated:YES completion:nil];
}

- (void)finishPicture:(MyPicViewController *)picker
                array:(NSArray*)imgArray {
    [self publishImg:imgArray];
}

- (void)onCamera:(NSNotification*)sender {
    [self addCameraEvent];
}

#pragma mark 摄像头的操作
-(void)cancelFoo{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)cameraTake:(CameraViewController *)picker
             image:(UIImage *)takeImage{
    if (takeImage==nil) {
        [self cancelFoo];
        return;
    }
    photo_ = takeImage;
    [self sendImage];
}

#pragma mark 照片库的操作
-(void)addPicEvent {
    UIImagePickerControllerSourceType sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    UIImagePickerController * picker = [[UIImagePickerController alloc]init];
    picker.delegate=self;
    picker.allowsEditing=YES;
    picker.sourceType=sourceType;
    [self.navigationController presentViewController:picker animated:YES completion:nil];
}

#pragma mark 摄像头的操作
-(void)addCameraEvent {
    UIImagePickerControllerSourceType sourceType=UIImagePickerControllerSourceTypeCamera;
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    }
    UIImagePickerController * picker = [[UIImagePickerController alloc]init];
    picker.delegate=self;
    picker.allowsEditing=NO;
    picker.sourceType=sourceType;
    [self.navigationController presentViewController:picker animated:YES completion:nil];
}

-(void)saveImage:(UIImage*)image {
    photo_ = image;
    [self sendImage];
}

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage * image=[info objectForKey:UIImagePickerControllerOriginalImage];
    [self performSelector:@selector(saveImage:) withObject:image afterDelay:0.5];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 发送图片消息
-(void)sendImage {
    
    UserObject *obj = [[DataManager sharedManager] getUser];
    
    ChatObject *cObject = [[ChatObject alloc] init];
    cObject.content = chatTextField.text;
    cObject.userid = obj.userid;
    cObject.groupid = m_nGroupid;
    cObject.type = eMessageType_Image;    
    cObject.chatStatus = eChatObjectStatus_Sending;
    NSString *filepath = [[Global sharedInstance] saveChatPicture:photo_];
    cObject.content = filepath;
    filepath = [[Global sharedInstance] saveChatPictureThumb:photo_];
    cObject.thumbURL = filepath;
    
    int tag = [ChatObject addOneChat:cObject];
    cObject.chatKey = tag;
    
    MsgObject *one = [[MsgObject alloc]init];
    one.subGroupid = m_nGroupid;
    GroupObject* g = [GroupObject findByGroupid:m_nGroupid];
    one.subGroupName = g.groupName;
    one.subGroupHead = g.groupHead;
    one.numOfMember = g.memberCount;
    one.lastName = [[DataManager sharedManager]getUser].userName;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    one.lastTime = [dateFormat stringFromDate:[NSDate date]];
    one.lastContent = @"图片";
    [self updateLastList:one];
    
    chatTableView.typingBubble = NSBubbleTypingTypeNobody;
    NSBubbleData *photoBubble = [NSBubbleData dataWithURLImage:getPicNameALL(cObject.thumbURL) withObj:cObject withName:@"我" date:cObject.chatTime type:BubbleTypeMine];
    [arrayBubbleData addObject:photoBubble];
    [self performSelector:@selector(reloadData) withObject:nil afterDelay:0.0];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(onDidStop)];
    theView_.bottom=self.view.height;
    chooseView.top=self.view.height;
    [UIView commitAnimations];
    isShowChooseView = NO;
    NSData *dataObj = UIImageJPEGRepresentation(photo_, 0.7);
    [[WebServiceManager sharedManager] sendImg:obj.userid groupid:m_nGroupid imgData:dataObj imgtype:@"jpg" msgTag:0  completion:^(NSDictionary* dic) {
        if (dic==nil) {
            NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:cObject, @"obj", [NSNumber numberWithInt:2], @"state", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
            cObject.chatStatus = eChatObjectStatus_Fail;
            [ChatObject updateOneChatState:cObject];
        } else {            
            if ([[dic objectForKey:@"success"]intValue]==1) {
                NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:cObject, @"obj", [NSNumber numberWithInt:3], @"state", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                cObject.chatStatus = eChatObjectStatus_Success;
                [ChatObject updateOneChatState:cObject];
            } else {
                NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:cObject, @"obj", [NSNumber numberWithInt:2], @"state", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                cObject.chatStatus = eChatObjectStatus_Fail;
                [ChatObject updateOneChatState:cObject];
                if ([[dic objectForKey:@"returnCode"]intValue]==101) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息" message:@"你的账号已经在别处登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alert show];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }
        }
    }];
}

- (void)updateLastList:(MsgObject*)one  {
    if ([MsgObject findByID:one.subGroupid]!=nil) {
        [MsgObject updateByID:one];
    } else {
        [MsgObject addOneLast:one];
    }
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"updateLastList" object:one];
}

- (BOOL)bubbleHasExist:(int)chatid{
    for (NSBubbleData *d in arrayBubbleData) {
        if(d.chatObj.chatid==chatid){
            return YES;
        }
    }
    
    return NO;
}

#pragma mark 接受消息推送
- (void)onRecvMsgOnChat:(NSNotification*)sender {
    NSDictionary* dic = (NSDictionary*)sender.object;
    int groupid = [[dic objectForKey:@"groupid"] intValue];
    NSArray* array = [dic objectForKey:@"array"];
    //ChatObject* chat = [dic objectForKey:@"chat"];
    if (groupid == m_nGroupid) {
        for (int i=0; i<array.count; i++) {
            ChatObject* chat = [array objectAtIndex:i];
            UserObject* _user = [UserObject findByID:chat.userid];
            NSString* str = _user.userName;
            
            if ( [[DataManager sharedManager] getUser].userid==chat.userid) {
                continue;
            }
            
            if ([self bubbleHasExist:chat.chatid]) {
                continue;
            }
            
            if (chat.type == eMessageType_Text) {
                NSBubbleData *heyBubble = [NSBubbleData dataWithText:chat.content withObj:chat withName:str date:chat.chatTime type:BubbleTypeSomeoneElse];
                [arrayBubbleData addObject:heyBubble];
            } else if (chat.type == eMessageType_Image) {
                NSBubbleData *photoBubble = [NSBubbleData dataWithURLImage:getPicNameALL(chat.thumbURL) withObj:chat withName:str date:chat.chatTime type:BubbleTypeSomeoneElse];
                [arrayBubbleData addObject:photoBubble];
            } else if (chat.type == eMessageType_Voice) {
                NSBubbleData *voiceBubble = [NSBubbleData dataWithVoice:getPicNameALL(chat.content) withObj:chat withName:str date:chat.chatTime type:BubbleTypeSomeoneElse];
                [arrayBubbleData addObject:voiceBubble];
            }
        }
        
        [self performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
        
        int all = [[DataManager sharedManager] getMsgCount];
        int count = [MsgObject findCountByID:m_nGroupid];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateNewMsg" object:[NSNumber numberWithInt:all-count]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"onChangeNum" object:[NSNumber numberWithInt:all-count]];
        [MsgObject updateCount:m_nGroupid withNewCount:0];
    }
}

- (void)onLoadMore:(NSNotification*)sender {
    startPoint++;
    oldMsgArray = [ChatObject loadChatList:m_nGroupid withPT:startPoint withALL:NO];
    if (oldMsgArray.count > 0) {
        [WaitTooles showHUD:@"正在加载上一页"];
        allMsgCount+=ONECHATINPAGE;
        for (int i=0; i<oldMsgArray.count; i++) {
            ChatObject* one = [oldMsgArray objectAtIndex:i];
//            if (one.chatid == 0) {
//                continue ;
//            }
            NSBubbleType whoChat;
            if (one.userid == [[DataManager sharedManager] getUser].userid) {
                whoChat = BubbleTypeMine;
            } else {
                whoChat = BubbleTypeSomeoneElse;
            }
            UserObject* _user = [UserObject findByID:one.userid];
            NSString* str = nil;
//            if (one.userid == [[DataManager sharedManager] getUser].userid) {
//                str = @"我";
//            } else {
                str = _user.userName;
//            }
            if (one.type == 1) {
                NSBubbleData *heyBubble = [NSBubbleData dataWithText:one.content withObj:one withName:str date:isLoadSql?formatStringToDateEx(one.strTime):one.chatTime type:whoChat];
                [arrayBubbleData insertObject:heyBubble atIndex:0];
                if (one.chatStatus == eChatObjectStatus_Sending && one.userid == [[DataManager sharedManager]getUser].userid) {
                    [[WebServiceManager sharedManager] sendText:one.userid groupid:m_nGroupid content:one.content msgTag:[NSString stringWithFormat:@"%d",one.chatKey] completion:^(NSDictionary* dic) {
                        if (dic==nil) {
                            NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:one, @"obj", [NSNumber numberWithInt:2], @"state", nil];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                            one.chatStatus = eChatObjectStatus_Fail;
                            [ChatObject updateOneChatState:one];
                        } else {
                            if ([[dic objectForKey:@"success"]intValue]==1) {
                                NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:one, @"obj", [NSNumber numberWithInt:3], @"state", nil];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                                one.chatStatus = eChatObjectStatus_Success;
                                [ChatObject updateOneChatState:one];
                            } else {
                                NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:one, @"obj", [NSNumber numberWithInt:2], @"state", nil];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                                one.chatStatus = eChatObjectStatus_Fail;
                                [ChatObject updateOneChatState:one];
                                if ([[dic objectForKey:@"returnCode"]intValue]==101) {
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息" message:@"你的账号已经在别处登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                                    [alert show];
                                    [self.navigationController popToRootViewControllerAnimated:YES];
                                }
                            }
                        }
                    }];
                }
            } else if (one.type == 2) {
                NSBubbleData *photoBubble = [NSBubbleData dataWithURLImage:getPicNameALL(one.thumbURL) withObj:one withName:str date:isLoadSql?formatStringToDateEx(one.strTime):one.chatTime type:whoChat];
                [arrayBubbleData insertObject:photoBubble atIndex:0];
                if (one.chatStatus == eChatObjectStatus_Sending && one.userid == [[DataManager sharedManager]getUser].userid) {
                    NSData* dataObj = [NSData dataWithContentsOfFile:one.content];
                    [[WebServiceManager sharedManager] sendImg:one.userid groupid:m_nGroupid imgData:dataObj imgtype:@"jpg" msgTag:0 completion:^(NSDictionary* dic) {
                        if (dic==nil) {
                            NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:one, @"obj", [NSNumber numberWithInt:2], @"state", nil];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                            one.chatStatus = eChatObjectStatus_Fail;
                            [ChatObject updateOneChatState:one];
                        } else {
                            if ([[dic objectForKey:@"success"]intValue]==1) {
                                NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:one, @"obj", [NSNumber numberWithInt:3], @"state", nil];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                                one.chatStatus = eChatObjectStatus_Success;
                                [ChatObject updateOneChatState:one];
                            } else {
                                NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:one, @"obj", [NSNumber numberWithInt:2], @"state", nil];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                                one.chatStatus = eChatObjectStatus_Fail;
                                [ChatObject updateOneChatState:one];
                                if ([[dic objectForKey:@"returnCode"]intValue]==101) {
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息" message:@"你的账号已经在别处登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                                    [alert show];
                                    [self.navigationController popToRootViewControllerAnimated:YES];
                                }
                            }
                        }
                    }];
                }
            } else if (one.type == 3) {
                NSBubbleData *voiceBubble = [NSBubbleData dataWithVoice:getPicNameALL(one.content) withObj:one withName:str date:isLoadSql?formatStringToDateEx(one.strTime):one.chatTime type:whoChat];
                [arrayBubbleData insertObject:voiceBubble atIndex:0];
                if (one.chatStatus == eChatObjectStatus_Sending && one.userid == [[DataManager sharedManager]getUser].userid) {
                    NSData * reader = [NSData dataWithContentsOfFile:one.content];
                    [[WebServiceManager sharedManager] sendVoice:one.userid groupid:m_nGroupid voiceData:reader msgTag:[NSString stringWithFormat:@"%d",one.chatKey] completion:^(NSDictionary* dic) {
                        if (dic==nil) {
                            NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:one, @"obj", [NSNumber numberWithInt:2], @"state", nil];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                            one.chatStatus = eChatObjectStatus_Fail;
                            [ChatObject updateOneChatState:one];
                        } else {
                            if ([[dic objectForKey:@"success"]intValue]==1) {
                                NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:one, @"obj", [NSNumber numberWithInt:3], @"state", nil];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                                one.chatStatus = eChatObjectStatus_Success;
                                [ChatObject updateOneChatState:one];
                            } else {
                                NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:one, @"obj", [NSNumber numberWithInt:2], @"state", nil];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                                one.chatStatus = eChatObjectStatus_Fail;
                                [ChatObject updateOneChatState:one];
                                if ([[dic objectForKey:@"returnCode"]intValue]==101) {
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息" message:@"你的账号已经在别处登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                                    [alert show];
                                    [self.navigationController popToRootViewControllerAnimated:YES];
                                }
                            }
                        }
                    }];
                }
            }
        }
        [chatTableView reloadData];
        [WaitTooles removeHUD];
    } else {
        startPoint--;
    }
    //chatTableView.m_bIsLoadFinish = YES;
}

- (ChatObject *)findChatObjectByID:(int)ID{
    for (NSBubbleData *obj in arrayBubbleData) {
        if (obj.chatObj.chatid == ID && obj.chatObj.chatid>=0) {
            return obj.chatObj;
        }
    }
    return nil;
}

#pragma mark 发送文字的函数
- (void)sendTextOnChat {
    
    UserObject *user = [[DataManager sharedManager] getUser];
    
    ChatObject *cObject = [[ChatObject alloc] init];
    cObject.content = chatTextField.text;
    cObject.userid = user.userid;
    cObject.groupid = m_nGroupid;
    cObject.type = eMessageType_Text;
    cObject.chatStatus = eChatObjectStatus_Sending;
    int tag = [ChatObject addOneChat:cObject];
    cObject.chatKey = tag;
    
    MsgObject *one = [[MsgObject alloc]init];
    one.subGroupid = m_nGroupid;
    GroupObject* g = [GroupObject findByGroupid:m_nGroupid];
    one.subGroupName = g.groupName;
    one.subGroupHead = g.groupHead;
    one.numOfMember = g.memberCount;
    one.lastName = [[DataManager sharedManager]getUser].userName;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    one.lastTime = [dateFormat stringFromDate:[NSDate date]];
    one.lastContent = cObject.content;
    [self updateLastList:one];
    
    NSBubbleData *sayBubble = [NSBubbleData dataWithText:cObject.content withObj:cObject withName:@"我" date:cObject.chatTime type:BubbleTypeMine];
    [arrayBubbleData addObject:sayBubble];
    
    [self performSelector:@selector(reloadData) withObject:nil afterDelay:0.0];
    
    [[WebServiceManager sharedManager] sendText:user.userid groupid:m_nGroupid content:chatTextField.text msgTag:[NSString stringWithFormat:@"%d",tag] completion:^(NSDictionary* dic) {
        if (dic==nil) {
            NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:cObject, @"obj", [NSNumber numberWithInt:2], @"state", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
            cObject.chatStatus = eChatObjectStatus_Fail;
            [ChatObject updateOneChatState:cObject];
        } else {
            if ([[dic objectForKey:@"success"]intValue]==1) {
                //ChatObject *oneChat = [self findChatObjectByID:tag];//[ChatObject getOneChat:[dic objectForKey:@"obj"]];
                NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:cObject, @"obj", [NSNumber numberWithInt:3], @"state", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                cObject.chatStatus = eChatObjectStatus_Success;
                [ChatObject updateOneChatState:cObject];
            } else {
                NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:cObject, @"obj", [NSNumber numberWithInt:2], @"state", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                cObject.chatStatus = eChatObjectStatus_Fail;
                [ChatObject updateOneChatState:cObject];
                if ([[dic objectForKey:@"returnCode"]intValue]==101) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息" message:@"你的账号已经在别处登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alert show];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }
        }
    }];
    chatTextField.text = @"";
    [chatTextField clearText];
}

#pragma mark 发送多张图片
- (void)publishImg:(NSArray*)array {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(onDidStop)];
    theView_.bottom=self.view.height;
    chooseView.top=self.view.height;
    [UIView commitAnimations];
    isShowChooseView = NO;
    for (UIImage* img in array) {
        
        NSData *dataObj = UIImageJPEGRepresentation(img, 0.7);
        
        UserObject *user = [[DataManager sharedManager] getUser];
        
        ChatObject *cObject = [[ChatObject alloc] init];
        cObject.content = chatTextField.text;
        cObject.userid = user.userid;
        cObject.groupid = m_nGroupid;
        cObject.chatStatus = eChatObjectStatus_Sending;
        cObject.type = eMessageType_Image;
        
        NSString *filepath = [[Global sharedInstance] saveChatPicture:img];
        cObject.content = filepath;
        filepath = [[Global sharedInstance] saveChatPictureThumb:img];
        cObject.thumbURL = filepath;
        
        int tag = [ChatObject addOneChat:cObject];
        cObject.chatKey = tag;
        
        MsgObject *one = [[MsgObject alloc]init];
        one.subGroupid = m_nGroupid;
        GroupObject* g = [GroupObject findByGroupid:m_nGroupid];
        one.subGroupName = g.groupName;
        one.subGroupHead = g.groupHead;
        one.numOfMember = g.memberCount;
        one.lastName = [[DataManager sharedManager]getUser].userName;
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setTimeZone:[NSTimeZone defaultTimeZone]];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        one.lastTime = [dateFormat stringFromDate:[NSDate date]];
        one.lastContent = @"图片";
        [self updateLastList:one];
        
        chatTableView.typingBubble = NSBubbleTypingTypeNobody;    
        NSBubbleData *photoBubble = [NSBubbleData dataWithURLImage:getPicNameALL(cObject.thumbURL) withObj:cObject withName:@"我" date:cObject.chatTime type:BubbleTypeMine];
        [arrayBubbleData addObject:photoBubble];
        
        [self performSelector:@selector(reloadData) withObject:nil afterDelay:0.0];
        
        [[WebServiceManager sharedManager] sendImg:user.userid groupid:m_nGroupid
                                           imgData:dataObj imgtype:@"jpg" msgTag:[NSString stringWithFormat:@"%d",tag] completion:^(NSDictionary* dic) {
           if (dic==nil) {
               NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:cObject, @"obj", [NSNumber numberWithInt:2], @"state", nil];
               [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
               cObject.chatStatus = eChatObjectStatus_Fail;
               [ChatObject updateOneChatState:cObject];
           } else {
               if ([[dic objectForKey:@"success"]intValue]==1) {
                   //                ChatObject *oneChat = [self findChatObjectByID:tag];//[ChatObject getOneChat:[dic objectForKey:@"obj"]];
                   //                oneChat.chatStatus = eChatObjectStatus_Success;
                   NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:cObject, @"obj", [NSNumber numberWithInt:3], @"state", nil];
                   [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                   cObject.chatStatus = eChatObjectStatus_Success;
                   [ChatObject updateOneChatState:cObject];
               } else {
                   NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:cObject, @"obj", [NSNumber numberWithInt:2], @"state", nil];
                   [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                   cObject.chatStatus = eChatObjectStatus_Fail;
                   [ChatObject updateOneChatState:cObject];
                   if ([[dic objectForKey:@"returnCode"]intValue]==101) {
                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息" message:@"你的账号已经在别处登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                       [alert show];
                       [self.navigationController popToRootViewControllerAnimated:YES];
                   }
               }
           }
        }];
    }
}

- (void)reloadChatTableView:(NSNotification *)notification{
    //[self reloadData];
    [chatTableView reloadData];
}

- (void)reloadData{
    [chatTableView reloadData];
    [self performSelector:@selector(setContentOffset) withObject:nil afterDelay:0.2];
}

- (void)setContentOffset{
//    NSIndexPath* ipath = [NSIndexPath indexPathForRow:arrayBubbleData.count-2 inSection:0];
//    [chatTableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
    CGPoint bottomOffset = CGPointMake(0, chatTableView.contentSize.height - chatTableView.bounds.size.height);
    if ( bottomOffset.y > 0 ) {
        [chatTableView setContentOffset:bottomOffset animated:YES];
    }
}

- (void)onDeleteOneChat:(NSNotification*)sender {
    //NSBubbleData* data = (NSBubbleData*)sender.object;
    ChatObject* chat = (ChatObject*)sender.object;
    NSBubbleData* data = nil;
    if (data.chatObj.chatid == 0) {
        [ChatObject deleteOneChatByChatkey:m_nGroupid withChatkey:chat.chatKey];
        for (NSBubbleData* one in arrayBubbleData) {
            if (one.chatObj.chatKey == chat.chatKey) {
                data = one;
                break;
            }
        }
    } else {
        [ChatObject deleteOneChatByChatid:m_nGroupid withChatid:chat.chatid];
        for (NSBubbleData* one in arrayBubbleData) {
            if (one.chatObj.chatid == chat.chatid) {
                data = one;
                break;
            }
        }
    }
    if (data!=nil) {
        [arrayBubbleData removeObject:data];
        [chatTableView reloadData];
    }
}

- (void)hideTextField:(NSNotification*)sender {
    [chatTextField resignFirstResponder];
}

- (void)onPasteImg:(UILongPressGestureRecognizer*)gesture {
    //UIPasteboard *appPasteBoard =[UIPasteboard pasteboardWithName:@"CopyPasteImage" create:YES];
    //NSData *data =[appPasteBoard dataForPasteboardType:@"com.marizack.CopyPasteImage.imageView"];
    //pasteView.image = [UIImage imageWithData:data];
}

- (void)sendPasteImg:(NSNotification*)sender {
    pasteAlert = [[UIAlertView alloc] initWithTitle:nil message:@"是否发送所复制的图片?" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    pasteAlert.delegate = self;
    [pasteAlert show];    
}

#pragma mark 发送所粘贴的图片
- (void)publishPasteImg {
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    NSString* picURL = pboard.string;
    [chatTextField resignFirstResponder];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(onDidStop)];
    theView_.bottom=self.view.height;
    faceView.top=self.view.height;
    [UIView commitAnimations];
    isShowFaceView = NO;
    
    UserObject *obj = [[DataManager sharedManager] getUser];
    
    ChatObject *cObject = [[ChatObject alloc] init];
    cObject.userid = obj.userid;
    cObject.groupid = m_nGroupid;
    cObject.type = eMessageType_Image;
    cObject.content = picURL;
    cObject.chatStatus = eChatObjectStatus_Sending;
    NSArray* array = [ChatObject findByGroupid:cObject.groupid withType:1];
    for (int i=0; i<array.count; i++) {
        ChatObject* one = [array objectAtIndex:i];
        if ([cObject.content isEqualToString:one.content] ) {
            cObject.thumbURL = one.thumbURL;
            break;
        }
    }
    
    NSData *dataObj = nil;
    NSURL* url = [NSURL URLWithString:getPicNameALL(cObject.content)];
    if (url == nil) {
        dataObj = [NSData dataWithContentsOfFile:getPicNameALL(cObject.content)];
    } else {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *str = [documentsDirectory stringByAppendingPathComponent:@"activity"];
        str = [str stringByAppendingFormat:@"/%@",[cObject.content lastPathComponent]];
        if (file_exists(str)) {
            dataObj = [NSData dataWithContentsOfFile:str];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"gotoPicView" object:cObject];
            return ;
        } 
    }
    
    int tag = [ChatObject addOneChat:cObject];
    cObject.chatKey = tag;
    
    MsgObject *one = [[MsgObject alloc]init];
    one.subGroupid = m_nGroupid;
    GroupObject* g = [GroupObject findByGroupid:m_nGroupid];
    one.subGroupName = g.groupName;
    one.subGroupHead = g.groupHead;
    one.numOfMember = g.memberCount;
    one.lastName = [[DataManager sharedManager]getUser].userName;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    one.lastTime = [dateFormat stringFromDate:[NSDate date]];
    one.lastContent = @"图片";
    [self updateLastList:one];
    
    chatTableView.typingBubble = NSBubbleTypingTypeNobody;
    NSBubbleData *photoBubble = [NSBubbleData dataWithURLImage:getPicNameALL(cObject.content) withObj:cObject withName:@"我" date:cObject.chatTime type:BubbleTypeMine];
    [arrayBubbleData addObject:photoBubble];
    
    [self reloadData];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(onDidStop)];
    theView_.bottom=self.view.height;
    chooseView.top=self.view.height;
    [UIView commitAnimations];
    isShowChooseView = NO;
    
    if (dataObj.length > 0) {
        [[WebServiceManager sharedManager] sendImg:obj.userid groupid:m_nGroupid imgData:dataObj imgtype:@"jpg" msgTag:0  completion:^(NSDictionary* dic) {
            if (dic==nil) {
                NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:cObject, @"obj", [NSNumber numberWithInt:2], @"state", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                cObject.chatStatus = eChatObjectStatus_Fail;
                [ChatObject updateOneChatState:cObject];
            } else {
                if ([[dic objectForKey:@"success"]intValue]==1) {
                    NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:cObject, @"obj", [NSNumber numberWithInt:3], @"state", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                    cObject.chatStatus = eChatObjectStatus_Success;
                    [ChatObject updateOneChatState:cObject];
                } else {
                    NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:cObject, @"obj", [NSNumber numberWithInt:2], @"state", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                    cObject.chatStatus = eChatObjectStatus_Fail;
                    [ChatObject updateOneChatState:cObject];
                    if ([[dic objectForKey:@"returnCode"]intValue]==101) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息" message:@"你的账号已经在别处登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        [alert show];
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }
                }
            }
        }];
    }
}

#pragma mark 粘贴文字
- (void)sendPasteText:(NSNotification*)sender {
    chatTextField.text = (NSString*)sender.object;
}

#pragma mark 增加一个cell
- (void)addOneCell:(NSNotification*)sender {
    ChatObject* one = (ChatObject*)sender.object;
    
    if (one.type == 1) {
        NSBubbleData *heyBubble = [NSBubbleData dataWithText:one.content withObj:one withName:[[DataManager sharedManager]getUser].userName date:isLoadSql?formatStringToDateEx(one.strTime):one.chatTime type:BubbleTypeMine];
        [arrayBubbleData addObject:heyBubble];
    } else if (one.type == 2) {
        NSBubbleData *photoBubble = [NSBubbleData dataWithURLImage:getPicNameALL(one.thumbURL) withObj:one withName:[[DataManager sharedManager]getUser].userName date:isLoadSql?formatStringToDateEx(one.strTime):one.chatTime type:BubbleTypeMine];
        [arrayBubbleData addObject:photoBubble];
    } else if (one.type == 3) {
        NSBubbleData *voiceBubble = [NSBubbleData dataWithVoice:getPicNameALL(one.content) withObj:one withName:[[DataManager sharedManager]getUser].userName date:isLoadSql?formatStringToDateEx(one.strTime):one.chatTime type:BubbleTypeMine];
        [arrayBubbleData addObject:voiceBubble];
    }
    int tag = [ChatObject addOneChat:one];
    one.chatKey = tag;
    [self reloadData];
}

- (void)showAlertView:(NSNotification*)sender {
    int num = [(NSNumber*)sender.object intValue];
    if (num == 1) {
        deleteAlert = [[UIAlertView alloc] initWithTitle:nil message:@"确定要删除该条记录吗?" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
        deleteAlert.delegate = self;
        [deleteAlert show];
    } else if (num == 2) {
        reSendAlert = [[UIAlertView alloc] initWithTitle:nil message:@"是否重发该消息?" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
        reSendAlert.delegate = self;
        [reSendAlert show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == deleteAlert) {
        if (buttonIndex == 1) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"onDeleteOneChat" object:[[DataManager sharedManager]getDeleteObj]];
        }
    } else if (alertView == reSendAlert) {
        if (buttonIndex == 1) {
            [self sendFailMsgAgain:[[DataManager sharedManager]getDeleteObj]];
        }
    } else if (alertView == pasteAlert) {
        if (buttonIndex == 1) {
            [self publishPasteImg];
        }
    }
}

- (void)sendFailMsgAgain:(ChatObject*)one {
    NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:one, @"obj", [NSNumber numberWithInt:1], @"state", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
    one.chatStatus = eChatObjectStatus_Sending;
    [ChatObject updateOneChatState:one];
    if (one.type == 1) {
        [[WebServiceManager sharedManager] sendText:one.userid groupid:one.groupid content:one.content msgTag:[NSString stringWithFormat:@"%d",one.chatKey] completion:^(NSDictionary* dic) {
            if (dic==nil) {
                NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:one, @"obj", [NSNumber numberWithInt:2], @"state", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                one.chatStatus = eChatObjectStatus_Fail;
                [ChatObject updateOneChatState:one];
            } else {
                if ([[dic objectForKey:@"success"]intValue]==1) {
                    NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:one, @"obj", [NSNumber numberWithInt:3], @"state", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                    one.chatStatus = eChatObjectStatus_Success;
                    one.chatTime = [NSDate date];
                    one.strTime = formatDateToStringALL(one.chatTime);
                    [ChatObject updateOneChatState:one];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"onDeleteOneChat" object:[[DataManager sharedManager]getDeleteObj]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"addOneCell" object:one];
                    MsgObject *lastMsg = [[MsgObject alloc]init];
                    lastMsg.subGroupid = m_nGroupid;
                    GroupObject* g = [GroupObject findByGroupid:m_nGroupid];
                    lastMsg.subGroupName = g.groupName;
                    lastMsg.subGroupHead = g.groupHead;
                    lastMsg.numOfMember = g.memberCount;
                    lastMsg.lastName = [[DataManager sharedManager]getUser].userName;
                    lastMsg.lastTime = one.strTime;
                    lastMsg.lastContent = one.content;
                    [self updateLastList:lastMsg];
                } else {
                    NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:one, @"obj", [NSNumber numberWithInt:2], @"state", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                    one.chatStatus = eChatObjectStatus_Fail;
                    [ChatObject updateOneChatState:one];
                    if ([[dic objectForKey:@"returnCode"]intValue]==101) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息" message:@"你的账号已经在别处登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        [alert show];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"backToRoot" object:nil];
                    }
                }
            }
        }];
    } else if (one.type == 2) {
        NSData* dataObj = [NSData dataWithContentsOfFile:one.content];
        [[WebServiceManager sharedManager] sendImg:one.userid groupid:one.groupid imgData:dataObj imgtype:@"jpg" msgTag:0 completion:^(NSDictionary* dic) {
            if (dic==nil) {
                NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:one, @"obj", [NSNumber numberWithInt:2], @"state", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                one.chatStatus = eChatObjectStatus_Fail;
                [ChatObject updateOneChatState:one];
            } else {
                if ([[dic objectForKey:@"success"]intValue]==1) {
                    NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:one, @"obj", [NSNumber numberWithInt:3], @"state", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                    one.chatStatus = eChatObjectStatus_Success;
                    one.chatTime = [NSDate date];
                    one.strTime = formatDateToStringALL(one.chatTime);
                    [ChatObject updateOneChatState:one];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"onDeleteOneChat" object:[[DataManager sharedManager]getDeleteObj]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"addOneCell" object:one];
                    MsgObject *lastMsg = [[MsgObject alloc]init];
                    lastMsg.subGroupid = m_nGroupid;
                    GroupObject* g = [GroupObject findByGroupid:m_nGroupid];
                    lastMsg.subGroupName = g.groupName;
                    lastMsg.subGroupHead = g.groupHead;
                    lastMsg.numOfMember = g.memberCount;
                    lastMsg.lastName = [[DataManager sharedManager]getUser].userName;
                    lastMsg.lastTime = one.strTime;
                    lastMsg.lastContent = @"图片";
                    [self updateLastList:lastMsg];
                } else {
                    NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:one, @"obj", [NSNumber numberWithInt:2], @"state", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                    one.chatStatus = eChatObjectStatus_Fail;
                    [ChatObject updateOneChatState:one];
                    if ([[dic objectForKey:@"returnCode"]intValue]==101) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息" message:@"你的账号已经在别处登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        [alert show];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"backToRoot" object:nil];
                    }
                }
            }
        }];
    } else if (one.type == 3) {
        NSData * reader = [NSData dataWithContentsOfFile:one.content];
        [[WebServiceManager sharedManager] sendVoice:one.userid groupid:one.groupid voiceData:reader msgTag:[NSString stringWithFormat:@"%d",one.chatKey] completion:^(NSDictionary* dic) {
            if (dic==nil) {
                NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:one, @"obj", [NSNumber numberWithInt:2], @"state", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                one.chatStatus = eChatObjectStatus_Fail;
                [ChatObject updateOneChatState:one];
            } else {
                if ([[dic objectForKey:@"success"]intValue]==1) {
                    NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:one, @"obj", [NSNumber numberWithInt:3], @"state", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];                    
                    one.chatStatus = eChatObjectStatus_Success;
                    one.chatTime = [NSDate date];
                    one.strTime = formatDateToStringALL(one.chatTime);
                    [ChatObject updateOneChatState:one];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"onDeleteOneChat" object:[[DataManager sharedManager]getDeleteObj]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"addOneCell" object:one];
                    MsgObject *lastMsg = [[MsgObject alloc]init];
                    lastMsg.subGroupid = m_nGroupid;
                    GroupObject* g = [GroupObject findByGroupid:m_nGroupid];
                    lastMsg.subGroupName = g.groupName;
                    lastMsg.subGroupHead = g.groupHead;
                    lastMsg.numOfMember = g.memberCount;
                    lastMsg.lastName = [[DataManager sharedManager]getUser].userName;
                    lastMsg.lastTime = one.strTime;
                    lastMsg.lastContent = @"语音";
                    [self updateLastList:lastMsg];
                } else {
                    NSDictionary* dic1 = [NSDictionary dictionaryWithObjectsAndKeys:one, @"obj", [NSNumber numberWithInt:2], @"state", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"getSendMsgState" object:dic1];
                    one.chatStatus = eChatObjectStatus_Fail;
                    [ChatObject updateOneChatState:one];
                    if ([[dic objectForKey:@"returnCode"]intValue]==101) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息" message:@"你的账号已经在别处登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        [alert show];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"backToRoot" object:nil];
                    }
                }
            }
        }];
    }
}


@end
