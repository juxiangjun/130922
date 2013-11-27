//
//  LoginViewController.m
//  DYT
//
//  Created by zhaoliang.chen on 13-5-31.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "LoginViewController.h"
#import "MainViewController.h"
#import "WebServiceManager.h"
#import "AboutViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize nameTextField;
@synthesize psdTextField;
@synthesize isRecv;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRecvMsg:) name:@"onRecvMsg" object:nil];
        isRecv = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    [self.navigationController.navigationBar setBackgroundImage:getBundleImage(@"navBG.png") forBarMetrics:UIBarMetricsDefault];
    self.view.backgroundColor = [UIColor colorWithPatternImage:getBundleImage(@"loginBG.png")];
    self.title = @"大业堂";
    
    UIView *vv = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:vv];
    vv.backgroundColor = [UIColor clearColor];
    
    UIImageView* logo = getImageViewByImageName(@"logoOnLogin.png");
    logo.centerX = self.view.width/2;
    logo.top = 30;
    [self.view addSubview:logo];
    
    UIImageView* textBG1 = getImageViewByImageName(@"inputBGOnLogin.png");
    textBG1.centerX = logo.centerX;
    textBG1.top = logo.bottom+20;
    textBG1.userInteractionEnabled = YES;
    [self.view addSubview:textBG1];
    
    nameTextField = [[UITextField alloc]initWithFrame:CGRectMake(75, 0, textBG1.width-70, textBG1.height/2-10)];
    nameTextField.centerY = textBG1.height/4+2;
    nameTextField.backgroundColor = [UIColor clearColor];
    nameTextField.placeholder = @"手机号";
    nameTextField.textAlignment = NSTextAlignmentLeft;
    nameTextField.delegate = self;
    nameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    nameTextField.returnKeyType = UIReturnKeyDone;
    [textBG1 addSubview:nameTextField];
    
    psdTextField = [[UITextField alloc]initWithFrame:CGRectMake(75, 0, nameTextField.width, nameTextField.height)];
    psdTextField.centerY = textBG1.height*3/4+2;
    psdTextField.backgroundColor = [UIColor clearColor];
    psdTextField.placeholder = @"6-10位英文或数字";
    psdTextField.textAlignment = NSTextAlignmentLeft;
    psdTextField.delegate = self;
    psdTextField.secureTextEntry = YES;
    psdTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    psdTextField.returnKeyType = UIReturnKeyDone;
    [textBG1 addSubview:psdTextField];
    
    UIButton* btLogin = getButtonByImageName(@"btLogin.png");
    btLogin.centerX = textBG1.centerX;
    btLogin.top = textBG1.bottom+20;
    [btLogin addTarget:self action:@selector(onLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btLogin];
    
    UIImageView* company = getImageViewByImageName(@"companyName.png");
    company.centerX = logo.centerX;
    company.top = btLogin.bottom+20;
    [self.view addSubview:company];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKey:)];
    [vv addGestureRecognizer:tap];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    int userid = [[def objectForKey:@"userid"]intValue];
    NSString* encodeStr = [def objectForKey:[NSString stringWithFormat:@"%d_encodeStr",userid]];
    if (userid != 0 && encodeStr.length > 0 && encodeStr != nil) {
        UserObject* user = [[UserObject alloc]init];
        user.userid = userid;
        user.encodeStr = encodeStr;
        [[DataManager sharedManager] setUser:user];
        MainViewController* v = [[MainViewController alloc]initWithUserid:userid];
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        [self.navigationController pushViewController:v animated:NO];
    }
    
    UILabel *tel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 25)];
    tel.text = @"客服热线: 400-997-5277";
    tel.textAlignment = NSTextAlignmentCenter;
    tel.backgroundColor = [UIColor clearColor];
    tel.font = [UIFont fontWithName:@"STHeiti" size:20];
    [self.view addSubview:tel];
    [tel sizeToFit];
    tel.center = CGPointMake(self.view.width/2, 0);
    tel.bottom = self.view.height - 64;
    tel.textColor = [UIColor grayColor];
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tel.width, 1)];
    v.backgroundColor = tel.textColor;
    [self.view addSubview:v];
    v.left = tel.left;
    v.top = tel.bottom;
    UITapGestureRecognizer *dial = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dial)];
    [tel addGestureRecognizer:dial];
    tel.userInteractionEnabled = YES;
}

