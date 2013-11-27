//
//  GroupActViewController.m
//  DYT
//
//  Created by zhaoliang.chen on 13-6-25.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "GroupActViewController.h"
#import "GroupActCell.h"
#import "TKImageCache.h"
#import "UserDetailViewController.h"
#import "GroupActDetailViewController.h"

@interface GroupActViewController (){
    UIActivityIndicatorView * loading_;
}

@end

@implementation GroupActViewController

#define USERHEADONACT 1000

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        titleArray = [NSArray arrayWithObjects:@"群公告", @"活动时间", @"活动地点", @"活动内容", nil];
        arrayUser = [NSMutableArray new];
        
        _recvUserOnAct = [[TKImageCache alloc] initWithCacheDirectoryName:@"activity"];
        _recvUserOnAct.notificationName = @"recvUserOnAction";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvUserOnAction:) name:@"recvUserOnAction" object:nil];
    }
    return self;
}

- (id)initWithGroup:(GroupObject*)group {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        groupObj = group;
        //contentArray = [NSArray arrayWithObjects:@"无群组活动", @"无群组活动", @"无群组活动", @"无群组活动", nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.navigationController.navigationBar setBackgroundImage:getBundleImage(@"navBG.png") forBarMetrics:UIBarMetricsDefault];
    self.view.backgroundColor = [UIColor colorWithPatternImage:getBundleImage(@"loginBG.png")];
    self.title = @"获取群活动";    
    
    UIButton *button1 = getButtonByImageName(@"btBack.png");
    [button1 addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn1 = [[UIBarButtonItem alloc] initWithCustomView:button1];
    self.navigationItem.leftBarButtonItem = btn1;

    mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 10, self.view.width, self.view.height-self.navigationController.navigationBar.height-self.tabBarController.tabBar.height-10)];
    mainScrollView.userInteractionEnabled = YES;
    mainScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:mainScrollView];
    
    tableAct = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, mainScrollView.width-20, 160) style:UITableViewStylePlain];
    tableAct.centerX = self.view.width/2;
    tableAct.layer.borderWidth = 1;
    tableAct.layer.borderColor = [UIColor colorWithRed:149.0/255.0 green:149.0/255.0 blue:149.0/255.0 alpha:1.0f].CGColor;
    tableAct.layer.cornerRadius = 6.0f;
    tableAct.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableAct.separatorColor = [UIColor colorWithRed:149.0/255.0 green:149.0/255.0 blue:149.0/255.0 alpha:1.0f];
    tableAct.delegate = self;
    tableAct.dataSource = self;
    tableAct.bounces = NO;
    [mainScrollView addSubview:tableAct];
    
    lNumber = [[UILabel alloc]initWithFrame:CGRectMake(tableAct.left, tableAct.bottom+20, 180, 25)];
    lNumber.backgroundColor = [UIColor clearColor];
    lNumber.textAlignment = NSTextAlignmentLeft;
    lNumber.textColor = [UIColor colorWithRed:149.0/255.0 green:149.0/255.0 blue:149.0/255.0 alpha:1.0f];
    lNumber.font = [UIFont systemFontOfSize:20];
    lNumber.text = [NSString stringWithFormat:@"参与人数:%d人",0];
    [mainScrollView addSubview:lNumber];
    
    userImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, lNumber.bottom+10, tableAct.width, 100)];
    userImg.centerX = tableAct.centerX;
    userImg.backgroundColor = [UIColor whiteColor];
    userImg.layer.cornerRadius = 6.0f;
    userImg.layer.borderWidth = 1;
    userImg.layer.borderColor = [UIColor colorWithRed:149.0/255.0 green:149.0/255.0 blue:149.0/255.0 alpha:1.0f].CGColor;
    userImg.layer.cornerRadius = 6.0f;
    userImg.userInteractionEnabled = YES;
    [mainScrollView addSubview:userImg];
    
    isJoin = NO;
    btJoin = getButtonByImageName(@"wantJoin.png");
    btJoin.centerX = userImg.centerX;
    btJoin.top = userImg.bottom+10;
    [btJoin addTarget:self action:@selector(onJoin) forControlEvents:UIControlEventTouchUpInside];
    [mainScrollView addSubview:btJoin];
    
    mainScrollView.contentSize = CGSizeMake(mainScrollView.width, btJoin.bottom+10);
    mainScrollView.hidden = YES;

    
}

