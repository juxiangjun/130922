//
//  MainJobViewController.h
//  DYT
//
//  Created by zhaoliang.chen on 13-7-2.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainJobViewController : UIViewController 
<UITableViewDataSource,UITableViewDelegate>{
    UITableView* mainJobTable;
    NSMutableArray* mainJobArray;
    NSMutableArray* subJobArray;
}

@end
