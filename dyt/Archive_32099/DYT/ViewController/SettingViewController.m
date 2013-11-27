//
//  SettingViewController.m
//  DYT
//
//  Created by zhaoliang.chen on 13-6-3.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "SettingViewController.h"
#import "ChangePWDViewController.h"
#import "TKImageCache.h"
#import "ProvinceViewController.h"
#import "MainJobViewController.h"
#import "config.h"
#import "MaskViewController.h"
#import "AboutViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

#define UPVIEWTAG       100
#define NUMOFUPVIEW     8
#define NUMOFDOWNVIEW   2
#define NUMOFMIDDLEVIEW   1

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"设置" image:[UIImage imageNamed:@"btSet.png"] tag:3];
        self.tabBarItem = tabBarItem;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateArea:) name:@"updateArea" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateJob:) name:@"updateJob" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMask:) name:@"updateMask" object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view. 
    [self.navigationController.navigationBar setBackgroundImage:getBundleImage(@"navBG.png") forBarMetrics:UIBarMetricsDefault];
    self.view.backgroundColor = [UIColor colorWithPatternImage:getBundleImage(@"loginBG.png")];
    self.title = @"设置";
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    _recvUserHeadOnSetting = [[TKImageCache alloc] initWithCacheDirectoryName:@"activity"];
    _recvUserHeadOnSetting.notificationName = @"recvUserHeadOnSetting";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvUserHeadOnSetting:) name:@"recvUserHeadOnSetting" object:nil];
    
    scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-self.tabBarController.tabBar.height-self.navigationController.navigationBar.height)];
    scroll.backgroundColor = [UIColor clearColor];
    scroll.userInteractionEnabled = YES;
    [self.view addSubview:scroll];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_recvUserHeadOnSetting cancelOperations];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    myUser = [[DataManager sharedManager] getUser];    
    [self createScrollView];
}

