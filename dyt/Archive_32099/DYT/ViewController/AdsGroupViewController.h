//
//  AdsGroupViewController.h
//  DYT
//
//  Created by zhaoliang.chen on 13-6-3.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@class TKImageCache;
@interface AdsGroupViewController : UIViewController
<UITextFieldDelegate,UISearchBarDelegate,
UITableViewDataSource,UITableViewDelegate,
UISearchDisplayDelegate,EGORefreshTableHeaderDelegate>{
    float height;
    UITextField* searchTextField;
    UIScrollView* listScrollView;
    NSMutableArray* arrayGroup;
    NSMutableArray* arraySearch;
    TKImageCache* _recvGroupMain;
    UISearchBar* m_searchBar;
    UISearchDisplayController* searchDisplay;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    UILabel* titleLabel;
}

@end
