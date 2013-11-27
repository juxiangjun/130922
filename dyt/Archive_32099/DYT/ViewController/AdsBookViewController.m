//
//  AdsBookViewController.m
//  DYT
//
//  Created by zhaoliang.chen on 13-6-3.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "AdsBookViewController.h"
#import "GroupDetailViewController.h"
#import "TKImageCache.h"

@interface AdsBookViewController ()

@end

@implementation AdsBookViewController

#define GROUPTAG        1000
#define GROUPHEADCHILD  2000

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _recvGroupChild = [[TKImageCache alloc] initWithCacheDirectoryName:@"activity"];
        _recvGroupChild.notificationName = @"recvGroupChild";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvGroupChild:) name:@"recvGroupChild" object:nil];
        
        arraySearch = [NSMutableArray new];
    }
    return self;
}

-(id)initWithData:(GroupObject*)obj {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        parentGroup = obj;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.navigationController.navigationBar setBackgroundImage:getBundleImage(@"navBG.png") forBarMetrics:UIBarMetricsDefault];
    self.view.backgroundColor = [UIColor colorWithPatternImage:getBundleImage(@"loginBG.png")];
    self.title = [NSString stringWithFormat:@"通讯录(%@)",parentGroup.groupName];
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    UIButton *button1 = getButtonByImageName(@"btBack.png");
    [button1 addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn1 = [[UIBarButtonItem alloc] initWithCustomView:button1];
    self.navigationItem.leftBarButtonItem = btn1;
    
    UIImageView* searchBG = getImageViewByImageName(@"searchBG.png");
    searchBG.centerX = self.view.width/2;
    searchBG.top = 10;
    searchBG.userInteractionEnabled = YES;
    [self.view addSubview:searchBG];
    
    searchTextField = [[UITextField alloc]initWithFrame:CGRectMake(30, 0, searchBG.width-100, searchBG.height-8)];
    searchTextField.centerY = searchBG.height/2;
    searchTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    searchTextField.textAlignment = NSTextAlignmentLeft;
    searchTextField.delegate = self;
    searchTextField.returnKeyType = UIReturnKeySearch;
    [searchBG addSubview:searchTextField];
    
    listScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, searchBG.bottom+10, self.view.width, self.view.height-searchBG.height-20)];
    listScrollView.userInteractionEnabled = YES;
    listScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:listScrollView];
    
    height = 0.0f;
    [self createScrollView:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self.navigationController setNavigationBarHidden:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_recvGroupChild cancelOperations];
}

