//
//  AnnDetailViewController.h
//  DYT
//
//  Created by zhaoliang.chen on 13-7-15.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@class TKImageCache;
@interface AnnDetailViewController : UIViewController {
    AnnObject* m_Obj;
    UIScrollView* detailScrollView;
    TKImageCache* _recvAnnImg;
    MPMoviePlayerController *mp;
    UIButton* playbtn;
    UIImageView* picView;
}

-(id)initWithObj:(AnnObject*)obj;

@end
