//
//  SubJobViewController.m
//  DYT
//
//  Created by zhaoliang.chen on 13-7-2.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "SubJobViewController.h"

@interface SubJobViewController ()

@end

@implementation SubJobViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithArray:(NSArray*)array withMainJob:(NSString*)MainJob {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        subJobArray = array;
        mainJobName = MainJob;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.navigationController.navigationBar setBackgroundImage:getBundleImage(@"navBG.png") forBarMetrics:UIBarMetricsDefault];
    self.view.backgroundColor = [UIColor colorWithRed:243.0/255.0 green:243.0/255.0 blue:243.0/255.0 alpha:1.0f];
    self.title = @"选择职业";
    
    UIButton *button1 = getButtonByImageName(@"btBack.png");
    [button1 addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn1 = [[UIBarButtonItem alloc] initWithCustomView:button1];
    self.navigationItem.leftBarButtonItem = btn1;
    
    subJobTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-self.navigationController.navigationBar.height-self.tabBarController.tabBar.height) style:UITableViewStyleGrouped];
    subJobTable.centerX = self.view.width/2;
    subJobTable.delegate = self;
    subJobTable.dataSource = self;
    subJobTable.backgroundColor = [UIColor whiteColor];
    subJobTable.backgroundView = nil;
    subJobTable.clipsToBounds = YES;
    subJobTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    subJobTable.separatorColor = [UIColor colorWithRed:190.0/255.0 green:190.0/255.0 blue:190.0/255.0 alpha:1.0f];
    [self.view addSubview:subJobTable];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark TableView的代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return subJobArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *myCell = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myCell];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.textLabel.text = [subJobArray objectAtIndex:indexPath.row];
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

-(NSIndexPath*)tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath {
	return indexPath;
}

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    return 40;
}

//选中Cell响应事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.navigationController popToRootViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateJob" object:[NSString stringWithFormat:@"%@",[subJobArray objectAtIndex:indexPath.row]]];
    
    [[WebServiceManager sharedManager] updateJob:[[DataManager sharedManager]getUser].userid Job1:mainJobName Job2:[subJobArray objectAtIndex:indexPath.row] encodeStr:[[DataManager sharedManager]getUser].encodeStr completion:^(NSDictionary *dic) {
        if ([[dic objectForKey:@"success"]intValue]==1) {

        }
    }];
}


@end
