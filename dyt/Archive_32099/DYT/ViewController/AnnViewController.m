//
//  AnnViewController.m
//  DYT
//
//  Created by zhaoliang.chen on 13-6-3.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "AnnViewController.h"
#import "TKImageCache.h"
#import "AnnDetailViewController.h"
#import "HeadphonesDetector.h"

@interface AnnViewController (){
    UIActivityIndicatorView *active;
}

@end

@implementation AnnViewController

#define ANNIMGTAG       1000
#define PLAYBTNTAG      2000
#define MOVIETAG        3000
#define TIMELABLETAG    10000
#define ANNBGTAG        20000
#define CONTENTTAG      30000

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"公告" image:[UIImage imageNamed:@"btNotice.png"] tag:2];
        //[tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"btNoticeH.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"btNotice.png"]];
        self.tabBarItem = tabBarItem;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseAudio:) name:@"pauseAudio" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(continueAudio:) name:@"continueAudio" object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];    
    _recvAnnImg = [[TKImageCache alloc] initWithCacheDirectoryName:@"activity"];
    _recvAnnImg.notificationName = @"recvAnnImg";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvAnnImg:) name:@"recvAnnImg" object:nil];
	// Do any additional setup after loading the view.
    [self.navigationController.navigationBar setBackgroundImage:getBundleImage(@"navBG.png") forBarMetrics:UIBarMetricsDefault];
    self.view.backgroundColor = [UIColor colorWithPatternImage:getBundleImage(@"loginBG.png")];
    self.title = @"公告";
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    annScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-self.navigationController.navigationBar.height-self.tabBarController.tabBar.height)];
    annScrollView.userInteractionEnabled = YES;
    annScrollView.delegate = self;
    annScrollView.backgroundColor = [UIColor clearColor];
    annScrollView.alwaysBounceVertical = YES;
    [self.view addSubview:annScrollView];
    
    if (_refreshHeaderView == nil) {
        _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -80, annScrollView.width, 80)];
        _refreshHeaderView.delegate = self;
        [annScrollView addSubview:_refreshHeaderView];
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    
    arrayAnn = [NSMutableArray new];
    pageNum = 0;
    pageTotal = 0;
    height = 10;
    isUpdate = NO;
    isScrollToBottom = NO;
    
    //arrayAnn = [AnnObject loadAnnList:pageNum];
    
    [self getAnnList];    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_recvAnnImg cancelOperations];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"proximityChanged" object:nil];
    UIDevice *device = [UIDevice currentDevice];
    [device setProximityMonitoringEnabled:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proximityChanged:) name:UIDeviceProximityStateDidChangeNotification object:device];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"proximityChanged" object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return UIDeviceOrientationIsLandscape(toInterfaceOrientation);
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)getAnnList {
    [WaitTooles showHUD:@"加载中..."];
    [[WebServiceManager sharedManager] getNoticeList:pageNum encodeStr:[[DataManager sharedManager]getUser].encodeStr completion:^(NSDictionary* dic1) {
        [WaitTooles removeHUD];
        int success = [[dic1 objectForKey:@"success"]intValue];
        if (success == 1) {            
            NSDictionary* dic2 = [dic1 objectForKey:@"obj"];
            NSArray *array = [dic2 objectForKey:@"news"];
            pageTotal = [[dic2 objectForKey:@"totalCount"]intValue];
            if ([array isKindOfClass:[NSArray class]]) {
                for (int i=0; i<array.count; i++) {
                    NSDictionary *dic3 = [array objectAtIndex:i];
                    AnnObject* one = [AnnObject getOneAnnObject:dic3];
                    [arrayAnn addObject:one];
                    if ([AnnObject findAnnByID:one.annID]==nil) {
                        [AnnObject addOneAnn:one];
                    }
                }
            }
            [self createScrollView];
            isScrollToBottom = NO;
            pageNum+=NOTICELIMIT;
        } else {
            if ([[dic1 objectForKey:@"returnCode"]intValue]==101) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息" message:@"你的账号已经在别处登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"backToRoot" object:nil];
            }
        }
    }];
}

