//
//  MaskViewController.m
//  DYT
//
//  Created by zhaoliang.chen on 13-7-9.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "MaskViewController.h"

@interface MaskViewController ()

@end

@implementation MaskViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithData:(NSString*)mask {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        m_Mask = mask;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.navigationController.navigationBar setBackgroundImage:getBundleImage(@"navBG.png") forBarMetrics:UIBarMetricsDefault];
    self.view.backgroundColor = [UIColor colorWithRed:243.0/255.0 green:243.0/255.0 blue:243.0/255.0 alpha:1.0f];
    self.title = @"编辑个性签名";

    UIButton *button1 = getButtonByImageName(@"btBack.png");
    [button1 addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn1 = [[UIBarButtonItem alloc] initWithCustomView:button1];
    self.navigationItem.leftBarButtonItem = btn1;
    
    UIButton *button2 = getButtonByImageName(@"btFinish.png");
    [button2 addTarget:self action:@selector(goSave) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn2 = [[UIBarButtonItem alloc] initWithCustomView:button2];
    self.navigationItem.rightBarButtonItem = btn2;
    
    m_TextView = [[UITextView alloc]initWithFrame:CGRectMake(0, 10, self.view.width-20, 300)];
    m_TextView.layer.borderColor = [UIColor grayColor].CGColor;
    m_TextView.layer.borderWidth = 1.0f;
    m_TextView.layer.cornerRadius = 6.0f;
    m_TextView.centerX = self.view.width/2;
    if ([[DataManager sharedManager]getUser].explain.length==0) {
        m_TextView.text = @"编辑您的个性签名";
        m_TextView.textColor = [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1.0f];
    } else {
        m_TextView.text = [[DataManager sharedManager]getUser].explain;
        m_TextView.textColor = [UIColor blackColor];
    }
    m_TextView.delegate = self;
    m_TextView.font = [UIFont systemFontOfSize:15];
    m_TextView.textAlignment = UITextAlignmentLeft;
    [self.view addSubview:m_TextView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@"编辑您的个性签名"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    } 
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{    
    if([text isEqualToString:@"\n"]) {
        if (textView.text.length <= 0) {
            textView.text = @"编辑您的个性签名";
            textView.textColor = [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1.0f];
        }
        [textView resignFirstResponder];
        return NO;
    }
    //int remainTextNum_=30;
    //计算剩下多少文字可以输入
    if(range.location>=30&&range.length==0){
        //remainTextNum_=0;
        return NO;
    } else {
        //int existTextNum=[m_TextView.text length];
        //remainTextNum_=30-existTextNum;
        return YES;
    }
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length <= 0) {
        textView.text = @"编辑您的个性签名";
        textView.textColor = [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1.0f];
    }
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)goSave {
    [m_TextView resignFirstResponder];
    if ([m_TextView.text isEqualToString:@"编辑您的个性签名"]) {
        m_TextView.text = @"";
    }
    [WaitTooles showHUD:@"正在更新个性签名..."];
    [[WebServiceManager sharedManager] updateMask:[[DataManager sharedManager]getUser].userid mask:m_TextView.text encodeStr:[[DataManager sharedManager]getUser].encodeStr completion:^(NSDictionary* dic) {
        [WaitTooles removeHUD];
        if ([[dic objectForKey:@"success"]intValue]==1) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMask" object:m_TextView.text];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"结果" message:[dic objectForKey:@"msg"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}



















@end
