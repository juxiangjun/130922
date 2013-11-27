//
//  NewSettingViewController.m
//  DYT
//
//  Created by zhaoliang.chen on 13-7-3.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "NewSettingViewController.h"
#import "SettingCell.h"
#import "config.h"

@interface NewSettingViewController ()

@end

@implementation NewSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"设置" image:[UIImage imageNamed:@"btSet.png"] tag:3];
        self.tabBarItem = tabBarItem;
        
        titleArrayOne = [NSArray arrayWithObjects:@"头像",@"名字",@"性别",@"地区",@"职业",@"职位",@"个性签名",@"修改密码", nil];
        titleArrayTwo = [NSArray arrayWithObjects:@"关于大业堂云平台",@"版本更新", nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.myUser = [[DataManager sharedManager] getUser];
    [self.navigationController.navigationBar setBackgroundImage:getBundleImage(@"navBG.png") forBarMetrics:UIBarMetricsDefault];
    self.view.backgroundColor = [UIColor colorWithPatternImage:getBundleImage(@"loginBG.png")];
    self.title = @"设置";
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-self.tabBarController.tabBar.height-self.navigationController.navigationBar.height)];
    mainScrollView.backgroundColor = [UIColor clearColor];
    mainScrollView.userInteractionEnabled = YES;
    [self.view addSubview:mainScrollView];
    
    settingTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, mainScrollView.width, mainScrollView.height) style:UITableViewStyleGrouped];
    settingTableView.delegate = self;
    settingTableView.dataSource = self;
    settingTableView.backgroundColor = [UIColor whiteColor];
    settingTableView.backgroundView = nil;
    settingTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    settingTableView.separatorColor = [UIColor colorWithRed:190.0/255.0 green:190.0/255.0 blue:190.0/255.0 alpha:1.0f];
    [mainScrollView addSubview:settingTableView];
    
    myUser = [[DataManager sharedManager] getUser];    
    contentArray = [NSArray arrayWithObjects:myUser.userHeadURL, myUser.userName, myUser.sex==1?@"男":@"女", myUser.hometown, myUser.location, myUser.pos, myUser.explain, @"", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TableView的代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return titleArrayOne.count;
    } else if (section == 1) {
        return titleArrayTwo.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *myCell = @"Cell";
    SettingCell *cell = (SettingCell*)[tableView dequeueReusableCellWithIdentifier:myCell];
    if (cell == nil) {
        cell = [[SettingCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myCell];
    }
    
    if (indexPath.section==0) {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (indexPath.row==0) {
            cell.type=1;
        } else if (indexPath.row==1 || indexPath.row==5 || indexPath.row==6 ) {
            cell.type=2;
        } else {
            cell.type=3;
        }
        if (contentArray.count > 0) {
            [cell setCell:[titleArrayOne objectAtIndex:indexPath.row] withContent:[contentArray objectAtIndex:indexPath.row]];
        } else {
            [cell setCell:[titleArrayOne objectAtIndex:indexPath.row] withContent:@""];
        }
    } else if (indexPath.section==1) {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell setCell:[titleArrayTwo objectAtIndex:indexPath.row] withContent:@""];
    } else {
        [cell setBackgroundColor:[UIColor colorWithPatternImage:getBundleImage(@"btLogOut.png")]];
    }
    
    return cell;
}

-(NSIndexPath*)tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath {
	return indexPath;
}

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 60;
    } else {
        return 40;
    }
}

//选中Cell响应事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==0) {

    } else if (indexPath.section==1) {
    } else {
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
}

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
    picker.allowsEditing=YES;
    picker.sourceType=sourceType;
    [self.navigationController presentViewController:picker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    //UIImage * image=[info objectForKey:UIImagePickerControllerEditedImage];
    //[self sendGroupPic:image];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


@end