- (void)createScrollView:(BOOL)isSearch {
    for (UIView* v in listScrollView.subviews) {
        [v removeFromSuperview];
    }
    NSArray* arr = nil;
    if (isSearch) {
        arr = arraySearch;
    } else {
        arr = parentGroup.subGroup;
    }
    for (int i=0; i<arr.count; i++) {
        GroupObject* one = [arr objectAtIndex:i];
        
        UIView* v = [[UIView alloc]initWithFrame:CGRectMake(0, height, listScrollView.width, 50.0f)];
        if (i%2==0) {
            v.backgroundColor = [UIColor colorWithPatternImage:getBundleImage(@"groupBGgray.png")];
        } else {
            v.backgroundColor = [UIColor colorWithPatternImage:getBundleImage(@"groupBGwhite.png")];
        }
        v.tag = GROUPTAG+i;
        [listScrollView addSubview:v];
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTap:)];
        [v addGestureRecognizer:tap];
        
        UIImageView* head = createPortraitView(44);
        head.left = 10;
        head.centerY = v.height/2;
        head.tag = GROUPHEADCHILD+i;
        head.image = getBundleImage(@"defaultGroup.png");
        if ((![one.groupHead isKindOfClass:[NSNull class]])&&one.groupHead.length>0) {
            NSURL *url = [NSURL URLWithString:getPicNameALL(one.groupHead)];
            UIImage *img = [_recvGroupChild imageForKey:[one.groupHead lastPathComponent]                                          url:url queueIfNeeded:YES tag:head.tag];
            if (img) {
                head.image = img;
            }
        }
        [v addSubview:head];
        
        UILabel* groupName = [[UILabel alloc]initWithFrame:CGRectMake(head.right+10, 2, v.width/2, 20)];
        groupName.backgroundColor = [UIColor clearColor];
        groupName.textColor = [UIColor colorWithRed:163.0/255.0 green:38.0/255.0 blue:38.0/255.0 alpha:1.0f];
        groupName.textAlignment = NSTextAlignmentLeft;
        groupName.font = [UIFont systemFontOfSize:12];
        groupName.text = one.groupName;
        [v addSubview:groupName];
        
        UILabel* l1 = [[UILabel alloc]initWithFrame:CGRectMake(groupName.left, groupName.bottom+4, 15, 20)];
        l1.backgroundColor = [UIColor clearColor];
        l1.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0f];
        l1.textAlignment = NSTextAlignmentLeft;
        l1.font = [UIFont systemFontOfSize:12];
        l1.text = @"共";
        l1.width = [l1.text sizeWithFont:l1.font].width;
        [v addSubview:l1];
        
        UILabel* l2 = [[UILabel alloc]initWithFrame:CGRectMake(l1.right, l1.top, 10, 20)];
        l2.backgroundColor = [UIColor clearColor];
        l2.textColor = [UIColor blackColor];
        l2.textAlignment = NSTextAlignmentLeft;
        l2.font = [UIFont systemFontOfSize:12];
        l2.text = [NSString stringWithFormat:@"%d",one.memberCount];
        l2.width = [l2.text sizeWithFont:l2.font].width;
        [v addSubview:l2];
        
        UILabel* l3 = [[UILabel alloc]initWithFrame:CGRectMake(l2.right, l1.top, 15, 20)];
        l3.backgroundColor = [UIColor clearColor];
        l3.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0f];
        l3.textAlignment = NSTextAlignmentLeft;
        l3.font = [UIFont systemFontOfSize:12];
        l3.text = @"人";
        l3.width = [l3.text sizeWithFont:l3.font].width;
        [v addSubview:l3];
        
        UILabel* mask = [[UILabel alloc]initWithFrame:CGRectMake(0, l1.top, 15, 20)];
        mask.backgroundColor = [UIColor clearColor];
        mask.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0f];
        mask.textAlignment = NSTextAlignmentRight;
        mask.font = [UIFont systemFontOfSize:12];
        mask.text = one.remark;
        mask.width = [mask.text sizeWithFont:mask.font].width;
        mask.right = v.width-20;
        [v addSubview:mask];        
        
        if ([GroupObject findByGroupid:one.groupid]==nil) {
            [GroupObject addOneGroup:one];
        } else {
            [GroupObject updateGroup:one];
        }
        
        height = v.bottom;
    }
    listScrollView.contentSize = CGSizeMake(listScrollView.width, height);
}

- (void)onTap:(UITapGestureRecognizer*)sender {
    GroupObject* obj = [parentGroup.subGroup objectAtIndex:sender.view.tag-GROUPTAG];
    GroupDetailViewController* v = [[GroupDetailViewController alloc]initWithData:obj withName:parentGroup.groupName];
    [self.navigationController pushViewController:v animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [searchTextField resignFirstResponder];
    height = 0.0f;
    [arraySearch removeAllObjects];
    if (searchTextField.text.length>0) {
        for (GroupObject* p in parentGroup.subGroup) {
            NSRange foundObj=[p.groupName rangeOfString:searchTextField.text options:NSCaseInsensitiveSearch];
            if (foundObj.length>0) {
                [arraySearch addObject:p];
            }
        }
        [self createScrollView:YES];
    } else {
        [self createScrollView:NO];
    }
    return YES;
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)recvGroupChild:(NSNotification*)sender {
    NSDictionary *dict = [sender userInfo];
    UIImage *img = [dict objectForKey:@"image"];
    int tag = [[dict objectForKey:@"tag"] intValue];    
    UIImageView* imgView = (UIImageView*)[listScrollView viewWithTag:tag];    
    imgView.image = img;
}

@end
