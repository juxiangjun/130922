//
//  CityViewController.h
//  DYT
//
//  Created by zhaoliang.chen on 13-7-2.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CityViewController : UIViewController
<UITableViewDataSource,UITableViewDelegate>{
    UITableView* cityTable;
    NSArray* cityArray;
    NSString* provinceName;
}

- (id)initWithArray:(NSArray*)array withPname:(NSString*)pName;

@end
