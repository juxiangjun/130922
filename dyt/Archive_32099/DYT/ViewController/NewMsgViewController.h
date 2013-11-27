//
//  NewMsgViewController.h
//  DYT
//
//  Created by zhaoliang.chen on 13-6-6.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface NewMsgViewController : UIViewController
<UITextFieldDelegate,UIScrollViewDelegate,
EGORefreshTableHeaderDelegate,UITableViewDataSource,
UITableViewDelegate,UISearchBarDelegate,
UISearchDisplayDelegate> {
    UITextField* searchTextField;
    UITableView* msgTableView;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    NSMutableArray* arrayMsg;
    NSMutableArray* arraySearch;
    BOOL isSearch;
    UISearchBar* m_searchBar;
    UISearchDisplayController* searchDisplay;
    UILabel* titleLabel;
}

@end