- (void)viewDidAppear:(BOOL)animated{
    if (loading_==nil) {
        loading_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [loading_ startAnimating];
        [self.navigationController.navigationBar addSubview:loading_];
        loading_.center = CGPointMake(70, 22);
        [self getLastAction];
    }
}

- (void)getLastAction {
    //[WaitTooles showHUD:@"正在获取群活动.."];
    [[WebServiceManager sharedManager] getLastAction:groupObj.groupid encodeStr:[[DataManager sharedManager]getUser].encodeStr completion:^(NSDictionary* dic) {
        //[WaitTooles removeHUD];
        int success = [[dic objectForKey:@"success"]intValue];
        mainScrollView.hidden = NO;
        [loading_ removeFromSuperview];
        [loading_ stopAnimating];
        loading_ = nil;
        if (success == 1) {
            NSDictionary* dic2 = [dic objectForKey:@"obj"];
            if ([dic2 allKeys].count>0) {
                activeobj = [ActiveObject getActiveObject:dic2];
                contentArray = [NSArray arrayWithObjects:activeobj.eventTitle, activeobj.eventDate, activeobj.eventAddr, activeobj.eventContent, nil];
            } else {
                contentArray = [NSArray arrayWithObjects:@"无群组活动", @"无群组活动", @"无群组活动", @"无群组活动", nil];
                lNumber.hidden = YES;
                userImg.hidden = YES;
                btJoin.hidden = YES;
            }
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            [def setObject:[dic2 objectForKey:@"update_time"] forKey:[NSString stringWithFormat:@"%d_%d_actTime",[[DataManager sharedManager]getUser].userid,groupObj.groupid]];
            [def synchronize];
        } else {
            if ([[dic objectForKey:@"returnCode"]intValue]==101) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息" message:@"你的账号已经在别处登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"backToRoot" object:nil];
            }
        }
        [tableAct reloadData];
        [self getActMember];
        self.title = @"群组活动";
    }];    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onJoin {
    if (!isJoin) {
        [WaitTooles showHUD:@"正在提交参与信息..."];
        [[WebServiceManager sharedManager] joinAction:activeobj.eventID user:[[DataManager sharedManager]getUser].userid encodeStr:[[DataManager sharedManager]getUser].encodeStr completion:^(NSDictionary *dic) {
            [WaitTooles removeHUD];
            if ([[dic objectForKey:@"success"]intValue]==1) {
                [self getActMember];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"结果" message:@"参与成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            } else {
                if ([[dic objectForKey:@"returnCode"]intValue]==101) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息" message:@"你的账号已经在别处登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alert show];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"backToRoot" object:nil];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息" message:[dic objectForKey:@"msg"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alert show];
                }
            }
        }];
    } else {
        [WaitTooles showHUD:@"正在提交退出信息..."];
        [[WebServiceManager sharedManager] quitAction:activeobj.eventID user:[[DataManager sharedManager]getUser].userid encodeStr:[[DataManager sharedManager]getUser].encodeStr completion:^(NSDictionary *dic) {
            [WaitTooles removeHUD];
            if ([[dic objectForKey:@"success"]intValue]==1) {
                [self getActMember];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"结果" message:@"退出成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            } else {
                if ([[dic objectForKey:@"returnCode"]intValue]==101) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息" message:@"你的账号已经在别处登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alert show];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"backToRoot" object:nil];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息" message:[dic objectForKey:@"msg"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alert show];
                }
            }
        }];
    }
}

