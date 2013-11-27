//
//  AdsGroupViewController.m
//  DYT
//
//  Created by zhaoliang.chen on 13-6-3.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "AdsGroupViewController.h"
#import "TKImageCache.h"
#import "NewAdsBookViewController.h"
#import "NewAdsGroupCell.h"

@interface AdsGroupViewController ()

@end

@implementation AdsGroupViewController

#define ADDRESSTAG      1000
#define GROUPHEADTAG    2000

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"通讯录" image:[UIImage imageNamed:@"btAdsBook.png"] tag:1];
        //[tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"btAdsBookH.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"btAdsBook.png"]];
        self.tabBarItem = tabBarItem;
        
        _recvGroupMain = [[TKImageCache alloc] initWithCacheDirectoryName:@"activity"];
        _recvGroupMain.notificationName = @"recvGroupMain";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvGroupMain:) name:@"recvGroupMain" object:nil];
        
        arrayGroup = [NSMutableArray new];
        arraySearch = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.navigationController.navigationBar setBackgroundImage:getBundleImage(@"navBG.png") forBarMetrics:UIBarMetricsDefault];
    //self.view.backgroundColor = [UIColor colorWithPatternImage:getBundleImage(@"loginBG.png")];
    self.view.backgroundColor = [UIColor colorWithRed:243.0/255.0 green:243.0/255.0 blue:243.0/255.0 alpha:1.0f];
    self.title = @"通讯录";
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    view.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = view;
    
    titleLabel = [[UILabel alloc]initWithFrame:view.frame];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:20];
    [view addSubview:titleLabel];
    
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
    
    searchDisplay = [[UISearchDisplayController alloc] initWithSearchBar:m_searchBar contentsController:self];
    searchDisplay.active = NO;
    searchDisplay.delegate = self;
    searchDisplay.searchResultsDataSource = self;
    searchDisplay.searchResultsDelegate = self;

    listScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, m_searchBar.bottom, self.view.width, self.view.height-m_searchBar.height-self.navigationController.navigationBar.height-self.tabBarController.tabBar.height)];
    listScrollView.userInteractionEnabled = YES;
    listScrollView.backgroundColor = [UIColor colorWithRed:234.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0f];
    listScrollView.alwaysBounceVertical = YES;
    listScrollView.delegate = self;
    [self.view addSubview:listScrollView];
    
    if (_refreshHeaderView == nil) {
        _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -80, listScrollView.width, 80)];
        _refreshHeaderView.delegate = self;
        [listScrollView addSubview:_refreshHeaderView];
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    
    UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, listScrollView.width, 1)];
    line.backgroundColor = [UIColor colorWithRed:190.0/255.0 green:190.0/255.0 blue:190.0/255.0 alpha:1.0f];
    line.bottom = listScrollView.top;
    [self.view addSubview:line];
    
    height = 0.0f;
    //if (([Reachability reachabilityForInternetConnection].currentReachabilityStatus == NotReachable) &&       ([Reachability reachabilityForLocalWiFi].currentReachabilityStatus == NotReachable)) {
        arrayGroup = [GroupObject findByParentid:-1];
        for (GroupObject *one in arrayGroup) {
            one.subGroup = [GroupObject findByParentid:one.groupid];
        }        
        [self createScrollView:NO];
    //} else {
    [self getGroup];
    //}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_recvGroupMain cancelOperations];
}

- (void)getGroup {
    titleLabel.text = @"通讯录(正在更新中)";
    [[WebServiceManager sharedManager] getGroupMain:[[DataManager sharedManager] getUser].userid encodeStr:[[DataManager sharedManager] getUser].encodeStr completion:^(NSDictionary* dic) {
        int success = [[dic objectForKey:@"success"]intValue];
        if (success == 1) {
            NSArray* array = [dic objectForKey:@"obj"];
            if ([array isKindOfClass:[NSArray class]]) {
                height = 0.0f;
                [arrayGroup removeAllObjects];
                [GroupObject deleteAllGroupid];
                for (int i=0; i<array.count; i++) {
                    NSDictionary* dic1 = [array objectAtIndex:i];
                    GroupObject* one = [GroupObject getOneGroup:dic1];
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
            titleLabel.text = @"通讯录";
            [self createScrollView:NO];
        } else {
            if ([[dic objectForKey:@"returnCode"]intValue]==101) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息" message:@"你的账号已经在别处登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"backToRoot" object:nil];
            }
        }
    }];
}