- (void)createScrollView {
    for (UIView* v in scroll.subviews) {
        if (v.tag > 100) {
            [v removeFromSuperview];
        }
    }
    
    upView = [[UIView alloc]initWithFrame:CGRectMake(0, 10, 306, 20)];
    upView.centerX = self.view.width/2;
    upView.layer.cornerRadius = 8.0f;
    upView.tag = 100000;
    upView.clipsToBounds = YES;
    upView.layer.borderColor = [UIColor colorWithRed:149.0/255.0 green:149.0/255.0 blue:149.0/255.0 alpha:1.0f].CGColor;
    upView.layer.borderWidth = 1;
    upView.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0f];
    [scroll addSubview:upView];
    
    NSString* titleForUpView[NUMOFUPVIEW]={@"头像",@"名字",@"性别",@"地区",@"职业",@"职位",@"个性签名",@"修改密码"};
    int heightOnUpView = 0;
    for (int i=0; i<NUMOFUPVIEW; i++) {
        UIView* v = [[UIView alloc]initWithFrame:CGRectMake(0, heightOnUpView, upView.width, 0)];
        if (i==0) {
            v.height=60;
        } else {
            v.height=40;
        }
        v.tag = 10000+i;
        v.backgroundColor = [UIColor clearColor];
        if (i==NUMOFUPVIEW-1) {
            UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gotoChangePWD:)];
            [v addGestureRecognizer:tap];
        }
        [upView addSubview:v];
        
        UILabel* l = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 100, 25)];
        l.centerY = v.height/2;
        l.backgroundColor = [UIColor clearColor];
        l.textColor = [UIColor blackColor];
        l.textAlignment = NSTextAlignmentLeft;
        l.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:14];
        l.text = titleForUpView[i];
        [v addSubview:l];
        
        if (i==0) {
            imgHead = createPortraitView(44);
            imgHead.right = v.width-30;
            imgHead.centerY = v.height/2;
            imgHead.userInteractionEnabled = YES;
            imgHead.image = getBundleImage(@"defaultHead.png");
            imgHead.contentMode = UIViewContentModeScaleAspectFill;
            
            if (![myUser.userHeadURL isKindOfClass:[NSNull class]]&&myUser.userHeadURL.length>0) {
                NSURL *url = [NSURL URLWithString:getPicNameALL(myUser.userHeadURL)];
                UIImage *img = [_recvUserHeadOnSetting imageForKey:[myUser.userHeadURL lastPathComponent]                                       url:url queueIfNeeded:YES];
                if (img) {
                    imgHead.image = img;
                }
            }
            UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onChangeHead:)];
            [imgHead addGestureRecognizer:tap];
            [v addSubview:imgHead];
        } else if (i==1) {
            nameTextField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 200, 25)];
            nameTextField.right = imgHead.right;
            nameTextField.centerY = v.height/2;
            nameTextField.backgroundColor = [UIColor clearColor];
            nameTextField.borderStyle = UITextBorderStyleNone;
            nameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            nameTextField.textAlignment = NSTextAlignmentRight;
            nameTextField.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:14];
            nameTextField.text = myUser.userName;
            nameTextField.textColor = [UIColor colorWithRed:137.0/255.0 green:137.0/255.0 blue:137.0/255.0 alpha:1.0f];
            nameTextField.returnKeyType = UIReturnKeyDone;
            nameTextField.delegate = self;
            [v addSubview:nameTextField];
        } else if (i==2) {
            sexLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 25)];
            sexLabel.right = imgHead.right;
            sexLabel.centerY = v.height/2;
            sexLabel.backgroundColor = [UIColor clearColor];
            sexLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:14];
            sexLabel.textAlignment = NSTextAlignmentRight;
            sexLabel.userInteractionEnabled = YES;
            NSString* strSex[3]={@"未知",@"男",@"女"};
            sexLabel.text = strSex[myUser.sex];
            sexLabel.textColor = [UIColor colorWithRed:137.0/255.0 green:137.0/255.0 blue:137.0/255.0 alpha:1.0f];
            UITapGestureRecognizer *sexTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onChangeSex:)];
            [sexLabel addGestureRecognizer:sexTap];
            [v addSubview:sexLabel];
        } else if (i==3) {
            UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onChangeCity:)];
            [v addGestureRecognizer:tap];
            cityLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 25)];
            cityLabel.right = imgHead.right;
            cityLabel.centerY = v.height/2;
            cityLabel.backgroundColor = [UIColor clearColor];
            cityLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:14];
            cityLabel.textAlignment = NSTextAlignmentRight;
            cityLabel.userInteractionEnabled = YES;
            cityLabel.text = myUser.hometown;
            cityLabel.textColor = [UIColor colorWithRed:137.0/255.0 green:137.0/255.0 blue:137.0/255.0 alpha:1.0f];
            [v addSubview:cityLabel];
        } else if (i==4) {
            UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onChangeJob:)];
            [v addGestureRecognizer:tap];
            jobLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 25)];
            jobLabel.right = imgHead.right;
            jobLabel.centerY = v.height/2;
            jobLabel.backgroundColor = [UIColor clearColor];
            jobLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:14];
            jobLabel.textAlignment = NSTextAlignmentRight;
            jobLabel.userInteractionEnabled = YES;
            jobLabel.text = myUser.location;
            jobLabel.textColor = [UIColor colorWithRed:137.0/255.0 green:137.0/255.0 blue:137.0/255.0 alpha:1.0f];
            [v addSubview:jobLabel];
        } else if (i==5) {
            posTextField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 200, 25)];
            posTextField.right = imgHead.right;
            posTextField.centerY = v.height/2;
            posTextField.backgroundColor = [UIColor clearColor];
            posTextField.borderStyle = UITextBorderStyleNone;
            posTextField.returnKeyType = UIReturnKeyDone;
            posTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            posTextField.textAlignment = NSTextAlignmentRight;
            posTextField.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:14];
            posTextField.textColor = [UIColor colorWithRed:137.0/255.0 green:137.0/255.0 blue:137.0/255.0 alpha:1.0f];
            posTextField.delegate = self;
            posTextField.text = myUser.pos;
            [v addSubview:posTextField];
        } else if (i==6) {
            UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onGotoMask:)];
            [v addGestureRecognizer:tap];
            maskLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 25)];
            maskLabel.right = imgHead.right;
            maskLabel.backgroundColor = [UIColor clearColor];
            maskLabel.textAlignment = NSTextAlignmentRight;
            maskLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:14];
            maskLabel.textColor = [UIColor colorWithRed:137.0/255.0 green:137.0/255.0 blue:137.0/255.0 alpha:1.0f];
            maskLabel.text = myUser.explain;
            maskLabel.numberOfLines = 0;
            [v addSubview:maskLabel];
            CGSize size = CGSizeMake(maskLabel.width,2000);
            CGSize labelsize = [maskLabel.text sizeWithFont:maskLabel.font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
            maskLabel.frame = CGRectMake(maskLabel.left, maskLabel.top, maskLabel.width, labelsize.height);
            v.height = maskLabel.height+10;
            if (v.height < 40) {
                v.height = 40;
            }
            maskLabel.centerY = v.height/2;
            l.centerY = v.height/2;
        }
        
        UIImageView* arrow = getImageViewByImageName(@"arrow.png");
        arrow.right = v.width-10;
        arrow.centerY = v.height/2;
        [v addSubview:arrow];
        
        heightOnUpView = v.bottom;
        
        if (i!=NUMOFUPVIEW-1) {
            UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0, v.bottom, v.width, 1)];
            line.backgroundColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0f];
            [upView addSubview:line];
            
            heightOnUpView = line.bottom;
        }
    }
    upView.height = heightOnUpView;
    
    
    UIView *middleView = [[UIView alloc]initWithFrame:CGRectMake(0, 10, 306, 20)];
    middleView.top = upView.bottom+15;
    middleView.centerX = self.view.width/2;
    middleView.layer.cornerRadius = 8.0f;
    middleView.tag = 100001;
    middleView.clipsToBounds = YES;
    middleView.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0f];
    middleView.layer.borderColor = [UIColor colorWithRed:149.0/255.0 green:149.0/255.0 blue:149.0/255.0 alpha:1.0f].CGColor;
    middleView.layer.borderWidth = 1;
    [scroll addSubview:middleView];
    
    NSString* titleForMiddleView[NUMOFMIDDLEVIEW]={@"客服热线  :  400-997-5277"};
    int heightOnDownView = 0;
    
    for (int i=0; i<NUMOFMIDDLEVIEW; i++) {
        UIView* v = [[UIView alloc]initWithFrame:CGRectMake(0, heightOnDownView, middleView.width, 40)];
        v.backgroundColor = [UIColor clearColor];
        [middleView addSubview:v];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dial)];
        [v addGestureRecognizer:tap];
        
        UILabel* l = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 200, 25)];
        l.centerY = v.height/2;
        l.backgroundColor = [UIColor clearColor];
        l.textColor = [UIColor blackColor];
        l.textAlignment = NSTextAlignmentLeft;
        l.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:14];
        l.text = titleForMiddleView[i];
        [v addSubview:l];
        
        UIImageView* arrow = getImageViewByImageName(@"arrow.png");
        arrow.right = v.width-10;
        arrow.centerY = v.height/2;
        [v addSubview:arrow];
        
        heightOnDownView = v.bottom;
        
        if (i!=NUMOFMIDDLEVIEW-1) {
            UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0, v.bottom, v.width, 1)];
            line.backgroundColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0f];
            [downView addSubview:line];
            
            heightOnDownView = line.bottom;
        }
    }
    middleView.height = heightOnDownView;

    
    
    downView = [[UIView alloc]initWithFrame:CGRectMake(0, 10, 306, 20)];
    downView.top = middleView.bottom+15;
    downView.centerX = self.view.width/2;
    downView.layer.cornerRadius = 8.0f;
    downView.tag = 100001;
    downView.clipsToBounds = YES;
    downView.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0f];
    downView.layer.borderColor = [UIColor colorWithRed:149.0/255.0 green:149.0/255.0 blue:149.0/255.0 alpha:1.0f].CGColor;
    downView.layer.borderWidth = 1;
    [scroll addSubview:downView];
    
    NSString* titleForDownView[NUMOFDOWNVIEW]={@"关于大业堂云平台",@"版本更新"};
    heightOnDownView = 0;
    
    for (int i=0; i<NUMOFDOWNVIEW; i++) {
        UIView* v = [[UIView alloc]initWithFrame:CGRectMake(0, heightOnDownView, downView.width, 40)];
        v.backgroundColor = [UIColor clearColor];
        [downView addSubview:v];
        
        if (i==0) {
            UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoAbout)];
            [v addGestureRecognizer:tap];
        } else if (i==1) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(version)];
            [v addGestureRecognizer:tap];
        }
        
        UILabel* l = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 200, 25)];
        l.centerY = v.height/2;
        l.backgroundColor = [UIColor clearColor];
        l.textColor = [UIColor blackColor];
        l.textAlignment = NSTextAlignmentLeft;
        l.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:14];
        l.text = titleForDownView[i];
        [v addSubview:l];
        
        UIImageView* arrow = getImageViewByImageName(@"arrow.png");
        arrow.right = v.width-10;
        arrow.centerY = v.height/2;
        [v addSubview:arrow];
        
        heightOnDownView = v.bottom;
        
        if (i!=NUMOFDOWNVIEW-1) {
            UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0, v.bottom, v.width, 1)];
            line.backgroundColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0f];
            [downView addSubview:line];
        
            heightOnDownView = line.bottom;
        }
    }
    downView.height = heightOnDownView;
    
    UIButton* btLogOut = getButtonByImageName(@"btLogOut.png");
    btLogOut.centerX = self.view.width/2;
    btLogOut.top = downView.bottom+15;
    btLogOut.tag = 100002;
    [btLogOut addTarget:self action:@selector(onLogOut) forControlEvents:UIControlEventTouchUpInside];
    [scroll addSubview:btLogOut];
    
    scroll.contentSize = CGSizeMake(scroll.width, btLogOut.bottom+30);    
}

