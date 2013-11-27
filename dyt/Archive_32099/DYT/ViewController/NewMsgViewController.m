//
//  NewMsgViewController.m
//  DYT
//
//  Created by zhaoliang.chen on 13-6-6.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "NewMsgViewController.h"
#import "NewMsgCell.h"

@interface NewMsgViewController ()

@end

@implementation NewMsgViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"消息" image:[UIImage imageNamed:@"btMsg.png"] tag:0];
        //[tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"btMsgH.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"btMsg.png"]];
        self.tabBarItem = tabBarItem;
        arrayMsg = [NSMutableArray new];
        arraySearch = [NSMutableArray new];
        isSearch = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLastList:) name:@"updateLastList" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRecvMsgOnMsg:) name:@"onRecvMsgOnMsg" object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.navigationController.navigationBar setBackgroundImage:getBundleImage(@"navBG.png") forBarMetrics:UIBarMetricsDefault];
    //self.view.backgroundColor = [UIColor colorWithPatternImage:getBundleImage(@"loginBG.png")];
    self.view.backgroundColor = [UIColor colorWithRed:243.0/255.0 green:243.0/255.0 blue:243.0/255.0 alpha:1.0f];
    self.title = @"消息";
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    view.backgroundColor = [UIColor clearColor];    
    self.navigationItem.titleView = view;
    
    titleLabel = [[UILabel alloc]initWithFrame:view.frame];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:20];
    titleLabel.text = @"消息(连接中)";
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
//    [m_searchBar setBackgroundImage:getBundleImage(@"searchBarBG.png")];
    [self.view addSubview:m_searchBar];
    [[m_searchBar.subviews objectAtIndex:0]removeFromSuperview];
    
    searchDisplay = [[UISearchDisplayController alloc] initWithSearchBar:m_searchBar contentsController:self];
    searchDisplay.active = NO;
    searchDisplay.delegate = self;
    searchDisplay.searchResultsDataSource = self;
    searchDisplay.searchResultsDelegate = self;
    
    msgTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, m_searchBar.bottom, self.view.width, self.view.height-m_searchBar.height-20)];
    msgTableView.backgroundColor = [UIColor colorWithRed:234.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1];
    msgTableView.delegate = self;
    msgTableView.dataSource = self;
    msgTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    msgTableView.separatorColor = [UIColor colorWithRed:190.0/255.0 green:190.0/255.0 blue:190.0/255.0 alpha:1.0f];
    msgTableView.alwaysBounceVertical = YES;
    
    UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, msgTableView.width, 1)];
    line.backgroundColor = [UIColor colorWithRed:190.0/255.0 green:190.0/255.0 blue:190.0/255.0 alpha:1.0f];
    line.bottom = msgTableView.top;
    [self.view addSubview:line];
    
    UIView * footview = [[UIView alloc]init];
    footview.backgroundColor =[UIColor clearColor];
    [msgTableView setTableFooterView:footview];
    //UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onHidebt:)];
    //[msgScrollView addGestureRecognizer:tap];
    [self.view addSubview:msgTableView];
    
    if (_refreshHeaderView == nil) {
        _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -80, msgTableView.width, 80)];
        _refreshHeaderView.delegate = self;
        [msgTableView addSubview:_refreshHeaderView];
    }
    [_refreshHeaderView refreshLastUpdatedDate];    
    
    [arrayMsg removeAllObjects];
    arrayMsg = [MsgObject findAll];
    NSMutableArray *arr = [NSMutableArray array];
    for (int i=0; i<arrayMsg.count; i++) {
        MsgObject* mm = [arrayMsg objectAtIndex:i];
        if ([GroupObject findByGroupid:mm.subGroupid]==nil) {
            [arr addObject:mm];
        }
    }
    for (MsgObject *obj in arr) {
        [arrayMsg removeObject:obj];
        [MsgObject deleteByID:obj.subGroupid];
    }
    [msgTableView reloadData];
    
    [self getMsgList];    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [arrayMsg removeAllObjects];
    arrayMsg = [MsgObject findAll];
    [msgTableView reloadData];
    int all = 0;
    for (MsgObject* one in arrayMsg) {
        all += one.newMsgCount;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateNewMsg" object:[NSNumber numberWithInt:all]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"onChangeNum" object:[NSNumber numberWithInt:all]];
    [[DataManager sharedManager] setMsgCount:all];
    if (all==0) {
        titleLabel.text=@"消息";
    } else {
        titleLabel.text=[NSString stringWithFormat:@"消息 ( %d )",all];
    }
    
    if (([Reachability reachabilityForInternetConnection].currentReachabilityStatus == NotReachable) &&
        ([Reachability reachabilityForLocalWiFi].currentReachabilityStatus == NotReachable)) {
        titleLabel.text = @"消息(连接中)";
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)getMsgList {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *str = [def objectForKey:[NSString stringWithFormat:@"%d_lastGetMsgTime",[[DataManager sharedManager]getUser].userid]];
    titleLabel.text = @"消息(连接中)";
    [[WebServiceManager sharedManager] getMsgList:[[DataManager sharedManager]getUser].userid encodeStr:[[DataManager sharedManager]getUser].encodeStr date:str completion:^(NSDictionary* dic) {
        //[WaitTooles removeHUD];
        int success = [[dic objectForKey:@"success"]intValue];
        if (success == 1) {
            NSString *strMilli = nil;
            NSArray* array = [dic objectForKey:@"obj"];
            NSDate* compareTime = [NSDate dateWithTimeIntervalSince1970:0];
            if ([array isKindOfClass:[NSArray class]]) {
                for (int i=0; i<array.count; i++) {
                    NSDictionary* dic1 = [array objectAtIndex:i];
                    MsgObject* one = [MsgObject getOneMsg:dic1];
                    if (one == nil) {
                        continue;
                    }
                    
                    if ([MsgObject findByID:one.subGroupid]==nil) {
                        [MsgObject addOneLast:one];
                    } else {
                        [MsgObject updateByID:one];
                    }
                    [MsgObject updateCount:one.subGroupid withNewCount:one.newMsgCount];
                    if ([formatStringToDateMilli(one.lastTime) compare:compareTime]==NSOrderedDescending) {
                        compareTime = formatStringToDateMilli(one.lastTime);
                        strMilli = one.lastTime;
                    }
                }
//            NSDate* date = [NSDate date];
//            if (array.count>0) {
//                NSDictionary *dic = [array objectAtIndex:0];
//                NSString *dString = [dic objectForKey:@"timestamp"];
//                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//                [dateFormat setTimeZone:[NSTimeZone defaultTimeZone]];
//                [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//                date = [dateFormat dateFromString:dString];
//            }
                if (array.count>0) {
                    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
//                    [def setObject:formatDateToStringALL(compareTime) forKey:[NSString stringWithFormat:@"%d_lastGetMsgTime",[[DataManager sharedManager]getUser].userid]];
                    [def setObject:strMilli forKey:[NSString stringWithFormat:@"%d_lastGetMsgTime",[[DataManager sharedManager]getUser].userid]];
                    [def synchronize];
                }
            }
            isSearch = NO;
            [arrayMsg removeAllObjects];
            arrayMsg = [MsgObject findAll];
            [msgTableView reloadData];
            int all = 0;
            for (MsgObject* one in arrayMsg) {
                all += one.newMsgCount;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateNewMsg" object:[NSNumber numberWithInt:all]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"onChangeNum" object:[NSNumber numberWithInt:all]];
            [[DataManager sharedManager] setMsgCount:all];
            if (all==0) {
                titleLabel.text=@"消息";
            } else {                
                titleLabel.text=[NSString stringWithFormat:@"消息 ( %d )",all];
            }
        }
    }];
}

#pragma mark TableView的代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        return arraySearch.count;
    } else {
        return arrayMsg.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MsgCell = @"MsgCell";
    
    NewMsgCell *cell = (NewMsgCell*)[tableView dequeueReusableCellWithIdentifier:MsgCell];
    if (cell == nil) {
        cell = [[NewMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MsgCell];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        [cell setCell:[arraySearch objectAtIndex:indexPath.row]];
    } else {
        [cell setCell:[arrayMsg objectAtIndex:indexPath.row]];
    }
    
    return cell;
}

-(NSIndexPath*)tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath {
	return indexPath;
}

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    return 60;
}

//设置行缩进
- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
}