- (void)createScrollView {
    if (isUpdate) {
        for (UIView* v in annScrollView.subviews) {
            if (![v isKindOfClass:[EGORefreshTableHeaderView class]]&&v.tag>100) {
                [v removeFromSuperview];
            }
        }
    }
    isUpdate = NO;
    for (int i=pageNum/**NOTICELIMIT*/; i<arrayAnn.count; i++) {
        AnnObject *one = [arrayAnn objectAtIndex:i];
        
        UILabel* timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, height, annScrollView.width, 20)];
        timeLabel.centerX = annScrollView.width/2;
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textColor = [UIColor colorWithRed:170.0/255.0 green:170.0/255.0 blue:170.0/255.0 alpha:1.0f];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.font = [UIFont systemFontOfSize:12];
        if ([one.publishTime isKindOfClass:[NSString class]] && one.publishTime.length>0) {
            timeLabel.text = one.publishTime;
        }
        [annScrollView addSubview:timeLabel];
        timeLabel.tag = TIMELABLETAG+i;
        
        float myH = 0.0f;
        UIView* bg = [[UIView alloc]initWithFrame:CGRectMake(0, timeLabel.bottom+10, annScrollView.width-20, 50)];
        bg.centerX = annScrollView.width/2;
        bg.layer.cornerRadius = 8.0f;
        bg.backgroundColor = [UIColor whiteColor];
        [annScrollView addSubview:bg];
        bg.tag = ANNBGTAG+i;
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gotoAnnDetail:)];
        [bg addGestureRecognizer:tap];
        
        UILabel* title = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, bg.width-20, 24)];
        title.centerX = bg.width/2;
        title.backgroundColor = [UIColor clearColor];
        title.textColor = [UIColor blackColor];
        title.font = [UIFont systemFontOfSize:18];
        if (![one.title isKindOfClass:[NSNull class]] && one.title.length>0) {
            title.text = one.title;
        }
        [bg addSubview:title];
//        title.numberOfLines = 0;
//        title.lineBreakMode = NSLineBreakByCharWrapping;
//        CGSize size = CGSizeMake(title.width,2000);
//        CGSize labelsize = [title.text sizeWithFont:title.font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
//        title.frame = CGRectMake(title.left, title.top, title.width, labelsize.height);
        title.textAlignment = NSTextAlignmentCenter;
        myH = title.bottom;
        
        if ((![one.picURL isKindOfClass:[NSNull class]]&&one.picURL.length>0)||(![one.videoURL isKindOfClass:[NSNull class]]&&one.videoURL.length>0)) {
            UIImageView* imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, myH+10, bg.width-20, 180)];
            imgView.centerX = bg.width/2;
            imgView.tag = ANNIMGTAG+i;
            imgView.userInteractionEnabled = YES;
            [bg addSubview:imgView];
            
            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            activityIndicator.frame = imgView.frame;
            activityIndicator.left = 0;
            activityIndicator.top = 0;
            [activityIndicator startAnimating];
            activityIndicator.tag = 99;
            [imgView addSubview:activityIndicator];
            imgView.backgroundColor = [UIColor grayColor];
            
            if (![one.videoURL isKindOfClass:[NSNull class]]&&one.videoURL.length>0) {
                NSURL *url = [NSURL URLWithString:getPicNameALL(one.videoPic) ];
                UIImage *img = [_recvAnnImg imageForKey:[getPicNameALL(one.videoPic) lastPathComponent]                                          url:url queueIfNeeded:YES tag:imgView.tag];
                if (img) {
                    [activityIndicator stopAnimating];
                    [activityIndicator removeFromSuperview];
                    
                    double radio = img.size.width/imgView.width;
                    float newheight = img.size.height/radio;
                    [imgView setFrame:CGRectMake(imgView.left, imgView.top, imgView.width, newheight)];
                }
                imgView.image = img;
                
                UIButton* btPlay = getButtonByImageName(@"btPlayMovie.png");
                btPlay.tag = PLAYBTNTAG+i;
                btPlay.center = CGPointMake(imgView.width/2, imgView.height/2);
                [btPlay addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
                [imgView addSubview:btPlay];
             } else if (![one.picURL isKindOfClass:[NSNull class]]&&one.picURL.length>0) {
                 NSURL *url = [NSURL URLWithString:getPicNameALL(one.picURL) ];
                 UIImage *img = [_recvAnnImg imageForKey:[getPicNameALL(one.picURL) lastPathComponent]                                          url:url queueIfNeeded:YES tag:imgView.tag];
                 if (img) {
                     [activityIndicator stopAnimating];
                     [activityIndicator removeFromSuperview];                     
                     double radio = img.size.width/imgView.width;
                     float newheight = img.size.height/radio;
                     [imgView setFrame:CGRectMake(imgView.left, imgView.top, imgView.width, newheight)];
                 }
                 imgView.image = img;
             }
            
            myH = imgView.bottom;
        }
        
        UILabel* content = [[UILabel alloc]initWithFrame:CGRectMake(0, myH+10, bg.width-20, 15)];
        content.centerX = bg.width/2;
        content.backgroundColor = [UIColor clearColor];
        content.textColor = [UIColor colorWithRed:64.0/255.0 green:64.0/255.0 blue:64.0/255.0 alpha:1.0f];
        content.textAlignment = NSTextAlignmentLeft;
        content.font = [UIFont systemFontOfSize:12];
        content.text = one.content;
        content.tag = CONTENTTAG+i;
