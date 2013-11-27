//
//  PictureViewController.m
//  DYT
//
//  Created by zhaoliang.chen on 13-7-2.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "PictureViewController.h"
#import "TKImageCache.h"

@interface PictureViewController (){
    NSMutableArray *pics_;
    int flag ;
}

@end

@implementation PictureViewController

#define PICURLTAG       1000
#define SCROLLVIEWTAG   2000

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _recvBigPic = [[TKImageCache alloc] initWithCacheDirectoryName:@"activity"];
        _recvBigPic.notificationName = @"recvBigPic";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvBigPic:) name:@"recvBigPic" object:nil];
        flag = 0;
        m_nOldPage = -1;
    }
    return self;
}

- (id)initWithObj:(NSArray*)array whitIndex:(int)index {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        arrayChat = array;
        m_nIndex = index;
        m_PicType = chatPic;
    }
    return self;
}


- (id)initWithGroupPicData:(NSArray*)array whitIndex:(int)index {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        arrayChat = array;
        m_nIndex = index;
        m_PicType = groupPic;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.wantsFullScreenLayout = YES;
    [self.navigationController.navigationBar setBackgroundImage:getBundleImage(@"navBG.png") forBarMetrics:UIBarMetricsDefault];
    self.title = [NSString stringWithFormat:@"%d/%d",m_nIndex+1,arrayChat.count]; 
    
    UIButton *button1 = getButtonByImageName(@"btBack.png");
    [button1 addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn1 = [[UIBarButtonItem alloc] initWithCustomView:button1];
    self.navigationItem.leftBarButtonItem = btn1;
    
    UIButton *button2 = getButtonByImageName(@"savePic.png");
    [button2 addTarget:self action:@selector(goSave) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn2 = [[UIBarButtonItem alloc] initWithCustomView:button2];
    self.navigationItem.rightBarButtonItem = btn2;    
    
	// Do any additional setup after loading the view.
    CGRect rc = [UIScreen mainScreen].bounds;
    mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, rc.size.width, rc.size.height)];
    mainScrollView.backgroundColor = [UIColor blackColor];
    mainScrollView.pagingEnabled = YES;
    mainScrollView.delegate = self;
    mainScrollView.userInteractionEnabled = YES;
    mainScrollView.contentSize = CGSizeMake(mainScrollView.width*arrayChat.count, mainScrollView.height);    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTap:)];    [mainScrollView addGestureRecognizer:tap];    
    [self.view addSubview:mainScrollView];
    
    mainScrollView.top = -self.navigationController.navigationBar.height-20;
    
    pics_ = [NSMutableArray array];
    if (m_PicType == chatPic) {
        for (int i=0; i<arrayChat.count; i++) {
            ChatObject* obj = [arrayChat objectAtIndex:i];
            UIScrollView* imgScrollView = [[UIScrollView alloc]initWithFrame:mainScrollView.bounds];
            imgScrollView.left = i*imgScrollView.width;
            imgScrollView.tag = SCROLLVIEWTAG+i;
            imgScrollView.minimumZoomScale = 1;
            imgScrollView.maximumZoomScale = 3;
            imgScrollView.userInteractionEnabled = YES;
            imgScrollView.delegate = self;
            
            [mainScrollView addSubview:imgScrollView];
            
            UIImageView* imgView = [[UIImageView alloc]initWithFrame:mainScrollView.frame];
            imgView.top = 0;
            imgView.left = 0;
            imgView.tag = PICURLTAG+i;
            imgView.userInteractionEnabled = YES;
            [imgScrollView addSubview:imgView];
            imgView.contentMode = UIViewContentModeScaleAspectFit;
            largeHeight = imgView.height;
            
            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            activityIndicator.frame = imgView.frame;
            activityIndicator.backgroundColor = [UIColor clearColor];
            [activityIndicator startAnimating];
            activityIndicator.tag = 99;
            [imgView addSubview:activityIndicator];
            
            NSURL *url = [NSURL URLWithString:getPicNameALL(obj.content)];
            NSLog(@"%@",url);
            UIImage *img = nil;
            
            if (fabs(i-m_nIndex)<=1) {
                if (url==nil) {
                    img = [UIImage imageWithContentsOfFile:obj.content];
                }else{
                    NSString *path = [get_thumbPic_Path() stringByAppendingPathComponent:[obj.content lastPathComponent]];
                    if ([[NSFileManager defaultManager]fileExistsAtPath:path]) {
                        img = [UIImage imageWithContentsOfFile:path];
                    }else{
                        if (m_nIndex==i) {
                            img = [_recvBigPic imageForKey:[obj.content lastPathComponent] url:url queueIfNeeded:YES tag:imgView.tag];
                        }
                    }
                }
            }
            
            
            if (img) {
                [activityIndicator stopAnimating];
                [activityIndicator removeFromSuperview];
                if (img.size.width>320) {
                    double radio = img.size.width/320;
                    float height = img.size.height/radio;
                    [imgView setFrame:CGRectMake(0, 0, 320, height)];
                    if (height<=imgScrollView.height) {
                        imgView.center = CGPointMake(imgScrollView.width/2, imgScrollView.height/2);
                    }
                    if (height>imgScrollView.height) {
                        imgScrollView.contentSize = CGSizeMake(imgScrollView.width, height);
                    }
                } else {
                    double radio = 320/img.size.width;
                    float height = img.size.height*radio;
                    [imgView setFrame:CGRectMake(0, 0, 320, height)];
                    if (height<=imgScrollView.height) {
                        imgView.center = CGPointMake(imgScrollView.width/2, imgScrollView.height/2);
                    }
                    if (height>imgScrollView.height) {
                        imgScrollView.contentSize = CGSizeMake(imgScrollView.width, height);
                    }
                }
                imgView.image = img;
            } else {
                NSString* path = [NSString stringWithFormat:@"%@/%@",get_thumbPic_Path(),[obj.thumbURL lastPathComponent]];
                if (file_exists(path)) {
                    imgView.image = nil;
                    UIImageView* thumbView = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:path]];
                    thumbView.frame = CGRectMake(0, 0, 80, 80);
                    thumbView.center = CGPointMake(rc.size.width/2, rc.size.height/2);
                    thumbView.tag = 9999;
                    [imgView addSubview:thumbView];
                    [imgView sendSubviewToBack:thumbView];
                }
            }
            [pics_ addObject:imgView];
        }
    } else {
        for (int i=0; i<arrayChat.count; i++) {
            GroupPicData* obj = [arrayChat objectAtIndex:i];
            UIScrollView* imgScrollView = [[UIScrollView alloc]initWithFrame:mainScrollView.bounds];
            imgScrollView.left = i*imgScrollView.width;
            imgScrollView.tag = SCROLLVIEWTAG+i;
            imgScrollView.minimumZoomScale = 1;
            imgScrollView.maximumZoomScale = 3;
            imgScrollView.userInteractionEnabled = YES;
            imgScrollView.delegate = self;
            
            [mainScrollView addSubview:imgScrollView];
            
            UIImageView* imgView = [[UIImageView alloc]initWithFrame:mainScrollView.frame];
            imgView.tag = PICURLTAG+i;
            imgView.userInteractionEnabled = YES;
            [imgScrollView addSubview:imgView];
            //imgView.contentMode = UIViewContentModeCenter;
            largeHeight = imgView.height;
            
            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            activityIndicator.frame = imgView.frame;
            activityIndicator.backgroundColor = [UIColor clearColor];
            activityIndicator.top = 0;
            activityIndicator.left = 0;
            [activityIndicator startAnimating];
            activityIndicator.tag = 99;
            [imgView addSubview:activityIndicator];
            
            NSURL *url = [NSURL URLWithString:getPicNameALL(obj.picURL)];
            UIImage *img = nil;
            if (url==nil) {
                img = [UIImage imageWithContentsOfFile:obj.picURL];
            }else{
                img = [_recvBigPic imageForKey:[obj.picURL lastPathComponent] url:url queueIfNeeded:YES tag:imgView.tag];
            }
            
            if (img) {
                [activityIndicator stopAnimating];
                [activityIndicator removeFromSuperview];
                if (img.size.width>320) {
                    double radio = img.size.width/320;
                    float height = img.size.height/radio;
                    [imgView setFrame:CGRectMake(0, 0, 320, height)];
                    if (imgView.height>largeHeight) {
                        radio = imgView.height/largeHeight;
                        float width = imgView.width/radio;
                        [imgView setFrame:CGRectMake(0, 0, width, largeHeight)];
                    }
                    imgView.center = CGPointMake(imgScrollView.width/2, imgScrollView.height/2);
                    imgScrollView.contentSize = CGSizeMake(imgScrollView.width, imgScrollView.height);
                } else {
                    double radio = 320/img.size.width;
                    float height = img.size.height*radio;
                    [imgView setFrame:CGRectMake(0, 0, 320, height)];
                    if (imgView.height>imgScrollView.height) {
                        imgView.top=0;
                        imgScrollView.contentSize = CGSizeMake(imgScrollView.width, imgView.height);
                    } else {
                        imgView.center = CGPointMake(imgScrollView.width/2, imgScrollView.height/2);
                        imgScrollView.contentSize = CGSizeMake(mainScrollView.width, mainScrollView.height);
                    }
                }
                imgView.image = img;
            } else {
                NSString* path = [NSString stringWithFormat:@"%@/%@",get_thumbPic_Path(),[obj.thumbURL lastPathComponent]];
                if (file_exists(path)) {
                    imgView.image = nil;
                    UIImageView* thumbView = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:path]];
                    thumbView.frame = CGRectMake(0, 0, 80, 80);
                    thumbView.center = CGPointMake(rc.size.width/2, rc.size.height/2);
                    thumbView.tag = 9999;
                    [imgView addSubview:thumbView];
                    [imgView bringSubviewToFront:activityIndicator];
                }
            }
            [pics_ addObject:imgView];
        }        
    }
    
    [mainScrollView setContentOffset:CGPointMake(m_nIndex*mainScrollView.width, 0)];
}

