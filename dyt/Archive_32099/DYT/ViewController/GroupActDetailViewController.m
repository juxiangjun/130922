//
//  GroupActDetailViewController.m
//  DYT
//
//  Created by zhaoliang.chen on 13-7-8.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "GroupActDetailViewController.h"

@interface GroupActDetailViewController ()

@end

@implementation GroupActDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithDetail:(NSString*)detail {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        content = detail;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.navigationController.navigationBar setBackgroundImage:getBundleImage(@"navBG.png") forBarMetrics:UIBarMetricsDefault];
    self.view.backgroundColor = [UIColor colorWithPatternImage:getBundleImage(@"loginBG.png")];
    self.title = @"活动详细内容";
    
    UIButton *button1 = getButtonByImageName(@"btBack.png");
    [button1 addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn1 = [[UIBarButtonItem alloc] initWithCustomView:button1];
    self.navigationItem.leftBarButtonItem = btn1;
    
    mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 10, self.view.width, self.view.height-self.navigationController.navigationBar.height-self.tabBarController.tabBar.height-10)];
    mainScrollView.userInteractionEnabled = YES;
    mainScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:mainScrollView];
    
    UIView* backView = [[UIView alloc]initWithFrame:CGRectMake(10, 10, mainScrollView.width-20, 300)];
    backView.backgroundColor = [UIColor whiteColor];
    backView.layer.cornerRadius = 6.0f;
    backView.layer.borderColor = [UIColor blackColor].CGColor;
    backView.layer.borderWidth = 1.0f;
    [mainScrollView addSubview:backView];
    
    contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, backView.width-10, 20)];
    contentLabel.textAlignment = NSTextAlignmentLeft;
    contentLabel.textColor = [UIColor blackColor];
    contentLabel.font = [UIFont systemFontOfSize:16];
    contentLabel.backgroundColor = [UIColor clearColor];
    contentLabel.text = content;
    contentLabel.numberOfLines = 0;
    CGSize size = CGSizeMake(contentLabel.width,2000);
    CGSize labelsize = [contentLabel.text sizeWithFont:contentLabel.font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
    contentLabel.frame = CGRectMake(contentLabel.left, contentLabel.top, contentLabel.width, labelsize.height);
    [backView addSubview:contentLabel];
    if (contentLabel.height>backView.height) {
        backView.height=contentLabel.height+10;
    }
    
    mainScrollView.contentSize = CGSizeMake(mainScrollView.width, backView.bottom+10);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