//        content.numberOfLines = 0;
//        content.lineBreakMode = NSLineBreakByCharWrapping;
//        size = CGSizeMake(content.width,2000);
//        //计算实际frame大小，并将label的frame变成实际大小
//        labelsize = [content.text sizeWithFont:content.font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
//        content.frame = CGRectMake(content.left, content.top, content.width, labelsize.height);
        [bg addSubview:content];
        myH = content.bottom;
        
        CGRect rc = bg.frame;
        rc.size.height = myH+10;
        bg.frame = rc;
        height = bg.bottom+10;
    }
    annScrollView.contentSize = CGSizeMake(annScrollView.width, height);
}

- (void)playVideo:(id)sender{
    UIButton* b = (UIButton* )sender;
    AnnObject* obj = [arrayAnn objectAtIndex:b.tag-PLAYBTNTAG];
    if (obj.videoURL.length == 0) {
        return ;
    }
    if (mp) {
        [mp.view removeFromSuperview];
        mp = nil;
        playbtn.hidden = NO;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    }
    playbtn = b;
    playbtn.hidden = YES;
    if (active) {
        [active removeFromSuperview];
    }
    active = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [active startAnimating];
    [playbtn.superview addSubview:active];
    active.frame = playbtn.frame;
    //[mp setFullscreen:YES];
    
    NSURL *movieURL = [NSURL URLWithString:getPicNameALL(obj.videoURL)];
    mp =  [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    [mp setControlStyle:MPMovieControlStyleDefault];
    [mp prepareToPlay];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerLoadStateChanged:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieWillFullScreen:)
                                                 name:MPMoviePlayerWillEnterFullscreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieWillExitFullScreen:)
                                                 name:MPMoviePlayerWillExitFullscreenNotification
                                               object:nil];
}

- (void) moviePlayerLoadStateChanged:(NSNotification*)notification {
	// Unless state is unknown, start playback
	if ([mp loadState] != MPMovieLoadStateUnknown) {
        // Remove observer
        [[NSNotificationCenter 	defaultCenter]
         removeObserver:self
         name:MPMoviePlayerLoadStateDidChangeNotification
         object:nil];        
        
        //playbtn.hidden = YES;
        
        UIImageView* videoView = (UIImageView*)[annScrollView viewWithTag:playbtn.tag-PLAYBTNTAG+ANNIMGTAG];

		[[mp view] setFrame:videoView.frame];
        [mp view].top = 0;
        [mp view].left = 0;
        
        [videoView addSubview:[mp view]];
        
		[mp play];
        
        //OSStatus s = AudioSessionSetProperty (                                             kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,sizeof (doChangeDefaultRoute),                                             &doChangeDefaultRoute);
    }
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    if (mp.fullscreen) {
        [mp setFullscreen:NO];
    }
    
    [[NSNotificationCenter 	defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:nil];
    
    [self performSelectorOnMainThread:@selector(releaseMP) withObject:nil waitUntilDone:YES];
}

- (void)movieWillFullScreen:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"enableAutoratate" object:[NSNumber numberWithBool:YES]];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
}

- (void)movieWillExitFullScreen:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"enableAutoratate" object:[NSNumber numberWithBool:NO]];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
}

