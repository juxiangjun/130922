//
//  MsgViewController.m
//  DYT
//
//  Created by zhaoliang.chen on 13-6-3.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "MsgViewController.h"

@interface MsgViewController ()

@end

@implementation MsgViewController

#define VIEWTAG         1000
#define CHATTAG         2000
#define DELBTTAG        3000
#define oneViewHeight   50

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"消息" image:[UIImage imageNamed:@"btMsg.png"] tag:0];        
        [tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"btMsgH.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"btMsg.png"]];
        self.tabBarItem = tabBarItem;
        
        deleteBtArray = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.navigationController.navigationBar setBackgroundImage:getBundleImage(@"navBG.png") forBarMetrics:UIBarMetricsDefault];
    self.view.backgroundColor = [UIColor colorWithPatternImage:getBundleImage(@"loginBG.png")];
    self.title = @"消息";
    [self.navigationItem setHidesBackButton:YES animated:NO];    
    
    UIImageView* searchBG = getImageViewByImageName(@"searchBG.png");
    searchBG.centerX = self.view.width/2;
    searchBG.top = 10;
    searchBG.userInteractionEnabled = YES;
    [self.view addSubview:searchBG];
    
    searchTextField = [[UITextField alloc]initWithFrame:CGRectMake(30, 0, searchBG.width-100, searchBG.height-8)];
    searchTextField.centerY = searchBG.height/2;
    searchTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    searchTextField.textAlignment = NSTextAlignmentLeft;
    searchTextField.delegate = self;
    [searchBG addSubview:searchTextField];
    
    msgScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, searchBG.bottom+10, self.view.width, self.view.height-searchBG.height-20)];
    msgScrollView.userInteractionEnabled = YES;
    msgScrollView.backgroundColor = [UIColor clearColor];
    msgScrollView.delegate = self;
    msgScrollView.alwaysBounceVertical = YES;
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onHidebt:)];
    [msgScrollView addGestureRecognizer:tap];
    [self.view addSubview:msgScrollView];
    
    if (_refreshHeaderView == nil) {
        _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -80, msgScrollView.width, 80)];
        _refreshHeaderView.delegate = self;
        [msgScrollView addSubview:_refreshHeaderView];
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    
    [self createScrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createScrollView {
    for (UIView* v in msgScrollView.subviews) {
        if (![v isKindOfClass:[EGORefreshTableHeaderView class]]) {
            [v removeFromSuperview];
        }
    }
    for (int i=0; i<5; i++) {
        UIView* v = [[UIView alloc]initWithFrame:CGRectMake(0, 0, msgScrollView.width, oneViewHeight)];
        v.top = i*v.height;
        v.backgroundColor = [UIColor clearColor];
        v.tag = VIEWTAG+i;
        [msgScrollView addSubview:v];
        
        UIImageView* head = createPortraitView(44);
        head.left = 5;
        head.centerY = v.height/2;
        head.image = getBundleImage(@"defaultGroup.png");
        [v addSubview:head];
        
        UIImageView* chatBG = getImageViewByImageName(@"oneMsgBG.png");
        chatBG.left = head.right;
        chatBG.centerY = head.centerY;
        chatBG.userInteractionEnabled = YES;
        chatBG.tag = CHATTAG+i;
        UISwipeGestureRecognizer* swipLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(onSwip:)];
        [swipLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
        [chatBG addGestureRecognizer:swipLeft];
        UISwipeGestureRecognizer* swipRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(onSwip:)];
        [swipRight setDirection:UISwipeGestureRecognizerDirectionRight];
        [chatBG addGestureRecognizer:swipRight];
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTap:)];
        [chatBG addGestureRecognizer:tap];
        [v addSubview:chatBG];
        
        UILabel* groupName = [[UILabel alloc]initWithFrame:CGRectMake(10, 2, chatBG.width/2, 20)];
        groupName.backgroundColor = [UIColor clearColor];
        groupName.textColor = [UIColor colorWithRed:163.0/255.0 green:38.0/255.0 blue:38.0/255.0 alpha:1.0f];
        groupName.textAlignment = NSTextAlignmentLeft;
        groupName.font = [UIFont systemFontOfSize:12];
        groupName.text = @"我的群组";
        [chatBG addSubview:groupName];
        
        UILabel* lTime = [[UILabel alloc]initWithFrame:CGRectMake(10, 2, chatBG.width/2, 20)];
        lTime.right = chatBG.width-5;
        lTime.backgroundColor = [UIColor clearColor];
        lTime.textColor = [UIColor colorWithRed:179.0/255.0 green:179.0/255.0 blue:179.0/255.0 alpha:1.0f];
        lTime.textAlignment = NSTextAlignmentRight;
        lTime.font = [UIFont systemFontOfSize:12];
        lTime.text = @"2013.5.20";
        [chatBG addSubview:lTime];
        
        UILabel* lastChatName = [[UILabel alloc]initWithFrame:CGRectMake(10, 22, 50, 20)];
        lastChatName.backgroundColor = [UIColor clearColor];
        lastChatName.textColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0f];
        lastChatName.textAlignment = NSTextAlignmentLeft;
        lastChatName.font = [UIFont systemFontOfSize:12];
        lastChatName.text = @"王经理";
        lastChatName.width = [lastChatName.text sizeWithFont:lastChatName.font].width;
        if (lastChatName.width>50) {
            lastChatName.width=50;
        }
        [chatBG addSubview:lastChatName];
        
        UILabel* colon = [[UILabel alloc]initWithFrame:CGRectMake(lastChatName.right, 22, 12, 20)];
        colon.backgroundColor = [UIColor clearColor];
        colon.textColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0f];
        colon.textAlignment = NSTextAlignmentLeft;
        colon.font = [UIFont systemFontOfSize:12];
        colon.text = @":";
        colon.width = [colon.text sizeWithFont:colon.font].width;
        [chatBG addSubview:colon];
        
        UILabel* lastChatContent = [[UILabel alloc]initWithFrame:CGRectMake(colon.right, 22, 160, 20)];
        lastChatContent.backgroundColor = [UIColor clearColor];
        lastChatContent.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0f];
        lastChatContent.textAlignment = NSTextAlignmentLeft;
        lastChatContent.font = [UIFont systemFontOfSize:12];
        lastChatContent.text = @"欢迎大家加入我们的群,以后群里要和谐共同发展.";
        [chatBG addSubview:lastChatContent];
        
        UIButton* btDelete = getButtonByImageName(@"msgDelete.png");
        btDelete.right = chatBG.width-10;
        btDelete.centerY = chatBG.height/2;
        btDelete.tag = DELBTTAG+i;
        [btDelete addTarget:self action:@selector(deleteOnMsg:) forControlEvents:UIControlEventTouchUpInside];
        btDelete.hidden = YES;
        [chatBG addSubview:btDelete];
        [deleteBtArray addObject:btDelete];
    }
    msgScrollView.contentSize = CGSizeMake(msgScrollView.width, oneViewHeight*5);
}