- (void)dial{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://4009975277"]];
}

- (void) hideKey:(UITapGestureRecognizer * ) sender{
    if (nameTextField.isFirstResponder) {
        [nameTextField resignFirstResponder];
    }
    else if (psdTextField.isFirstResponder){
        [psdTextField resignFirstResponder ];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    psdTextField.text = @"";
#ifdef DEBUG
    nameTextField.text = @"t8";
    psdTextField.text = @"123";
#endif

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSString* launchFlag = [defs objectForKey:@"bFirstLaunch"];
    if (launchFlag==nil) {
        AboutViewController *about = [[AboutViewController alloc] init];
        about.bLaunch = YES;
        UINavigationController *c = [[UINavigationController alloc] initWithRootViewController:about];
        [self.navigationController presentModalViewController:c animated:YES];
        
        [defs setObject:@"1" forKey:@"bFirstLaunch"];
        [defs synchronize];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [nameTextField resignFirstResponder];
    [psdTextField resignFirstResponder];
    return YES;
}

- (void)onLogin {
    UserObject* user = [[UserObject alloc]init];
    user.account = nameTextField.text;
    user.password = psdTextField.text;

    [nameTextField resignFirstResponder];
    [psdTextField resignFirstResponder];
    
    [WaitTooles showHUD:@"正在登陆中....."];
    [[WebServiceManager sharedManager] onLogin:user completion:^(NSDictionary* dic) {
        [WaitTooles removeHUD];
        BOOL res = [[dic objectForKey:@"success"]boolValue];
        if (res) {
            NSDictionary* dicc = [dic objectForKey:@"obj"];
            user.userid = [[dicc objectForKey:@"userid"]intValue];
            user.encodeStr = [dicc objectForKey:@"encodeStr"];
            //NSString *str1 = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%d_encodeStr",user.userid]];
            //if ((str1.length==0&&[str1 isKindOfClass:[NSString class]]) || str1==nil) {
                [[NSUserDefaults standardUserDefaults] setObject:user.encodeStr forKey:[NSString stringWithFormat:@"%d_encodeStr",user.userid]];
            //}
            [[NSUserDefaults standardUserDefaults] synchronize];
            [WaitTooles showHUD:@"正在获取用户信息....."];
            [[WebServiceManager sharedManager] getUserInfo:user.userid encodeStr:user.encodeStr completion:^(NSDictionary* dic1) {
                int success = [[dic1 objectForKey:@"success"]intValue];
                if (success == 1) {
                    NSDictionary* dic1cc = [dic1 objectForKey:@"obj"];
                    user.userName = [dic1cc objectForKey:@"name"];
                    user.userHeadURL = [dic1cc objectForKey:@"thumb"];
                    if ([user.userHeadURL isKindOfClass:[NSNull class]] || [user.userHeadURL rangeOfString:@"null" options:NSCaseInsensitiveSearch].length>0 || user.userHeadURL == nil) {
                        user.userHeadURL = @"";
                    }
                    user.userHeadLargeURL = [dic1cc objectForKey:@"pic"];
                    if ([user.userHeadLargeURL isKindOfClass:[NSNull class]] || [user.userHeadLargeURL rangeOfString:@"null" options:NSCaseInsensitiveSearch].length>0 || user.userHeadLargeURL == nil) {
                        user.userHeadLargeURL = @"";
                    }
                    if ([[dic1cc objectForKey:@"sex"] isKindOfClass:[NSNumber class]]) {
                        user.sex = [[dic1cc objectForKey:@"sex"]intValue];
                    } else {
                        user.sex = 0;
                    }
                    user.hometown = [NSString stringWithFormat:@"%@%@",[dic1cc objectForKey:@"area1"],[dic1cc objectForKey:@"area2"]];
                    if ([user.hometown isKindOfClass:[NSNull class]] || [user.hometown rangeOfString:@"null" options:NSCaseInsensitiveSearch].length>0) {
                        user.hometown = @"";
                    }
                    user.location = [NSString stringWithFormat:@"%@",[dic1cc objectForKey:@"job2"]];
                    if ([user.location isKindOfClass:[NSNull class]] || [user.location rangeOfString:@"null" options:NSCaseInsensitiveSearch].length>0) {
                        user.location = @"";
                    }
                    user.explain = [dic1cc objectForKey:@"sign"];
                    if ([user.explain isKindOfClass:[NSNull class]] || [user.explain rangeOfString:@"null" options:NSCaseInsensitiveSearch].length>0 || user.explain == nil) {
                        user.explain = @"";
                    }
                    user.pos = [dic1cc objectForKey:@"pos"];
                    if ([user.pos isKindOfClass:[NSNull class]] || [user.pos rangeOfString:@"null" options:NSCaseInsensitiveSearch].length>0 || user.pos == nil) {
                        user.pos = @"";
                    }
                    [[DataManager sharedManager] setUser:user];
                    if ([UserObject findByID:user.userid]==nil) {
                        [UserObject addName:user];
                    } else {
                        [UserObject updataName:user];
                    }
#ifdef DEBUG
                    NSDate* date = [NSDate dateWithMinutesBeforeNow:5];
#else
                    NSDate* date = [NSDate dateWithMinutesBeforeNow:0];
#endif
                    //NSDate* date = [NSDate dateWithDaysBeforeNow:30];
                    NSString* strDate = formatDateToStringALLEx(date);
                    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                    NSString *str = [def objectForKey:[NSString stringWithFormat:@"%d_lastGetMsgTime",user.userid]];
                    if (([str isKindOfClass:[NSString class]]&&str.length==0) || str==nil) {
                        [def setObject:strDate forKey:[NSString stringWithFormat:@"%d_lastGetMsgTime",user.userid]];
                    }
                    [def setObject:[NSNumber numberWithInt:user.userid]  forKey:@"userid"];
                    [def synchronize];
                    
                    [[WebServiceManager sharedManager] getGroupMain:[[DataManager sharedManager] getUser].userid encodeStr:[[DataManager sharedManager] getUser].encodeStr completion:^(NSDictionary* dic) {
                        [WaitTooles removeHUD];
                        int success = [[dic objectForKey:@"success"]intValue];
                        if (success == 1) {
                            NSArray* array = [dic objectForKey:@"obj"];
                            if ([array isKindOfClass:[NSArray class]]) {
                                [GroupObject deleteAllGroupid];
                                for (int i=0; i<array.count; i++) {
                                    NSDictionary* dic1 = [array objectAtIndex:i];
                                    GroupObject* one = [GroupObject getOneGroup:dic1];                                    
                                    if ([GroupObject findByGroupid:one.groupid]==nil) {
                                        [GroupObject addOneGroup:one];
                                    } else {
                                        [GroupObject updateGroup:one];
                                    }
                                }
                            }                            
                            MainViewController* v = [[MainViewController alloc]init];
                            [self.navigationController pushViewController:v animated:YES];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateNewAnn" object:[NSNumber numberWithBool:YES]];
                        } else {
                            if ([[dic objectForKey:@"returnCode"]intValue]==101) {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息" message:@"你的账号已经在别处登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                                [alert show];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"backToRoot" object:nil];
                            }
                        }
                    }];
                } else {
                    [WaitTooles removeHUD];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息" message:[dic1 objectForKey:@"msg"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alert show];                    
                }
            }];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息" message:[dic objectForKey:@"msg"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return NO;
}

- (void)onRecvMsg:(NSNotification*)sender {
    if (isRecv) {
        return ;
    }
    isRecv = YES;
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *str = [def objectForKey:[NSString stringWithFormat:@"%d_lastGetMsgTime",[[DataManager sharedManager]getUser].userid]];
    
    [[WebServiceManager sharedManager] getMsgList:[[DataManager sharedManager]getUser].userid encodeStr:[[DataManager sharedManager]getUser].encodeStr date:str completion:^(NSDictionary* dic) {
        int success = [[dic objectForKey:@"success"]intValue];
        if (success == 1) {
            NSDate* compareTime = [NSDate dateWithTimeIntervalSince1970:0];
            NSString *strMilli = nil;
            NSArray* array = [dic objectForKey:@"obj"];
            if ([array isKindOfClass:[NSArray class]]) {
                int allNewMsgCount = [[DataManager sharedManager]getMsgCount];
                for (int i=0; i<array.count; i++) {
                    NSDictionary* dic1 = [array objectAtIndex:i];
                    MsgObject* one = [MsgObject getOneMsg:dic1];
                    int count = [MsgObject findCountByID:one.subGroupid];
                    count += one.newMsgCount;
                    allNewMsgCount += one.newMsgCount;
                    one.newMsgCount = count;
                    if ([MsgObject findByID:one.subGroupid]==nil) {
                        [MsgObject addOneLast:one];
                    } else {
                        [MsgObject updateByID:one];
                    }
                    NSDictionary* ddd = [NSDictionary dictionaryWithObjectsAndKeys:one.arrayChat, @"array", [NSNumber numberWithInt:one.subGroupid], @"groupid", nil];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"onRecvMsgOnChat" object:ddd];
                    if ([formatStringToDateMilli(one.lastTime) compare:compareTime]==NSOrderedDescending) {
                        compareTime = formatStringToDateMilli(one.lastTime);
                        strMilli = one.lastTime;
                    }
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateNewMsg" object:[NSNumber numberWithInt:allNewMsgCount]];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"onChangeNum" object:[NSNumber numberWithInt:allNewMsgCount]];
                [[DataManager sharedManager] setMsgCount:allNewMsgCount];
                
                if (array.count>0) {
                    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                    [def setObject:strMilli forKey:[NSString stringWithFormat:@"%d_lastGetMsgTime",[[DataManager sharedManager]getUser].userid]];
                    [def synchronize];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"onRecvMsgOnMsg" object:nil];
                }
            }
        }
        isRecv = NO;
    }];
    
//************************************根据苹果推送***********************************//
//    NSDictionary* dic = (NSDictionary*)sender.object;
//    if (dic==nil) {
//        return ;
//    }
//    ChatObject* chat = [ChatObject getOneChat:dic];
//    chat.chatStatus = eChatObjectStatus_Success;
//    if ([ChatObject findByChatid:chat.groupid withChatid:chat.chatid]==nil) {
//        [ChatObject addOneChat:chat];
//    }
//    MsgObject* msg = [[MsgObject alloc]init];
//    msg.subGroupid = chat.groupid;
//    GroupObject* group = [GroupObject findByGroupid:chat.groupid];
//    msg.subGroupHead = group.groupHead;
//    msg.subGroupName = group.groupName;
//    msg.numOfMember = group.memberCount;
//    msg.lastName = chat.userName;
//    msg.lastContent = chat.content;
//    msg.lastTime = chat.strTime;
//    int count = [MsgObject findCountByID:msg.subGroupid];
//    count += 1;
//    msg.newMsgCount = count;
//    if ([MsgObject findByID:msg.subGroupid]==nil) {
//        [MsgObject addOneLast:msg];
//    } else {
//        [MsgObject updateByID:msg];
//    }
//    int all = [[DataManager sharedManager]getMsgCount];
//    all+=1;
//    [[DataManager sharedManager]setMsgCount:all];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateNewMsg" object:[NSNumber numberWithInt:all]];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"onChangeNum" object:[NSNumber numberWithInt:all]];    
//    NSDictionary* ddd = [NSDictionary dictionaryWithObjectsAndKeys:chat, @"chat", [NSNumber numberWithInt:msg.subGroupid], @"groupid", nil];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"onRecvMsgOnChat" object:ddd];
//    
//    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
//    [def setObject:chat.strTime forKey:[NSString stringWithFormat:@"%d_lastGetMsgTime",[[DataManager sharedManager]getUser].userid]];
//    [def synchronize];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"onRecvMsgOnMsg" object:nil];
}

- (BOOL)shouldAutorotate{
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
//    return UIInterfaceOrientationMaskAll;
}

@end