- (void)releaseMP{
    if (mp) {
        [mp stop];
        [mp.view removeFromSuperview];
        mp = nil;
        playbtn.hidden = NO;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"proximityChanged" object:nil];
    }
}

- (void)recvAnnImg:(NSNotification*)sender {
    NSDictionary *dict = [sender userInfo];
    UIImage *img = [dict objectForKey:@"image"];
    int tag = [[dict objectForKey:@"tag"] intValue];
    UIImageView* imgView = (UIImageView*)[annScrollView viewWithTag:tag];    
    UIActivityIndicatorView *activity = (UIActivityIndicatorView *)[imgView viewWithTag:99];
    [activity stopAnimating];
    [activity removeFromSuperview];
    
    float oldHeight = imgView.height;
    double radio = img.size.width/imgView.width;    
    float newheight = img.size.height/radio;
    float distance = newheight-oldHeight;
    [imgView setFrame:CGRectMake(imgView.left, imgView.top, imgView.width, newheight)];
    int bgtag = imgView.superview.tag;
    imgView.superview.height += distance;
    for (UIView* v in imgView.superview.subviews) {
        if ([v isKindOfClass:[UILabel class]]&&v.tag==CONTENTTAG+tag-ANNIMGTAG) {
            v.top = imgView.bottom+5;
            break;
        }
    }
    for (UIView* v in annScrollView.subviews) {
        if (v.tag >= TIMELABLETAG) {
            if ([v isKindOfClass:[UILabel class]]) {
                if ((v.tag-TIMELABLETAG>bgtag-ANNBGTAG) && (v.tag<CONTENTTAG)) {
                    v.top += distance;
                }
            } else {
                if ((v.tag > bgtag) && (v.tag<CONTENTTAG)) {
                    v.top += distance;
                }
            }
        }
    }
    UIView* lastView = (UIView*)[annScrollView viewWithTag:arrayAnn.count-1+ANNBGTAG];
    annScrollView.contentSize = CGSizeMake(annScrollView.width, lastView.bottom+10);
    height+=distance;
    
    imgView.image = img;
}

#pragma mark scrollview的代理
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (isScrollToBottom) {
        return ;
    }
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    CGRect bounds = annScrollView.bounds;
    CGSize size = annScrollView.contentSize;
    UIEdgeInsets inset = annScrollView.contentInset;
    CGFloat currentOffset=annScrollView.contentOffset.y+bounds.size.height-inset.bottom;
    CGFloat maximumOffset = size.height;
    if((maximumOffset-currentOffset)<50.0) {
        isScrollToBottom = YES;
        if (pageNum<pageTotal) {
            [self getAnnList];
        } else {            
            isScrollToBottom = NO;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)reloadTableViewDataSource{
    _reloading = YES;
}

- (void)doneLoadingTableViewData{
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:annScrollView];
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self reloadTableViewDataSource];
    pageNum=0;
    pageTotal=0;
    height=10;
    [arrayAnn removeAllObjects];
    isUpdate=YES;
    [self releaseMP];
    [self getAnnList];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.0];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    return _reloading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date];
}

- (void)gotoAnnDetail:(UITapGestureRecognizer*)sender {
    int tag = sender.view.tag;
    AnnObject* obj = [arrayAnn objectAtIndex:tag-ANNBGTAG];
    AnnDetailViewController* v = [[AnnDetailViewController alloc]initWithObj:obj];
    [self.navigationController pushViewController:v animated:YES];
}

- (void)proximityChanged:(NSNotification*)sender {
    
    if ([[HeadphonesDetector sharedDetector] headphonesArePlugged]) {
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
        AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
    }else{
        UIDevice *device = [UIDevice currentDevice];
        
        OSStatus status = 0;
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        status = AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
        
        
        if ([device proximityState]) {
            
            UInt32 doChangeDefaultRoute = 1;
            status = AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof (doChangeDefaultRoute), &doChangeDefaultRoute);
        }else{
            
            UInt32 doChangeDefaultRoute = 0;
            status = AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof (doChangeDefaultRoute), &doChangeDefaultRoute);
        }
    }
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
}

- (void)pauseAudio:(NSNotification*)sender {
    if (mp) {
        [mp pause];
    }
}

- (void)continueAudio:(NSNotification*)sender {
    if (mp) {
        [mp play];
    }
}


@end