- (void)onTap:(UITapGestureRecognizer*)sender {
    if(flag==0){
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        [self.navigationController setNavigationBarHidden:YES];
        flag = 1;
        mainScrollView.top = 0;        
    }
    else{
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        [self.navigationController setNavigationBarHidden:NO];
        flag = 0;
        mainScrollView.top = -self.navigationController.navigationBar.height-20;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_recvBigPic cancelOperations];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];    
}

- (void)goSave {
    saveActionSheet = [[UIActionSheet alloc]
                      initWithTitle:@"图片操作"
                      delegate:self
                      cancelButtonTitle:@"取消"
                      destructiveButtonTitle:nil
                      otherButtonTitles:/*@"转发",*/ @"保存到相册",nil];
    saveActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [saveActionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)recvBigPic:(NSNotification*)sender {
    NSDictionary *dict = [sender userInfo];
    UIImage *img = [dict objectForKey:@"image"];
    int tag = [[dict objectForKey:@"tag"] intValue];
    
//    if (fabs(tag - PICURLTAG - m_nIndex)>1) {
//        return;
//    }
    
    UIScrollView* s = (UIScrollView*)[mainScrollView viewWithTag:tag-PICURLTAG+SCROLLVIEWTAG];
    UIImageView* imgView = (UIImageView*)[s viewWithTag:tag];
    UIActivityIndicatorView* activityIndicator = (UIActivityIndicatorView*)[imgView viewWithTag:99];
    [activityIndicator stopAnimating];
    [activityIndicator removeFromSuperview];
    UIImageView* thumbView = (UIImageView*)[imgView viewWithTag:9999];
    [thumbView removeFromSuperview];
    if (img.size.width>320) {
        double radio = img.size.width/320;
        float height = img.size.height/radio;
        [imgView setFrame:CGRectMake(0, 0, 320, height)];
        if (height<=s.height) {
            imgView.center = CGPointMake(s.width/2, s.height/2);
        }
        if (height>s.height) {
            s.contentSize = CGSizeMake(s.width, height);
        }
    } else {
        double radio = 320/img.size.width;
        float height = img.size.height*radio;
        [imgView setFrame:CGRectMake(0, 0, 320, height)];
        if (height<=s.height) {
            imgView.center = CGPointMake(s.width/2, s.height/2);
        }
        if (height>s.height) {
            s.contentSize = CGSizeMake(s.width, height);
        }
    }
    imgView.image = img;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    if (scrollView!=mainScrollView) {
        int tag = scrollView.tag;
        UIScrollView* scaleScroll = (UIScrollView*)[mainScrollView viewWithTag:tag];
        return (UIImageView*)[scaleScroll viewWithTag:tag-SCROLLVIEWTAG+PICURLTAG];
    }
    return nil;
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    if (scrollView.zoomScale>1.0f) {
        CGFloat xcenter = scrollView.center.x , ycenter = scrollView.center.y;
        //目前contentsize的width是否大于原scrollview的contentsize，如果大于，设置imageview中心x点为contentsize的一半，以固定imageview在该contentsize中心。如果不大于说明图像的宽还没有超出屏幕范围，可继续让中心x点为屏幕中点，此种情况确保图像在屏幕中心。
        xcenter = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width/2 : xcenter;
        //同上，此处修改y值
        ycenter = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height/2 : ycenter;
        [(UIImageView*)[scrollView viewWithTag:scrollView.tag-SCROLLVIEWTAG+PICURLTAG] setCenter:CGPointMake(xcenter, ycenter)];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        [self updatePage:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self updatePage:scrollView];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {

}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if (scrollView == mainScrollView) {
//        int page = floor((mainScrollView.contentOffset.x+mainScrollView.width/2) / mainScrollView.width );
//        if (m_nOldPage != page) {
//            for (UIView *v in mainScrollView.subviews) {
//                if ([v isKindOfClass:[UIScrollView class]]) {
//                    UIScrollView* vv = (UIScrollView*)v;
//                    if (vv.zoomScale!=1.0f) {
//                        vv.zoomScale=1.0f;
//                        vv.contentSize = CGSizeMake(mainScrollView.width, mainScrollView.height);
//                        [(UIImageView*)[vv viewWithTag:vv.tag-SCROLLVIEWTAG+PICURLTAG] setCenter:CGPointMake(vv.width/2, vv.height/2)];
//                    }
//                }
//            }
//        }
//        m_nOldPage = page;
//        self.title = [NSString stringWithFormat:@"%d/%d",page+1,arrayChat.count];
//        m_nIndex = page;
//        [self updatePage:scrollView];
//    }
//}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存成功" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)updatePage:(UIScrollView *)scrollview{
    int idx = 0;
    
    int page = floor((mainScrollView.contentOffset.x+mainScrollView.width/2) / mainScrollView.width );
    m_nIndex = page;
    self.title = [NSString stringWithFormat:@"%d/%d",page+1,arrayChat.count];
    if (m_nOldPage != page) {
        for (UIView *v in mainScrollView.subviews) {
            if ([v isKindOfClass:[UIScrollView class]]) {
                UIScrollView* vv = (UIScrollView*)v;
                if (vv.zoomScale!=1.0f) {
                    vv.zoomScale=1.0f;
                    vv.contentSize = CGSizeMake(mainScrollView.width, mainScrollView.height);
                    [(UIImageView*)[vv viewWithTag:vv.tag-SCROLLVIEWTAG+PICURLTAG] setCenter:CGPointMake(vv.width/2, vv.height/2)];
                }
            }
        }
    }
    m_nOldPage = page;
    for (UIImageView *v in pics_) {
        if (fabs(m_nIndex - idx)>1) {
            v.image = nil;
        }else{
            int t = v.tag - PICURLTAG;
            if (m_PicType == chatPic) {
                ChatObject* obj = [arrayChat objectAtIndex:t];
                
                
                NSURL *url = [NSURL URLWithString:getPicNameALL(obj.content)];
                UIImage *img = nil;
                if (url==nil) {
                    img = [UIImage imageWithContentsOfFile:obj.content];
                }else{
                    
                    NSString *path = [get_thumbPic_Path() stringByAppendingPathComponent:[obj.content lastPathComponent]];
                    if ([[NSFileManager defaultManager]fileExistsAtPath:path]) {
                        img = [UIImage imageWithContentsOfFile:path];
                    }else{
                        if (m_nIndex==idx) {
                            img = [_recvBigPic imageForKey:[obj.content lastPathComponent] url:url queueIfNeeded:YES tag:v.tag];
                        }
                    }
                }
                if (img) {
                    v.image = img;
                    UIActivityIndicatorView* activityIndicator = (UIActivityIndicatorView*)[v viewWithTag:99];
                    [activityIndicator stopAnimating];
                    [activityIndicator removeFromSuperview];
                    UIImageView* thumbView = (UIImageView*)[v viewWithTag:9999];
                    [thumbView removeFromSuperview];
                } else {
//                    NSString* path = [NSString stringWithFormat:@"%@/%@",get_thumbPic_Path(),[obj.thumbURL lastPathComponent]];
//                    if (file_exists(path)) {
//                        v.image = [UIImage imageWithContentsOfFile:path];
//                    }
                }
            } else {                
                GroupPicData* obj = [arrayChat objectAtIndex:t];
                NSURL *url = [NSURL URLWithString:getPicNameALL(obj.picURL)];
                UIImage *img = [_recvBigPic imageForKey:[obj.picURL lastPathComponent] url:url queueIfNeeded:YES tag:v.tag];
                if (img) {
                    v.image = img;
                } else {
//                    NSString* path = [NSString stringWithFormat:@"%@/%@",get_thumbPic_Path(),[obj.thumbURL lastPathComponent]];
//                    if (file_exists(path)) {
//                        v.image = [UIImage imageWithContentsOfFile:path];
//                    }
                }
            }
        }
        idx++;
    }
}

#pragma mark UIActionSheet的代理
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet == saveActionSheet) {
        if (buttonIndex==1) {
            return ;
        }
        if (buttonIndex == 2) {
            
        } else if (buttonIndex == 0) {
            UIScrollView* s = (UIScrollView*)[mainScrollView viewWithTag:m_nIndex+SCROLLVIEWTAG];
            UIImageView* imgView = (UIImageView*)[s viewWithTag:m_nIndex+PICURLTAG];
            
            UIImageWriteToSavedPhotosAlbum(imgView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
    }
}

//returen YES,这样才可以让多手势并存，否则只会相应一种手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

-(void)scale:(UIPinchGestureRecognizer*)sender {
    if([sender state] == UIGestureRecognizerStateBegan) {
        lastScale = 1.0;
    }
    
    if ([sender state] == UIGestureRecognizerStateChanged) {
        CGFloat scale = 1.0 - (lastScale - [(UIPinchGestureRecognizer*)sender scale]);
        CGAffineTransform currentTransform = sender.view.transform;
        //Scale的仿射变换，只改变缩放比例，其他仿射变换底下会说
        CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
        [sender.view setTransform:newTransform];
        lastScale = [sender scale];
    }
}


@end