- (void)createScrollView:(BOOL)isSearch {
    for (UIView* v in listScrollView.subviews) {
        if (![v isKindOfClass:[EGORefreshTableHeaderView class]]) {
            [v removeFromSuperview];
        }
    }
    NSArray* arr = nil;
    if (isSearch) {
        arr = arraySearch;
    } else {
        arr = arrayGroup;
    }
    for (int i=0; i<arr.count; i++) {
        GroupObject* one = [arr objectAtIndex:i];
        
        UIView* v = [[UIView alloc]initWithFrame:CGRectMake(0, height, listScrollView.width, 55.0f)];
        v.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0f];
        v.tag = ADDRESSTAG+i;
        [listScrollView addSubview:v];
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTap:)];
        [v addGestureRecognizer:tap];
        
        UIImageView* head = createPortraitView(40);
        head.left = 10;
        head.centerY = v.height/2;
        head.tag = GROUPHEADTAG+one.groupid;
        if ([one.groupHead isKindOfClass:[NSString class]]&&one.groupHead.length>0) {
            NSURL *url = [NSURL URLWithString:getPicNameALL(one.groupHead)];
            UIImage *img = [_recvGroupMain imageForKey:[one.groupHead lastPathComponent]                                          url:url queueIfNeeded:YES tag:head.tag];
            if (img) {
                head.image = img;
            }else{
                head.image = getBundleImage(@"defaultGroup.png");
            }
        } else {
            head.image = getBundleImage(@"defaultGroup.png");
        }
        [v addSubview:head];
        
        UILabel* groupName = [[UILabel alloc]initWithFrame:CGRectMake(head.right+10, 2, v.width/2, 20)];
        groupName.backgroundColor = [UIColor clearColor];
        groupName.textColor = [UIColor blackColor];
        groupName.textAlignment = NSTextAlignmentLeft;
        groupName.font = [UIFont systemFontOfSize:16];
        groupName.text = one.groupName;
        [v addSubview:groupName];
        
        UILabel* l1 = [[UILabel alloc]initWithFrame:CGRectMake(groupName.left, groupName.bottom+4, 100, 20)];
        l1.backgroundColor = [UIColor clearColor];
        l1.textColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0f];
        l1.textAlignment = NSTextAlignmentLeft;
        l1.font = [UIFont systemFontOfSize:14];
        l1.text = @"";
        for (int j=0; j<one.subGroup.count; j++) {
            GroupObject* obj = [one.subGroup objectAtIndex:j];
            l1.text = [l1.text stringByAppendingFormat:@"%@",obj.groupName];
            if (j!=one.subGroup.count-1) {
                l1.text = [l1.text stringByAppendingFormat:@","];
            }
        }
        l1.width = [l1.text sizeWithFont:l1.font].width;
        [v addSubview:l1];
        
        UIImageView* arrow = getImageViewByImageName(@"arrow.png");
        arrow.centerY = v.height/2;
        arrow.right = v.width-10;
        [v addSubview:arrow];
        
        UIView* line = [[UIView alloc]initWithFrame:CGRectMake(v.left, v.bottom, v.width, 1)];
        line.backgroundColor = [UIColor colorWithRed:190.0/255.0 green:190.0/255.0 blue:190.0/255.0 alpha:1.0f];
        [listScrollView addSubview:line];

        height = line.bottom;
    }
    listScrollView.contentSize = CGSizeMake(listScrollView.width, height);
}

- (void)onTap:(UITapGestureRecognizer*)sender {
    GroupObject* obj = [arrayGroup objectAtIndex:sender.view.tag-ADDRESSTAG];
    NewAdsBookViewController* v = [[NewAdsBookViewController alloc]initWithData:obj];
    [self.navigationController pushViewController:v animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [searchTextField resignFirstResponder];
    height = 0.0f;
    [arraySearch removeAllObjects];
    if (searchTextField.text.length>0) {
        for (GroupObject* p in arrayGroup) {
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

- (void)recvGroupMain:(NSNotification*)sender {
    NSDictionary *dict = [sender userInfo];
    UIImage *img = [dict objectForKey:@"image"];
    int tag = [[dict objectForKey:@"tag"] intValue];    
    UIImageView* imgView = (UIImageView*)[listScrollView viewWithTag:tag];    
    imgView.image = img;
}

#pragma mark UISearchBar的代理
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    height = 0.0f;
    [arraySearch removeAllObjects];
    if (m_searchBar.text.length>0) {
        for (GroupObject* p in arrayGroup) {
            NSRange foundObj=[p.groupName rangeOfString:m_searchBar.text options:NSCaseInsensitiveSearch];
            if (foundObj.length>0) {
                [arraySearch addObject:p];
            }
        }
    }
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
	searchBar.showsCancelButton = YES;
	for(id cc in [searchBar subviews]){
        if([cc isKindOfClass:[UIButton class]]){
            UIButton *btn = (UIButton *)cc;
            btn.backgroundColor = [UIColor clearColor];
            [btn setBackgroundImage:getBundleImage(@"searchCancel.png") forState:UIControlStateNormal];
            [btn setBackgroundImage:getBundleImage(@"searchCancel.png") forState:UIControlStateHighlighted];
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

#pragma mark TableView的代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        return arraySearch.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MsgCell = @"MsgCell";
    
    NewAdsGroupCell *cell = (NewAdsGroupCell*)[tableView dequeueReusableCellWithIdentifier:MsgCell];
    if (cell == nil) {
        cell = [[NewAdsGroupCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MsgCell];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        [cell setCell:[arraySearch objectAtIndex:indexPath.row]];
    } 
    
    return cell;
}

-(NSIndexPath*)tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath {
	return indexPath;
}

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    return 60;
}

//选中Cell响应事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MsgObject* one = nil;
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        one = [arraySearch objectAtIndex:indexPath.row];
    }
    GroupObject* obj = [arraySearch objectAtIndex:indexPath.row];
    NewAdsBookViewController* v = [[NewAdsBookViewController alloc]initWithData:obj];
    [self.navigationController pushViewController:v animated:YES];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    if (m_searchBar.text.length>0) {
        for (GroupObject* m in arrayGroup) {
            NSRange foundObj=[m.groupName rangeOfString:m_searchBar.text options:NSCaseInsensitiveSearch];
            if (foundObj.length>0) {
                [arraySearch addObject:m];
            }
        }
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    return YES;
}

#pragma mark scrollview的代理
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)reloadTableViewDataSource{
    _reloading = YES;
}

- (void)doneLoadingTableViewData{
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:listScrollView];
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self reloadTableViewDataSource];
    [self getGroup];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.0];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    return _reloading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date];
}


@end