- (void)dial{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://4009975277"]];
}

- (void)onLogOut {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def removeObjectForKey:@"userid"];
    [def synchronize];
    [WaitTooles showHUD:@"正在登出...."];
    [[WebServiceManager sharedManager] onLogOut:[[DataManager sharedManager] getUser].userid completion:^(NSDictionary* dic){
        [WaitTooles removeHUD];
        if ([[dic objectForKey:@"success"]intValue]==1) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LogOut" object:nil];
            [MsgObject closeSql];
            [GroupObject closeSql];
            [ChatObject closeSql];
            [UserObject closeSql];
            [GroupPicData closeSql];
        } 
    }];
}

- (void)recvUserHeadOnSetting:(NSNotification*)sender {
    NSDictionary *dict = [sender userInfo];
    UIImage *img = [dict objectForKey:@"image"];    
    imgHead.image = img;
    myUser.headImage = img;
    [[DataManager sharedManager] setUser:myUser];
}

#pragma mark uitextField的代理
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == posTextField) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3f];
        scroll.bottom -= 120;
        [UIView commitAnimations];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField == posTextField) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3f];
        scroll.bottom += 120;
        [UIView commitAnimations];
    }
    
    NSString *val = nil;
    if (textField==nameTextField) {
        val = myUser.userName;
    } else if(textField == posTextField){
        val  = myUser.pos;
    }
    
    if ([textField.text isEqual:@""] || textField.text.length==0 || [textField.text isEqualToString:val]) {
        textField.text = val;
        return YES;
    }
    
    if (textField == nameTextField) {
        [WaitTooles showHUD:@"正在更新名字..."];
        [[WebServiceManager sharedManager] updateName:[[DataManager sharedManager]getUser].userid withName:nameTextField.text encodeStr:[[DataManager sharedManager]getUser].encodeStr completion:^(NSDictionary* dic) {
            [WaitTooles removeHUD];
            myUser.userName = nameTextField.text;
            [[DataManager sharedManager] setUser:myUser];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"结果" message:[dic objectForKey:@"msg"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }];
    } else if (textField == posTextField) {
        [WaitTooles showHUD:@"正在更新职位..."];
        [[WebServiceManager sharedManager] updatePos:[[DataManager sharedManager]getUser].userid pos:posTextField.text encodeStr:[[DataManager sharedManager]getUser].encodeStr completion:^(NSDictionary* dic) {
            [WaitTooles removeHUD];
            myUser.pos = posTextField.text;
            [[DataManager sharedManager] setUser:myUser];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"结果" message:[dic objectForKey:@"msg"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }];
    }
    return YES;
}

- (void)onChangeHead:(UITapGestureRecognizer*)sender {
    [nameTextField resignFirstResponder];
    picActionSheet = [[UIActionSheet alloc]
                      initWithTitle:@"选择照片"
                      delegate:self
                      cancelButtonTitle:@"取消"
                      destructiveButtonTitle:nil
                      otherButtonTitles:@"拍照", @"从手机相册选择",nil];
    picActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [picActionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)onChangeSex:(UITapGestureRecognizer*)sender {
    [nameTextField resignFirstResponder];
    sexActionSheet = [[UIActionSheet alloc]
                      initWithTitle:@"修改性别"
                      delegate:self
                      cancelButtonTitle:@"取消"
                      destructiveButtonTitle:nil
                      otherButtonTitles:@"男", @"女",nil];
    sexActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [sexActionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)dismissKeyboard{
    [nameTextField resignFirstResponder];
    [posTextField resignFirstResponder];
}

- (void)onChangeCity:(UITapGestureRecognizer*)sender {
    [self dismissKeyboard];
    ProvinceViewController* v = [[ProvinceViewController alloc]init];
    [self.navigationController pushViewController:v animated:YES];}

- (void)onChangeJob:(UITapGestureRecognizer*)sender {    
    [self dismissKeyboard];
    MainJobViewController* v = [[MainJobViewController alloc]init];
    [self.navigationController pushViewController:v animated:YES];
}

- (void)onGotoMask:(UITapGestureRecognizer*)sender {
    [self dismissKeyboard];
    MaskViewController* v = [[MaskViewController alloc]init];
    [self.navigationController pushViewController:v animated:YES];
}

#pragma mark UIActionSheet的代理
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet == picActionSheet) {
        if (buttonIndex==2) {
            return ;
        }
        if (buttonIndex == 0) {
            //[self addCameraEvent];
            UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
            if (![UIImagePickerController isSourceTypeAvailable: sourceType]) {
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
            CameraViewController *picker = [[CameraViewController alloc] init];
            picker.cameraDelegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = sourceType;
            [self.navigationController presentModalViewController:picker animated:YES];
        }else if (buttonIndex == 1) {
            //[self addPicEvent];
            UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            if (![UIImagePickerController isSourceTypeAvailable: sourceType]) {
                sourceType = UIImagePickerControllerSourceTypeCamera;
            }
            CameraViewController *picker = [[CameraViewController alloc] init];
            picker.cameraDelegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = sourceType;
            [self.navigationController presentModalViewController:picker animated:YES];
        }
    } else if (actionSheet == sexActionSheet) {
        if (buttonIndex==2) {
            return ;
        }
        [WaitTooles showHUD:@"正在更新性别....."];
        [[WebServiceManager sharedManager] updateSex:myUser.userid withSex:buttonIndex+1 encodeStr:[[DataManager sharedManager]getUser].encodeStr completion:^(NSDictionary* dic) {
            [WaitTooles removeHUD];
            if (buttonIndex == 0) {
                sexLabel.text = @"男";
            } else {
                sexLabel.text = @"女";
            }
            myUser.sex = buttonIndex+1;
            [[DataManager sharedManager] setUser:myUser];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"结果" message:[dic objectForKey:@"msg"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }];
    }
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
    [self updateHeadImg];
}

#pragma mark 照片库的操作
-(void)addPicEvent {
    UIImagePickerControllerSourceType sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        sourceType=UIImagePickerControllerSourceTypeCamera;
    }
    UIImagePickerController * picker = [[UIImagePickerController alloc]init];
    picker.delegate=self;
    picker.allowsEditing=NO;
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
    picker.allowsEditing=YES;
    picker.sourceType=sourceType;
    [self.navigationController presentViewController:picker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage * image=[info objectForKey:UIImagePickerControllerOriginalImage];
    
    UIImage *imgThumb = [image imageScaledToFitSize:CGSizeMake(256, 256/image.size.width*image.size.height)];
    
    [self performSelector:@selector(saveImage:) withObject:imgThumb afterDelay:0.5];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)saveImage:(UIImage*)image {
    photo_ = image;
    [self updateHeadImg];
}

- (void)updateHeadImg {
    [WaitTooles showHUD:@"正在更新头像....."];
    NSData *dataObj = UIImageJPEGRepresentation(photo_, 0.7);
    [[WebServiceManager sharedManager] updateHead:myUser.userid withPic:dataObj encodeStr:[[DataManager sharedManager]getUser].encodeStr completion:^(NSDictionary* dic) {
        [WaitTooles removeHUD];
        if ([[dic objectForKey:@"success"]intValue]==1) {
            imgHead.image = photo_;
            myUser.headImage = photo_;
            [[DataManager sharedManager] setUser:myUser];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"结果" message:[dic objectForKey:@"msg"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }];
}

- (void)gotoChangePWD:(UITapGestureRecognizer*)sender {
    [self dismissKeyboard];
    ChangePWDViewController* v = [[ChangePWDViewController alloc]init];
    [self.navigationController pushViewController:v animated:YES];
}

- (void)updateArea:(NSNotification*)sender {
    cityLabel.text = (NSString*)sender.object;
    myUser.hometown = cityLabel.text;
    [[DataManager sharedManager] setUser:myUser];
}

- (void)updateJob:(NSNotification*)sender {
    jobLabel.text = (NSString*)sender.object;
    myUser.location = jobLabel.text;
    [[DataManager sharedManager] setUser:myUser];
}

- (void)updateMask:(NSNotification*)sender {
    maskLabel.text = (NSString*)sender.object;
    myUser.explain = maskLabel.text;
    [[DataManager sharedManager] setUser:myUser];
    [self createScrollView];
}

- (void)gotoAbout {
    AboutViewController* v = [[AboutViewController alloc]init];    
    v.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:v animated:YES];
}

- (void)version{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"当前版本号" message:VERSION delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}
@end
