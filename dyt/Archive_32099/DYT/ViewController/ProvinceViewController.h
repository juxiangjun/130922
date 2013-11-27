//
//  ProvinceViewController.h
//  DYT
//
//  Created by zhaoliang.chen on 13-7-2.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProvinceViewController : UIViewController
<UITableViewDataSource,UITableViewDelegate>{
    UITableView* provinceTable;
    NSArray* provinceArray;
    NSMutableArray* cityArray;
}

@end
