//
//  NewAdsGroupViewController.m
//  DYT
//
//  Created by zhaoliang.chen on 13-6-25.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "NewAdsGroupViewController.h"
#include "pinyin.h"
#import "NewAdsGroupCell.h"

@interface NewAdsGroupViewController ()

@end

@implementation NewAdsGroupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"通讯录" image:[UIImage imageNamed:@"btAdsBook.png"] tag:1];
        self.tabBarItem = tabBarItem;
        
        isSearch = NO;
        ArrayTemptitle = [NSMutableArray new];
        arrayDIC = [NSMutableDictionary new];
        arrayGroup = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.navigationController.navigationBar setBackgroundImage:getBundleImage(@"navBG.png") forBarMetrics:UIBarMetricsDefault];
    self.view.backgroundColor = [UIColor colorWithPatternImage:getBundleImage(@"loginBG.png")];
    self.title = @"通讯录";
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
//    UIImageView* searchBG = getImageViewByImageName(@"searchBG.png");
//    searchBG.centerX = self.view.width/2;
//    searchBG.top = 10;
//    searchBG.userInteractionEnabled = YES;
//    [self.view addSubview:searchBG];
//    
//    searchTextField = [[UITextField alloc]initWithFrame:CGRectMake(30, 0, searchBG.width-100, searchBG.height-8)];
//    searchTextField.centerY = searchBG.height/2;
//    searchTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    searchTextField.textAlignment = NSTextAlignmentLeft;
//    searchTextField.delegate = self;
//    searchTextField.returnKeyType = UIReturnKeySearch;
//    [searchBG addSubview:searchTextField];
    
    m_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    m_searchBar.centerX = self.view.width/2;
    m_searchBar.delegate = self;
    m_searchBar.barStyle = UIBarStyleDefault;
    m_searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    m_searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    m_searchBar.placeholder = @"搜索";
    m_searchBar.keyboardType =  UIKeyboardTypeDefault;
    [m_searchBar setBackgroundImage:getBundleImage(@"searchBarBG.png")];
    [self.view addSubview:m_searchBar];
    
    listTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, m_searchBar.bottom, self.view.width, self.view.height-m_searchBar.height-self.navigationController.navigationBar.height-self.tabBarController.tabBar.height) style:UITableViewStyleGrouped];
    listTableView.dataSource = self;
    listTableView.delegate = self;
    listTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:listTableView];
    
    if (([Reachability reachabilityForInternetConnection].currentReachabilityStatus == NotReachable) &&       ([Reachability reachabilityForLocalWiFi].currentReachabilityStatus == NotReachable)) {
        arrayGroup = [GroupObject findByParentid:-1];
        for (GroupObject *one in arrayGroup) {
            one.subGroup = [GroupObject findByParentid:one.groupid];
        }
        [listTableView reloadData];
    } else {
        [self getGroup];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)getGroup {
    [[WebServiceManager sharedManager] getGroupMain:[[DataManager sharedManager] getUser].userid encodeStr:[[DataManager sharedManager]getUser].encodeStr completion:^(NSDictionary* dic) {
        int success = [[dic objectForKey:@"success"]intValue];
        if (success == 1) {
            NSArray* array = [dic objectForKey:@"obj"];
            if ([array isKindOfClass:[NSArray class]]) {
                for (int i=0; i<array.count; i++) {
                    NSDictionary* dic = [array objectAtIndex:i];
                    GroupObject* one = [GroupObject getOneGroup:dic];
                    [arrayGroup addObject:one];
                    
                    if ([GroupObject findByGroupid:one.groupid]==nil) {
                        [GroupObject addOneGroup:one];
                    } else {
                        [GroupObject updateGroup:one];
                    }
                }
            } else {
                arrayGroup = [GroupObject findByParentid:-1];
                for (GroupObject *one in arrayGroup) {
                    one.subGroup = [GroupObject findByParentid:one.groupid];
                }
            }
            ArrayTemptitle = [NSArray arrayWithObjects:@"group", nil];
            for (int i=0; i<ArrayTemptitle.count; i++) {
                NSString* str = [ArrayTemptitle objectAtIndex:i];
                [arrayDIC setObject:arrayGroup forKey:str];
            }
            [listTableView reloadData];
        }
    }];
}

//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [ArrayTemptitle count];//返回标题数组中元素的个数来确定分区的个数
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {    
    NSString *key = [ArrayTemptitle objectAtIndex:section];    
    NSArray *nameSection = [arrayDIC objectForKey:key];    
    return [nameSection count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    NSUInteger section = [indexPath section];    
    NSUInteger row = [indexPath row];    
    NSString *key = [ArrayTemptitle objectAtIndex:section];    
    NSArray *nameSection = [arrayDIC objectForKey:key];    
    static NSString *SectionsTableIdentifier = @"SectionsTableIdentifier";    
    NewAdsGroupCell *cell = (NewAdsGroupCell*)[tableView dequeueReusableCellWithIdentifier:                            SectionsTableIdentifier];    
    if (cell == nil) {        
        cell = [[NewAdsGroupCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SectionsTableIdentifier];        
    }    
    [cell setCell:[nameSection objectAtIndex:row]];
    return cell;    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {    
    NSString *key = [ArrayTemptitle objectAtIndex:section];
    return key;    
}

#pragma mark UISearchBar的代理
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [arraySearch removeAllObjects];
    if (m_searchBar.text.length>0) {
        for (GroupObject* p in arrayGroup) {
            NSRange foundObj=[p.groupName rangeOfString:m_searchBar.text options:NSCaseInsensitiveSearch];
            if (foundObj.length>0) {
                [arraySearch addObject:p];
            }
        }
    }
    [listTableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [searchBar resignFirstResponder];
    if (m_searchBar.text.length==0) {
        [listTableView reloadData];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
	searchBar.showsCancelButton = YES;
	for(id cc in [searchBar subviews]){
        if([cc isKindOfClass:[UIButton class]]){
            UIButton *btn = (UIButton *)cc;
            [btn setTitle:@"取消"  forState:UIControlStateNormal];
        }
    }
	return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	searchBar.showsCancelButton = NO;
}


@end
