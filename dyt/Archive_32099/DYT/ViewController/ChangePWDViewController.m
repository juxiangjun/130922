//
//  ChangePWDViewController.m
//  DYT
//
//  Created by zhaoliang.chen on 13-6-7.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "ChangePWDViewController.h"

@interface ChangePWDViewController ()

@end

@implementation ChangePWDViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.navigationController.navigationBar setBackgroundImage:getBundleImage(@"navBG.png") forBarMetrics:UIBarMetricsDefault];
    self.view.backgroundColor = [UIColor colorWithPatternImage:getBundleImage(@"loginBG.png")];
    self.title = @"修改密码";
    
    UIButton *button1 = getButtonByImageName(@"btBack.png");
    [button1 addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn1 = [[UIBarButtonItem alloc] initWithCustomView:button1];
    self.navigationItem.leftBarButtonItem = btn1;
    
    UIButton *button2 = getButtonByImageName(@"btFinish.png");
    [button2 addTarget:self action:@selector(onFinish) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn2 = [[UIBarButtonItem alloc] initWithCustomView:button2];
    self.navigationItem.rightBarButtonItem = btn2;
    
    UIView* view = [[UIView alloc]initWithFrame:CGRectMake(0, 10, 306, 20)];
    view.centerX = self.view.width/2;
    view.layer.cornerRadius = 8.0f;
    view.clipsToBounds = YES;
    view.layer.borderWidth = 1.0f;
    view.layer.borderColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0f].CGColor;
    view.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0f];
    [self.view addSubview:view];
    
    NSString* titleForUpView[3]={@"原密码",@"新密码",@"确认密码"};
    int height = 0;
    for (int i=0; i<3; i++) {
        UIView* v = [[UIView alloc]initWithFrame:CGRectMake(0, height, view.width, 0)];
        v.height=40;
        v.backgroundColor = [UIColor clearColor];
        [view addSubview:v];
        
        UILabel* l = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 100, 25)];
        l.centerY = v.height/2;
        l.backgroundColor = [UIColor clearColor];
        l.textColor = [UIColor blackColor];
        l.textAlignment = NSTextAlignmentLeft;
        l.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:14];
        l.text = titleForUpView[i];
        [v addSubview:l];
        
        if (i==0) {
            oldPwd = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 200, 25)];
            oldPwd.right = view.width-10;
            oldPwd.centerY = v.height/2;
            oldPwd.backgroundColor = [UIColor clearColor];
            oldPwd.borderStyle = UITextBorderStyleNone;
            oldPwd.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            oldPwd.textAlignment = NSTextAlignmentLeft;
            oldPwd.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:14];
            oldPwd.delegate = self;
            oldPwd.placeholder = @"请输入旧密码";
            oldPwd.secureTextEntry = YES;
            [v addSubview:oldPwd];
        } else if (i==1) {
            newPwd = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 200, 25)];
            newPwd.right = oldPwd.right;
            newPwd.centerY = v.height/2;
            newPwd.backgroundColor = [UIColor clearColor];
            newPwd.borderStyle = UITextBorderStyleNone;
            newPwd.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            newPwd.textAlignment = NSTextAlignmentLeft;
            newPwd.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:14];
            newPwd.delegate = self;
            newPwd.placeholder = @"请输入新密码";
            newPwd.secureTextEntry = YES;
            [v addSubview:newPwd];
        } else if (i==2) {
            comfirmNewPwd = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 200, 25)];
            comfirmNewPwd.right = oldPwd.right;
            comfirmNewPwd.centerY = v.height/2;
            comfirmNewPwd.backgroundColor = [UIColor clearColor];
            comfirmNewPwd.borderStyle = UITextBorderStyleNone;
            comfirmNewPwd.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            comfirmNewPwd.textAlignment = NSTextAlignmentLeft;
            comfirmNewPwd.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:14];
            comfirmNewPwd.delegate = self;
            comfirmNewPwd.placeholder = @"请再次输入新密码";
            comfirmNewPwd.secureTextEntry = YES;
            [v addSubview:comfirmNewPwd];
        }
        UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0, v.bottom, v.width, 1)];
        line.backgroundColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0f];
        [view addSubview:line];
        
        height = line.bottom;
    }
    view.height = height-1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onFinish {
    [oldPwd resignFirstResponder];
    [newPwd resignFirstResponder];
    [comfirmNewPwd resignFirstResponder];
    if (![newPwd.text isEqualToString:comfirmNewPwd.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息" message:@"两次设置的新密码不一样!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return ;
    }
    if (newPwd.text.length==0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息" message:@"新密码不能为空!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return ;
    }
    [WaitTooles showHUD:@"正在更新新密码..."];
    [[WebServiceManager sharedManager] updatePassword:[[DataManager sharedManager] getUser].userid oldPassword:oldPwd.text newPassword:newPwd.text encodeStr:[[DataManager sharedManager]getUser].encodeStr completion:^(NSDictionary* dic) {
        [WaitTooles removeHUD];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"结果" message:[dic objectForKey:@"msg"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