- (void)getActMember {
    [[WebServiceManager sharedManager] getActMember:activeobj.eventID encodeStr:[[DataManager sharedManager]getUser].encodeStr completion:^(NSDictionary* dic1) {
        if ([[dic1 objectForKey:@"success"]intValue]==1) {
            NSArray* array = [dic1 objectForKey:@"obj"];
            if ([array isKindOfClass:[NSArray class]]) {
                [arrayUser removeAllObjects];
                for (int i=0; i<array.count; i++) {
                    NSDictionary* dic2 = [array objectAtIndex:i];
                    UserObject* user = [[UserObject alloc]init];
                    user.userid = [[dic2 objectForKey:@"id"]intValue];
                    user.userName = [dic2 objectForKey:@"name"];
                    user.userHeadURL = [dic2 objectForKey:@"pic"];
                    user.sex = [[dic2 objectForKey:@"sex"]intValue];
                    [arrayUser addObject:user];
                }
                lNumber.text = [NSString stringWithFormat:@"参与人数:%d人",arrayUser.count];
                for (UIView *v in userImg.subviews) {
                    [v removeFromSuperview];
                }
                isJoin = NO;
                for (int i=0; i<arrayUser.count; i++) {
                    UserObject* one = [arrayUser objectAtIndex:i];
                    UIImageView* head = createPortraitView(44);
                    head.top = 15+80*(i/4);
                    head.left = 25+70*(i%4);
                    head.tag = USERHEADONACT+i;
                    head.image = getBundleImage(@"defaultHead.png");
                    if ([one.userHeadURL isKindOfClass:[NSString class]]&&one.userHeadURL.length>0) {
                        NSURL *url = [NSURL URLWithString:getPicNameALL(one.userHeadURL)];
                        UIImage *img = [_recvUserOnAct imageForKey:[one.userHeadURL lastPathComponent]                                          url:url queueIfNeeded:YES tag:head.tag];
                        if (img) {
                            head.image = img;
                        }
                    }
                    head.userInteractionEnabled = YES;
                    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapUserHead:)];
                    [head addGestureRecognizer:tap];
                    [userImg addSubview:head];
                    
                    UILabel* name = [[UILabel alloc]initWithFrame:CGRectMake(head.left, head.bottom+4, head.width, 15)];
                    name.backgroundColor = [UIColor clearColor];
                    name.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0f];
                    name.textAlignment = NSTextAlignmentCenter;
                    name.font = [UIFont systemFontOfSize:12];
                    name.text = one.userName;
                    [userImg addSubview:name];
                    
                    if (one.userid == [[DataManager sharedManager]getUser].userid) {
                        isJoin = YES;
                    }
                }
                userImg.height = 80*(ceil(arrayUser.count/4.0))+30;
                btJoin.top = userImg.bottom+10;
                if (isJoin) {
                    [btJoin setBackgroundImage:getBundleImage(@"quitactive.png") forState:UIControlStateNormal];
                } else {
                    [btJoin setBackgroundImage:getBundleImage(@"wantJoin.png") forState:UIControlStateNormal];                    
                }
                mainScrollView.contentSize = CGSizeMake(mainScrollView.width, btJoin.bottom+10);
            }
        } else {
            if ([[dic1 objectForKey:@"returnCode"]intValue]==101) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息" message:@"你的账号已经在别处登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"backToRoot" object:nil];
            }
        }
    }];
}

#pragma mark TableView的代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *UserCell = @"UserCell";
    
    GroupActCell *cell = (GroupActCell*)[tableView dequeueReusableCellWithIdentifier:UserCell];
    if (cell == nil) {
        cell = [[GroupActCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UserCell];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (contentArray != nil) {
        [cell setCell:[titleArray objectAtIndex:indexPath.row] withContent:[contentArray objectAtIndex:indexPath.row]];
    }
    
    return cell;
}

-(NSIndexPath*)tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath {
	return indexPath;
}

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row==3) {
        NSString* str = [contentArray objectAtIndex:indexPath.row];
        if (![str isEqualToString:@"无群组活动"]) {
            GroupActDetailViewController* v = [[GroupActDetailViewController alloc]initWithDetail:[contentArray objectAtIndex:indexPath.row]];
            [self.navigationController pushViewController:v animated:YES];
        }
    }
}

- (void)recvUserOnAction:(NSNotification*)sender {
    NSDictionary *dict = [sender userInfo];
    UIImage *img = [dict objectForKey:@"image"];
    int tag = [[dict objectForKey:@"tag"] intValue];
    UIImageView* imgView = (UIImageView*)[userImg viewWithTag:tag];
    imgView.image = img;
}

- (void)tapUserHead:(UITapGestureRecognizer*)sender {
    int tag = sender.view.tag-USERHEADONACT;
    UserObject* user = [arrayUser objectAtIndex:tag];
    UserDetailViewController* v = [[UserDetailViewController alloc]initWithUserid:user.userid];
    [self.navigationController pushViewController:v animated:YES];
}

@end