#pragma mark 平移事件
- (void)onSwip:(UISwipeGestureRecognizer*)sender {
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        UIButton* b = (UIButton*)[sender.view viewWithTag:sender.view.tag-CHATTAG+DELBTTAG];
        if (b.hidden) {
            b.hidden = NO;
        } else {
            return ;
        }
    } else if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
        UIButton* b = (UIButton*)[sender.view viewWithTag:sender.view.tag-CHATTAG+DELBTTAG];
        if (!b.hidden) {
            b.hidden = YES;
        } else {
            return ;
        }
    }
}

- (void)onTap:(UITapGestureRecognizer*)sender {
    BOOL isHide = YES ;
    for (UIButton* bb in deleteBtArray) {
        if (!bb.hidden) {
            bb.hidden = YES;
            isHide = NO;
        }
    }
    if (isHide) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"gotoChat" object:nil];
    } 
}

- (void)onHidebt:(UITapGestureRecognizer*)sender {
    for (UIButton* bb in deleteBtArray) {
        if (!bb.hidden) {
            bb.hidden = YES;
        }
    }
}

- (void)deleteOnMsg:(id)sender {
    UIButton* b = (UIButton*)sender;
    for (UIView* v in msgScrollView.subviews) {
        if (v.tag == b.tag-DELBTTAG+VIEWTAG) {
            [v removeFromSuperview];
            break;
        }
    }
    for (UIButton* bb in deleteBtArray) {
        if (bb.tag == b.tag) {
            [deleteBtArray removeObject:bb];
            break;
        }
    }
    for (UIButton* bb in deleteBtArray) {
        if (bb.tag > b.tag) {
            bb.tag -= 1;
        }
    }
    for (UIView* v in msgScrollView.subviews) {
        if ([v isKindOfClass:[UIView class]]) {
            if (v.tag > b.tag-DELBTTAG+VIEWTAG) {
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.5f];
                v.top -= oneViewHeight;
                for (UIView* i in v.subviews) {
                    if (i.tag == v.tag-VIEWTAG+CHATTAG && [i isKindOfClass:[UIImageView class]]) {
                        for (UIView* ii in i.subviews) {
                            if (ii.tag == i.tag-CHATTAG+DELBTTAG && [ii isKindOfClass:[UIButton class]]) {
                                ii.tag -= 1;
                                break;
                            }
                        }
                        i.tag -= 1;
                        break;
                    }
                }
                v.tag -= 1;
                [UIView commitAnimations];
            }
        }
    }
    msgScrollView.contentSize = CGSizeMake(msgScrollView.width, msgScrollView.contentSize.height-oneViewHeight);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [searchTextField resignFirstResponder];
    return YES;
}

#pragma mark scrollview的代理
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    //    CGRect bounds = myScrollView.bounds;
    //    CGSize size = myScrollView.contentSize;
    //    UIEdgeInsets inset = myScrollView.contentInset;
    //    CGFloat currentOffset=myScrollView.contentOffset.y+bounds.size.height-inset.bottom;
    //    CGFloat maximumOffset = size.height;
    //    if((maximumOffset-currentOffset)<50.0)
    //        NSLog(@"LoadMore…");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark –
#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)reloadTableViewDataSource{
    _reloading = YES;
}

- (void)doneLoadingTableViewData{
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:msgScrollView];
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self reloadTableViewDataSource];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.0];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    return _reloading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UIButton* bb in deleteBtArray) {
        if (!bb.hidden) {
            bb.hidden = YES;
        }
    }
}


@end
