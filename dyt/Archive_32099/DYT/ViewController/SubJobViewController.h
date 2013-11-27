//
//  SubJobViewController.h
//  DYT
//
//  Created by zhaoliang.chen on 13-7-2.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubJobViewController : UIViewController
<UITableViewDataSource,UITableViewDelegate>{
    UITableView* subJobTable;
    NSArray* subJobArray;
    NSString* mainJobName;
}

- (id)initWithArray:(NSArray*)array withMainJob:(NSString*)MainJob;

@end
