//
//  GroupActDetailViewController.h
//  DYT
//
//  Created by zhaoliang.chen on 13-7-8.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupActDetailViewController : UIViewController {
    NSString* content;
    UIScrollView* mainScrollView;
    UILabel* contentLabel;
}

- (id)initWithDetail:(NSString*)detail ;

@end
