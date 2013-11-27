//
//  NewAdsBookViewController.h
//  DYT
//
//  Created by zhaoliang.chen on 13-6-26.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewAdsBookViewController : UIViewController
<UITableViewDelegate,UITableViewDataSource,
UITextFieldDelegate,UISearchBarDelegate,
UISearchDisplayDelegate> {
    UITextField* searchTextField;
    UITableView* listTableView;
    GroupObject* parentGroup;
    BOOL isSearch;
    NSMutableArray* arraySearch;
    UISearchBar* m_searchBar;
    UISearchDisplayController* searchDisplay;
}


-(id)initWithData:(GroupObject*)obj;

@end
