//
//  MainViewController.m
//  DYT
//
//  Created by zhaoliang.chen on 13-6-4.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "MainViewController.h"
#import "MsgViewController.h"
#import "AdsGroupViewController.h"
#import "AnnViewController.h"
#import "SettingViewController.h"
#import "ChatViewController.h"
#import "NewMsgViewController.h"
#import "NewAdsGroupViewController.h"
#import "NewSettingViewController.h"
#import "PictureViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

@synthesize tabbarController;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoChat:) name:@"gotoChat" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LogOut:) name:@"LogOut" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoChatByGroupid:) name:@"gotoChatByGroupid" object:nil];        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNewMsg:) name:@"updateNewMsg" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNewAnn:) name:@"updateNewAnn" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backToRoot:) name:@"backToRoot" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoGroupPicBigImage:) name:@"gotoGroupPicBigImage" object:nil];
        isAutoLogin = NO;
    }
    return self;
}

- (id)initWithUserid:(int)userid {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        m_nUserid = userid;
        isAutoLogin = YES;
    }
    return self;
}

- (void)autoLogin {    
    //[WaitTooles showHUD:@"自动登陆中..."];
    if ((([Reachability reachabilityForInternetConnection].currentReachabilityStatus == NotReachable) &&
         ([Reachability reachabilityForLocalWiFi].currentReachabilityStatus == NotReachable))) {
        if (backImg) {
            [backImg removeFromSuperview];
            backImg = nil;
        }
        return ;
    }
    [[WebServiceManager sharedManager] getUserInfo:m_nUserid encodeStr:[[DataManager sharedManager] getUser].encodeStr completion:^(NSDictionary* dic1) {
        //[WaitTooles removeHUD];
        if (backImg) {
            [backImg removeFromSuperview];
            backImg = nil;
        }
        if ([[dic1 objectForKey:@"success"]intValue]==1) {
            UserObject* user = [[DataManager sharedManager]getUser];
            NSDictionary* dic1cc = [dic1 objectForKey:@"obj"];
            user.userName = [dic1cc objectForKey:@"name"];
            user.userHeadURL = [dic1cc objectForKey:@"thumb"];
            if ([user.userHeadURL isKindOfClass:[NSNull class]] || [user.userHeadURL rangeOfString:@"null" options:NSCaseInsensitiveSearch].length>0) {
                user.userHeadURL = @"";
            }
            user.userHeadLargeURL = [dic1cc objectForKey:@"pic"];
            if ([user.userHeadLargeURL isKindOfClass:[NSNull class]] || [user.userHeadLargeURL rangeOfString:@"null" options:NSCaseInsensitiveSearch].length>0) {
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

            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            NSString *str = [def objectForKey:[NSString stringWithFormat:@"%d_lastGetMsgTime",user.userid]];
            if ((str.length==0&&[str isKindOfClass:[NSString class]]) || str==nil) {
#ifdef DEBUG
                NSDate* date = [NSDate dateWithMinutesBeforeNow:5];
#else
                NSDate* date = [NSDate dateWithMinutesBeforeNow:0];
#endif
                NSString* strDate = formatDateToStringALL(date);
                [def setObject:strDate forKey:[NSString stringWithFormat:@"%d_lastGetMsgTime",user.userid]];
            }
            [self createTabbar];
        } else {
            if ([[dic1 objectForKey:@"returnCode"]intValue]==101) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息" message:@"你的账号已经在别处登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect rc = [UIScreen mainScreen].bounds;
    backImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, rc.size.width, rc.size.height)];
    if (IS_IPHONE_5) {
        backImg.image = getBundleImage(@"Default-568h@2x.png");
    } else {
        backImg.image = getBundleImage(@"Default@2x.png");
    }
    [[UIApplication sharedApplication].keyWindow addSubview:backImg];
    if (isAutoLogin) {
        if (([Reachability reachabilityForInternetConnection].currentReachabilityStatus == NotReachable) &&
            ([Reachability reachabilityForLocalWiFi].currentReachabilityStatus == NotReachable)) {
            UserObject* user = [UserObject findByID:m_nUserid];
            [[DataManager sharedManager] setUser:user];
            if (backImg) {
                [backImg removeFromSuperview];
                backImg = nil;
            }
            [self createTabbar];
        } else {
            [self autoLogin];
        }
    } else {
        [self createTabbar];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)createTabbar {
    // Do any additional setup after loading the view.
    self.tabbarController = [[UITabBarController alloc]init];
    //消息
    msg = [[NewMsgViewController alloc] init];
    UINavigationController *navMsg = [[UINavigationController alloc] initWithRootViewController:msg];
    navMsg.view.tag = 0;
    
    //通讯录
    AdsGroupViewController *ads = [[AdsGroupViewController alloc] init];
    UINavigationController *navAds = [[UINavigationController alloc] initWithRootViewController:ads];
    navAds.view.tag = 1;
    
    //公告
    ann = [[AnnViewController alloc] init];
    UINavigationController *navAnn = [[UINavigationController alloc] initWithRootViewController:ann];
    navAnn.view.tag = 2;
    
    //设置
    SettingViewController *set = [[SettingViewController alloc] init];
    UINavigationController *navSet = [[UINavigationController alloc] initWithRootViewController:set];
    navSet.view.tag = 3;
    
    NSArray *arr = [NSArray arrayWithObjects:navMsg, navAds, navAnn, navSet, nil];
    [self.tabbarController setViewControllers:arr];
    self.tabbarController.delegate = self;
    
    [self.view addSubview:self.tabbarController.view];
    
    UITabBar *tabBar = self.tabbarController.tabBar;
    if ([tabBar respondsToSelector:@selector(setBackgroundImage:)]){
        [tabBar setBackgroundImage:[UIImage imageNamed:@"tabBarBG.png"]];
    }
    else{
        CGRect frame = CGRectMake(0, 0, 480, 49);
        UIView *tabbg_view = [[UIView alloc] initWithFrame:frame];
        UIImage *tabbag_image = [UIImage imageNamed:@"tabBarBG.png"];
        UIColor *tabbg_color = [[UIColor alloc] initWithPatternImage:tabbag_image];
        tabbg_view.backgroundColor = tabbg_color;
        [tabBar insertSubview:tabbg_view atIndex:0];
    }
    
    self.tabbarController.view.top = -20;
    UIColor *color = [UIColor colorWithRed:206 green:1 blue:15 alpha:1.0];
    [[self.tabbarController tabBar]setSelectedImageTintColor:color];
    [[self.tabbarController tabBar]setSelectionIndicatorImage:[UIImage imageNamed:@"tabback.png"]];
    
    tabRedPoint = [[UIView alloc]initWithFrame:CGRectMake(self.tabbarController.view.width/2+55, 8, 10, 10)];
    tabRedPoint.backgroundColor = [UIColor redColor];
    tabRedPoint.layer.cornerRadius = tabRedPoint.width/2;
    tabRedPoint.layer.borderColor = [UIColor whiteColor].CGColor;
    tabRedPoint.layer.borderWidth = 1.0f;
    [self.tabbarController.tabBar addSubview:tabRedPoint];
    tabRedPoint.hidden = YES;
}

- (void)gotoChat:(NSNotification*)sender {
    NSArray* array = (NSArray*)sender.object;
    ChatViewController* v = [[ChatViewController alloc]initWithData:array];
    [self.navigationController pushViewController:v animated:YES];
}

- (void)gotoChatByGroupid:(NSNotification*)sender {
    int groupid = [(NSNumber*)sender.object intValue];
    ChatViewController* v = [[ChatViewController alloc]initWithGroupid:groupid];
    [self.navigationController pushViewController:v animated:YES];
}

- (void)LogOut:(NSNotification*)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    if (tabBarController.selectedIndex == 2) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateNewAnn" object:[NSNumber numberWithBool:NO]];
    }
}

- (void)updateNewMsg:(NSNotification*)sender {
    int num = [(NSNumber*)sender.object intValue];
    if (num == 0) {
        msg.tabBarItem.badgeValue = nil;
    } else {
        msg.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",num];
    }
}

- (void)updateNewAnn:(NSNotification*)sender {
    BOOL is = [(NSNumber*)sender.object boolValue];
    if (is) {
        [[WebServiceManager sharedManager] getNoticeFirst:[[DataManager sharedManager]getUser].encodeStr completion:^(NSDictionary* dic1) {
            int success = [[dic1 objectForKey:@"success"]intValue];
            if (success == 1) {
                NSDictionary* dic2 = [dic1 objectForKey:@"obj"];
                NSArray *array = [dic2 objectForKey:@"news"];
                if ([array isKindOfClass:[NSArray class]] && array.count>0) {
                    NSDictionary *dic3 = [array objectAtIndex:0];
                    AnnObject* one = [AnnObject getOneAnnObject:dic3];
                    AnnObject* two = [AnnObject getFirstAnn];
                    if (two == nil) {
                        tabRedPoint.hidden = NO;
                    } else {
                        if (two.annID < one.annID) {
                            tabRedPoint.hidden = NO;
                        } else {
                            tabRedPoint.hidden = YES;
                        }
                    }
                }
            } else {
                if ([[dic1 objectForKey:@"returnCode"]intValue]==101) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息" message:@"你的账号已经在别处登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alert show];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"backToRoot" object:nil];
                }
            }
        }];
    } else {
        tabRedPoint.hidden = YES;
        //ann.tabBarItem.badgeValue = nil;
    }
}

- (void)backToRoot:(NSNotification*)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)gotoGroupPicBigImage:(NSNotification*)sender {
    NSDictionary* dic = (NSDictionary*)sender.object;
    PictureViewController* v = [[PictureViewController alloc]initWithGroupPicData:[dic objectForKey:@"array"] whitIndex:[[dic objectForKey:@"tag"]intValue]];
    [self.navigationController pushViewController:v animated:YES];
}

- (BOOL)shouldAutorotate{
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
    //    return UIInterfaceOrientationMaskAll;
}

@end