//选中Cell响应事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MsgObject* one = nil;
    if (isSearch) {
        one = [arraySearch objectAtIndex:indexPath.row];
    } else {
        one = [arrayMsg objectAtIndex:indexPath.row];
    }
    int count = [MsgObject findCountByID:one.subGroupid];
    int all = [[DataManager sharedManager] getMsgCount];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateNewMsg" object:[NSNumber numberWithInt:all-count]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"onChangeNum" object:[NSNumber numberWithInt:all-count]];
    [MsgObject updateCount:one.subGroupid withNewCount:0];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"gotoChatByGroupid" object:[NSNumber numberWithInt:one.subGroupid]];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MsgObject* one = nil;
        if (isSearch) {
            one = [arraySearch objectAtIndex:indexPath.row];
            [arraySearch removeObjectAtIndex:indexPath.row];
        } else {
            one = [arrayMsg objectAtIndex:indexPath.row];
            [arrayMsg removeObjectAtIndex:indexPath.row];
        }
        [msgTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        int count = [MsgObject findCountByID:one.subGroupid];
        int all = [[DataManager sharedManager] getMsgCount];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateNewMsg" object:[NSNumber numberWithInt:all-count]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"onChangeNum" object:[NSNumber numberWithInt:all-count]];
        [MsgObject deleteByID:one.subGroupid];
        [ChatObject deleteOneChatList:one.subGroupid];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
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
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:msgTableView];
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self reloadTableViewDataSource];
    [self getMsgList];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.0];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    return _reloading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date];
}

