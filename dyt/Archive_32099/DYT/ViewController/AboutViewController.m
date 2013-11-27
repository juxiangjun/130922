//
//  AboutViewController.m
//  DYT
//
//  Created by zhaoliang.chen on 13-7-26.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController
@synthesize bLaunch;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        bLaunch = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.navigationController.navigationBar setBackgroundImage:getBundleImage(@"navBG.png") forBarMetrics:UIBarMetricsDefault];
    self.view.backgroundColor = [UIColor colorWithRed:243.0/255.0 green:243.0/255.0 blue:243.0/255.0 alpha:1.0f];
    self.title = @"关于大业堂";
    
    UIButton *button1 = getButtonByImageName(@"btBack.png");
    [button1 addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn1 = [[UIBarButtonItem alloc] initWithCustomView:button1];
    self.navigationItem.leftBarButtonItem = btn1;
    
    UIScrollView* scrollView_ = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    scrollView_.height = self.view.height-self.navigationController.navigationBar.height;
    scrollView_.pagingEnabled = YES;
    [self.view addSubview:scrollView_];
    
    for (int i=0; i<4; i++) {
        UIView* back = [[UIView alloc]initWithFrame:CGRectMake(i*scrollView_.width, 0, scrollView_.width, scrollView_.height)];
        [scrollView_ addSubview:back];
        
        UIImageView* v = getImageViewByImageName([NSString stringWithFormat:@"About%03d.jpg",i+1]);
        v.center = CGPointMake(back.width/2, back.height/2);
        [back addSubview:v];
        scrollView_.contentSize = CGSizeMake(back.right, scrollView_.height);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
}

- (void)goBack {
    if (bLaunch) {
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.hidesBottomBarWhenPushed = NO;//马上设置回NO
}

@end
