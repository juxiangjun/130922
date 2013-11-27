//
//  AnnDetailViewController.m
//  DYT
//
//  Created by zhaoliang.chen on 13-7-15.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "AnnDetailViewController.h"
#import "TKImageCache.h"

@interface AnnDetailViewController ()

@end

@implementation AnnDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _recvAnnImg = [[TKImageCache alloc] initWithCacheDirectoryName:@"activity"];
        _recvAnnImg.notificationName = @"recvAnnImg";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvAnnImgOnAnnDetail:) name:@"recvAnnImgOnAnnDetail" object:nil];
    }
    return self;
}

-(id)initWithObj:(AnnObject*)obj {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        m_Obj = obj;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.navigationController.navigationBar setBackgroundImage:getBundleImage(@"navBG.png") forBarMetrics:UIBarMetricsDefault];
    self.view.backgroundColor = [UIColor colorWithPatternImage:getBundleImage(@"loginBG.png")];
    self.title = @"公告详细";
    
    UIButton *button1 = getButtonByImageName(@"btBack.png");
    [button1 addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn1 = [[UIBarButtonItem alloc] initWithCustomView:button1];
    self.navigationItem.leftBarButtonItem = btn1;
    
    detailScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-self.navigationController.navigationBar.height-self.tabBarController.tabBar.height)];
    detailScrollView.userInteractionEnabled = YES;
    detailScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:detailScrollView];
    
    [self createScrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_recvAnnImg cancelOperations];
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createScrollView {
    UILabel* timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, detailScrollView.width, 20)];
    timeLabel.centerX = detailScrollView.width/2;
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.textColor = [UIColor colorWithRed:170.0/255.0 green:170.0/255.0 blue:170.0/255.0 alpha:1.0f];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.font = [UIFont systemFontOfSize:12];
    if ([m_Obj.publishTime isKindOfClass:[NSString class]] && m_Obj.publishTime.length>0) {
        timeLabel.text = m_Obj.publishTime;
    }
    [detailScrollView addSubview:timeLabel];
    
    float myH = 0.0f;
    UIView* bg = [[UIView alloc]initWithFrame:CGRectMake(0, timeLabel.bottom+10, detailScrollView.width-20, 50)];
    bg.centerX = detailScrollView.width/2;
    bg.layer.cornerRadius = 8.0f;
    bg.backgroundColor = [UIColor whiteColor];
    [detailScrollView addSubview:bg];
    
    UILabel* title = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, bg.width-20, 24)];
    title.centerX = bg.width/2;
    title.backgroundColor = [UIColor clearColor];
    title.textColor = [UIColor blackColor];
    title.font = [UIFont systemFontOfSize:18];
    if (![m_Obj.title isKindOfClass:[NSNull class]] && m_Obj.title.length>0) {
        title.text = m_Obj.title;
    }
    [bg addSubview:title];
    title.numberOfLines = 0;
    title.lineBreakMode = NSLineBreakByCharWrapping;
    CGSize size = CGSizeMake(title.width,2000);
    CGSize labelsize = [title.text sizeWithFont:title.font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
    title.frame = CGRectMake(title.left, title.top, title.width, labelsize.height);
    title.textAlignment = NSTextAlignmentCenter;
    myH = title.bottom;
    
    if ((![m_Obj.picURL isKindOfClass:[NSNull class]]&&m_Obj.picURL.length>0)||(![m_Obj.videoURL isKindOfClass:[NSNull class]]&&m_Obj.videoURL.length>0)) {
        picView = [[UIImageView alloc]initWithFrame:CGRectMake(0, myH+10, bg.width-20, 180)];
        picView.centerX = bg.width/2;
        picView.userInteractionEnabled = YES;
        [bg addSubview:picView];
        
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicator.frame = picView.frame;
        activityIndicator.left = 0;
        activityIndicator.top = 0;
        [activityIndicator startAnimating];
        activityIndicator.tag = 99;
        [picView addSubview:activityIndicator];
        picView.backgroundColor = [UIColor grayColor];
        
        if (![m_Obj.videoURL isKindOfClass:[NSNull class]]&&m_Obj.videoURL.length>0) {
            NSURL *url = [NSURL URLWithString:getPicNameALL(m_Obj.videoPic) ];
            UIImage *img = [_recvAnnImg imageForKey:[getPicNameALL(m_Obj.videoPic) lastPathComponent]                                          url:url queueIfNeeded:YES];
            if (img) {
                [activityIndicator stopAnimating];
                [activityIndicator removeFromSuperview];
                
                double radio = img.size.width/picView.width;
                float newheight = img.size.height/radio;
                [picView setFrame:CGRectMake(picView.left, picView.top, picView.width, newheight)];
            }
            picView.image = img;
            
            playbtn = getButtonByImageName(@"btPlayMovie.png");
            playbtn.center = CGPointMake(picView.width/2, picView.height/2);
            [playbtn addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
            [picView addSubview:playbtn];
        } else if (![m_Obj.picURL isKindOfClass:[NSNull class]]&&m_Obj.picURL.length>0) {
            NSURL *url = [NSURL URLWithString:getPicNameALL(m_Obj.picURL) ];
            UIImage *img = [_recvAnnImg imageForKey:[getPicNameALL(m_Obj.picURL) lastPathComponent]                                          url:url queueIfNeeded:YES tag:picView.tag];
            if (img) {
                [activityIndicator stopAnimating];
                [activityIndicator removeFromSuperview];
                double radio = img.size.width/picView.width;
                float newheight = img.size.height/radio;
                [picView setFrame:CGRectMake(picView.left, picView.top, picView.width, newheight)];
            }
            picView.image = img;
        }
        
        myH = picView.bottom;
    }
    
    UILabel* content = [[UILabel alloc]initWithFrame:CGRectMake(0, myH+10, bg.width-20, 10)];
    content.centerX = bg.width/2;
    content.backgroundColor = [UIColor clearColor];
    content.textColor = [UIColor colorWithRed:64.0/255.0 green:64.0/255.0 blue:64.0/255.0 alpha:1.0f];
    content.textAlignment = NSTextAlignmentLeft;
    content.numberOfLines = 4;
    content.font = [UIFont systemFontOfSize:12];
    content.text = m_Obj.content;
    content.numberOfLines = 0;
    content.lineBreakMode = NSLineBreakByCharWrapping;
    content.tag = 10000;
    size = CGSizeMake(content.width,2000);
    //计算实际frame大小，并将label的frame变成实际大小
    labelsize = [content.text sizeWithFont:content.font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
    content.frame = CGRectMake(content.left, content.top, content.width, labelsize.height);
    [bg addSubview:content];
    myH = content.bottom;

    bg.height = myH+10;
    detailScrollView.contentSize = CGSizeMake(detailScrollView.width, bg.bottom+10);
}

- (void)recvAnnImgOnAnnDetail:(NSNotification*)sender {
    NSDictionary *dict = [sender userInfo];
    UIImage *img = [dict objectForKey:@"image"];
    for (UIView* v in detailScrollView.subviews) {
        if ([v isKindOfClass:[UIImageView class]]) {
            UIImageView* imgView = (UIImageView*)v;
            UIActivityIndicatorView *activity = (UIActivityIndicatorView *)[imgView viewWithTag:99];
            [activity stopAnimating];
            [activity removeFromSuperview];
            float oldHeight = imgView.height;
            double radio = img.size.width/imgView.width;
            float newheight = img.size.height/radio;
            float distance = newheight-oldHeight;
            [imgView setFrame:CGRectMake(imgView.left, imgView.top, imgView.width, newheight)];
            
            imgView.superview.height += distance;
            detailScrollView.contentSize = CGSizeMake(detailScrollView.width, detailScrollView.height+distance);
            for (UIView* v in imgView.superview.subviews) {
                if ([v isKindOfClass:[UILabel class]]&&v.tag==10000) {
                    v.top = imgView.bottom+5;
                    break;
                }
            }
            imgView.image = img;
        }
    }
}

- (void)playVideo:(id)sender{
    UIButton* b = (UIButton* )sender;
    if (m_Obj.videoURL.length == 0) {
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
    //[mp setFullscreen:YES];
    
    NSURL *movieURL = [NSURL URLWithString:getPicNameALL(m_Obj.videoURL)];
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
        
        playbtn.hidden = YES;
        
		[[mp view] setFrame:picView.frame];
        [mp view].top = 0;
        [mp view].left = 0;
        
        [picView addSubview:[mp view]];
        
		[mp play];
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
    }
}


@end