#pragma mark uitextField
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [searchTextField resignFirstResponder];
    [arraySearch removeAllObjects];
    if (searchTextField.text.length>0) {
        for (MsgObject* m in arrayMsg) {
            NSRange foundObj=[m.subGroupName rangeOfString:searchTextField.text options:NSCaseInsensitiveSearch];
            if (foundObj.length>0) {
                [arraySearch addObject:m];
            }
        }
        isSearch = YES;
        [msgTableView reloadData];
    } else {
        isSearch = NO;
        [msgTableView reloadData];
    }
    return YES;
}

#pragma mark 更新最近联系人的列表
- (void)updateLastList:(NSNotification*)sender {
    MsgObject* one = (MsgObject*)sender.object;
    [arrayMsg insertObject:one atIndex:0];
    for (int i=1; i<arrayMsg.count; i++) {
        MsgObject* m = [arrayMsg objectAtIndex:i];
        if (one.groupid == m.groupid) {
            [arrayMsg removeObject:m];
            break;
        }
    }
    [msgTableView reloadData];
}

- (void)onRecvMsgOnMsg:(NSNotification*)sender {
    [arrayMsg removeAllObjects];
    arrayMsg = [MsgObject findAll];
    [msgTableView reloadData];
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
            break;
        }
    }
	return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	searchBar.showsCancelButton = NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
    [arraySearch removeAllObjects];
    if (m_searchBar.text.length>0) {
        for (MsgObject* m in arrayMsg) {
            NSRange foundObj=[m.subGroupName rangeOfString:m_searchBar.text options:NSCaseInsensitiveSearch];
            if (foundObj.length>0) {
                [arraySearch addObject:m];
            }
        }
        isSearch = YES;
    } else {
        isSearch = NO;
    }
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [searchBar resignFirstResponder];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    if (m_searchBar.text.length>0) {
        for (MsgObject* m in arrayMsg) {
            NSRange foundObj=[m.subGroupName rangeOfString:m_searchBar.text options:NSCaseInsensitiveSearch];
            if (foundObj.length>0) {
                [arraySearch addObject:m];
            }
        }
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    return YES;
}

- (BOOL)shouldAutorotate{
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
    //    return UIInterfaceOrientationMaskAll;
}

@end
