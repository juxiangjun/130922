//
//  NewAdsGroupViewController.h
//  DYT
//
//  Created by zhaoliang.chen on 13-6-25.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewAdsGroupViewController : UIViewController
<UITextFieldDelegate,UITableViewDataSource,
UITableViewDelegate,UISearchBarDelegate>{
    UITextField* searchTextField;
    UITableView* listTableView;
    NSMutableArray* arrayGroup;
    NSMutableArray* arraySearch;
    NSMutableArray *ArrayTemptitle;//定义标题数组
	NSMutableArray *dataArray; //存放分区数组的数组
    NSMutableDictionary* arrayDIC;
    UISearchBar* m_searchBar;
    BOOL isSearch;
}

@end
