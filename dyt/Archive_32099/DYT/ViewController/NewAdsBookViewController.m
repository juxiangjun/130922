//
//  NewAdsBookViewController.m
//  DYT
//
//  Created by zhaoliang.chen on 13-6-26.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "NewAdsBookViewController.h"
#import "NewAdsBookCell.h"
#import "GroupDetailViewController.h"

@interface NewAdsBookViewController ()

@end

@implementation NewAdsBookViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        isSearch = NO;
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
    //self.view.backgroundColor = [UIColor colorWithPatternImage:getBundleImage(@"loginBG.png")];
    self.view.backgroundColor = [UIColor colorWithRed:243.0/255.0 green:243.0/255.0 blue:243.0/255.0 alpha:1.0f];
    self.title = [NSString stringWithFormat:@"通讯录(%@)",parentGroup.groupName];
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    UIButton *button1 = getButtonByImageName(@"btBack.png");
    [button1 addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn1 = [[UIBarButtonItem alloc] initWithCustomView:button1];
    self.navigationItem.leftBarButtonItem = btn1;
    
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
    
    listTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, m_searchBar.bottom, self.view.width, self.view.height-m_searchBar.height-20) style:UITableViewStylePlain];
    listTableView.dataSource = self;
    listTableView.delegate = self;
    listTableView.backgroundColor = [UIColor colorWithRed:234.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0f];;
    listTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    listTableView.separatorColor = [UIColor colorWithRed:190.0/255.0 green:190.0/255.0 blue:190.0/255.0 alpha:1.0f];
    [self.view addSubview:listTableView];
    UIView * footview = [[UIView alloc]init];
    footview.backgroundColor =[UIColor clearColor];
    [listTableView setTableFooterView:footview];
    
    UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, listTableView.width, 1)];
    line.backgroundColor = [UIColor colorWithRed:190.0/255.0 green:190.0/255.0 blue:190.0/255.0 alpha:1.0f];
    line.bottom = listTableView.top;
    [self.view addSubview:line];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [listTableView reloadData];
}

#pragma mark TableView的代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        return arraySearch.count;
    } else {
        return parentGroup.subGroup.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *adsCell = @"adsCell";
    
    NewAdsBookCell *cell = (NewAdsBookCell*)[tableView dequeueReusableCellWithIdentifier:adsCell];
    if (cell == nil) {
        cell = [[NewAdsBookCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:adsCell];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        [cell setCell:[arraySearch objectAtIndex:indexPath.row]];
    } else {
        [cell setCell:[parentGroup.subGroup objectAtIndex:indexPath.row]];
    }
    
    return cell;
}

-(NSIndexPath*)tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath {
	return indexPath;
}

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    return 55;
}

//选中Cell响应事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupObject* one = nil;
    if (isSearch) {
        one = [arraySearch objectAtIndex:indexPath.row];
    } else {
        one = [parentGroup.subGroup objectAtIndex:indexPath.row];
    }
    GroupDetailViewController* v = [[GroupDetailViewController alloc]initWithData:one withName:parentGroup.groupName];
    [self.navigationController pushViewController:v animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [searchTextField resignFirstResponder];
    [arraySearch removeAllObjects];
    if (searchTextField.text.length>0) {
        for (GroupObject* p in parentGroup.subGroup) {
            //NSRange foundObj=[p.groupName rangeOfString:searchTextField.text options:NSCaseInsensitiveSearch];
            int locSlow = [p.groupName rangeOfString:searchTextField.text].location;
            if (locSlow!=NSNotFound) {
                [arraySearch addObject:p];
            }
        }
        isSearch = YES;
    } else {
        isSearch = NO;
    }
    [listTableView reloadData];
    return YES;
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UISearchBar的代理
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [arraySearch removeAllObjects];
    if (m_searchBar.text.length>0) {
        for (GroupObject* p in parentGroup.subGroup) {
            int locSlow = [p.groupName rangeOfString:m_searchBar.text].location;
            if (locSlow!=NSNotFound) {
                [arraySearch addObject:p];
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
//    if (m_searchBar.text.length == 0) {
//        isSearch = NO;
//        [listTableView reloadData];
//    }
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

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    if (m_searchBar.text.length>0) {
        for (GroupObject* p in parentGroup.subGroup) {
            int locSlow = [p.groupName rangeOfString:m_searchBar.text].location;
            if (locSlow!=NSNotFound) {
                [arraySearch addObject:p];
            }
        }
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    return YES;
}


@end
