//
//  MainJobViewController.m
//  DYT
//
//  Created by zhaoliang.chen on 13-7-2.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "MainJobViewController.h"
#import "SubJobViewController.h"

@interface MainJobViewController ()

@end

@implementation MainJobViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        mainJobArray = [NSMutableArray new];
        subJobArray = [NSMutableArray new];
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
    
    mainJobTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-self.navigationController.navigationBar.height-self.tabBarController.tabBar.height) style:UITableViewStyleGrouped];
    mainJobTable.centerX = self.view.width/2;
    mainJobTable.delegate = self;
    mainJobTable.dataSource = self;
    mainJobTable.backgroundColor = [UIColor whiteColor];
    mainJobTable.backgroundView = nil;
    mainJobTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    mainJobTable.separatorColor = [UIColor colorWithRed:190.0/255.0 green:190.0/255.0 blue:190.0/255.0 alpha:1.0f];
    [self.view addSubview:mainJobTable];
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"industry" ofType:@"plist"];
    NSArray *array = [[NSArray alloc] initWithContentsOfFile:plistPath];
    for (NSDictionary* dic in array) {
        if ([dic allKeys].count>0) {
            if ([[[dic allKeys] objectAtIndex:0] isKindOfClass:[NSString class]]) {
                [mainJobArray addObject:[[dic allKeys] objectAtIndex:0]];
                NSArray* arr = [dic objectForKey:[[dic allKeys] objectAtIndex:0]];
                [subJobArray addObject:arr];
            }
        }
    }
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
    return mainJobArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *myCell = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myCell];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.textLabel.text = [mainJobArray objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SubJobViewController* v = [[SubJobViewController alloc]initWithArray:[subJobArray objectAtIndex:indexPath.row] withMainJob:[mainJobArray objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:v animated:YES];
}


@end
