//
//  AnnViewController.h
//  DYT
//
//  Created by zhaoliang.chen on 13-6-3.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import <MediaPlayer/MediaPlayer.h>

@class TKImageCache;
@interface AnnViewController : UIViewController
<EGORefreshTableHeaderDelegate,UIScrollViewDelegate>{
    int height;
    UIScrollView* annScrollView;
    int pageNum;
    int pageTotal;
    NSMutableArray* arrayAnn;
    TKImageCache* _recvAnnImg;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    BOOL isUpdate;
    MPMoviePlayerController *mp;
    UIButton* playbtn;
    BOOL isScrollToBottom;
}

@end
