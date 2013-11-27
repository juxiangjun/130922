//
//  BaseGroupViewController.m
//  DYT
//
//  Created by zhaoliang.chen on 13-6-26.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "BaseGroupViewController.h"
#import "TKImageCache.h"
#import "GroupActViewController.h"
#import "UserDetailViewController.h"
#import "PictureViewController.h"

@interface BaseGroupViewController (){
    CGRect clickPosition_;
}

@end

@implementation BaseGroupViewController

#define USERHEADTAG 1000
#define GROUPPIC    2000

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        startPoint = 10;
        arrayUser = [NSMutableArray new];
        
        _recvGroupHead = [[TKImageCache alloc] initWithCacheDirectoryName:@"activity"];
        _recvGroupHead.notificationName = @"recvGroupHeadOnDetail";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvGroupHeadOnDetail:) name:@"recvGroupHeadOnDetail" object:nil];
        
        _recvUserHead = [[TKImageCache alloc] initWithCacheDirectoryName:@"activity"];
        _recvUserHead.notificationName = @"recvUserHeadOnGroupDetail";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvUserHeadOnGroupDetail:) name:@"recvUserHeadOnGroupDetail" object:nil];
        
        _recvGroupPic = [[TKImageCache alloc] initWithCacheDirectoryName:@"activity"];
        _recvGroupPic.notificationName = @"recvGroupPicOnGroupDetail";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvGroupPicOnGroupDetail:) name:@"recvGroupPicOnGroupDetail" object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.navigationController.navigationBar setBackgroundImage:getBundleImage(@"navBG.png") forBarMetrics:UIBarMetricsDefault];
    self.view.backgroundColor = [UIColor colorWithPatternImage:getBundleImage(@"loginBG.png")];
    self.title = [NSString stringWithFormat:@"%@%@(%d人)",parentName,groupObj.groupName,groupObj.memberCount];
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    UIButton *button1 = getButtonByImageName(@"btBack.png");
    [button1 addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn1 = [[UIBarButtonItem alloc] initWithCustomView:button1];
    self.navigationItem.leftBarButtonItem = btn1;
    
    UIButton *button2 = getButtonByImageName(@"groupPicCamera.png");
    [button2 addTarget:self action:@selector(onCamera) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn2 = [[UIBarButtonItem alloc] initWithCustomView:button2];
    self.navigationItem.rightBarButtonItem = btn2;
    
    mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-self.tabBarController.tabBar.height-self.navigationController.navigationBar.height)];
    mainScrollView.backgroundColor = [UIColor clearColor];
    mainScrollView.userInteractionEnabled = YES;
    [self.view addSubview:mainScrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_recvGroupHead) {
        [_recvGroupHead cancelOperations];
        _recvGroupHead = nil;
    }
    if (_recvUserHead) {
        [_recvUserHead cancelOperations];
        _recvUserHead = nil;
    }
    if (_recvGroupPic) {
        [_recvGroupPic cancelOperations];
        _recvGroupPic = nil;
    }
    if (_recvBigImgOnGroupPic) {
        [_recvBigImgOnGroupPic cancelOperations];
        _recvBigImgOnGroupPic = nil;
    }
}

- (void)createView {
    for (UIView* v in mainScrollView.subviews) {
        if (v.tag > 100) {
            [v removeFromSuperview];
        }
    }
    if (groupObj.arrGroupPic.count > 0) {
        groupPicScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, mainScrollView.width, 60*2+30)];
        groupPicScrollView.userInteractionEnabled = YES;
        groupPicScrollView.backgroundColor = [UIColor clearColor];
        groupPicScrollView.tag = 20000;
        groupPicScrollView.pagingEnabled = YES;
        [mainScrollView addSubview:groupPicScrollView];
        
        for (int i=0; i<groupObj.arrGroupPic.count; i++) {
            GroupPicData* one = [groupObj.arrGroupPic objectAtIndex:i];
            UIImageView* pic = [[UIImageView alloc]initWithFrame:CGRectMake(10+i%4*(70+8)+(i/8)*groupPicScrollView.width, 10+i%8/4*(65+10), 70, 65)];
            pic.tag = GROUPPIC+i;
            pic.layer.cornerRadius = 10.0f;
            
            pic.layer.masksToBounds = NO;
            pic.layer.shouldRasterize = YES;
            pic.layer.rasterizationScale = [UIScreen mainScreen].scale;
            pic.clipsToBounds = YES;
            pic.userInteractionEnabled = YES;
            NSURL *url = [NSURL URLWithString:getPicNameALL(one.thumbURL)];
            UIImage *img = [_recvGroupPic imageForKey:[one.thumbURL lastPathComponent]                                      url:url queueIfNeeded:YES tag:pic.tag];
            if (img) {
                pic.image = img;
            }
            UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapThumb:)];
            [pic addGestureRecognizer:tap];
            [groupPicScrollView addSubview:pic];
        }
        groupPicScrollView.contentSize = CGSizeMake(groupPicScrollView.width*((groupObj.arrGroupPic.count-1)/8+1), groupPicScrollView.height);
        
        startPoint = groupPicScrollView.bottom+10;
        
        UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0, startPoint, mainScrollView.width, 1)];
        line.backgroundColor = [UIColor colorWithRed:190.0/255.0 green:190.0/255.0 blue:190.0/255.0 alpha:1.0f];
        [mainScrollView addSubview:line];
        startPoint = line.bottom + 10;
        line.tag = 10000;
    }
    
    UIButton* btGroupAct = getButtonByImageName(@"groupAct.png");
    btGroupAct.centerX = mainScrollView.width/2;
    btGroupAct.top = startPoint;
    [btGroupAct addTarget:self action:@selector(gotoGroupAct) forControlEvents:UIControlEventTouchUpInside];
    btGroupAct.tag = 10003;
    [mainScrollView addSubview:btGroupAct];
    
    startPoint = btGroupAct.bottom + 10;
    
    UILabel* lMember = [[UILabel alloc]initWithFrame:CGRectMake(btGroupAct.left, startPoint, 100, 20)];
    lMember.backgroundColor = [UIColor clearColor];
    lMember.textColor = [UIColor colorWithRed:170.0/255.0 green:170.0/255.0 blue:170.0/255.0 alpha:1.0f];
    lMember.textAlignment = NSTextAlignmentLeft;
    lMember.text = @"群组成员";
    lMember.font = [UIFont systemFontOfSize:20];
    lMember.tag = 10001;
    [mainScrollView addSubview:lMember];
    
    startPoint = lMember.bottom + 10;
    
    UIView* userImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, startPoint, btGroupAct.width, 100)];
    userImg.centerX = mainScrollView.width/2;
    userImg.userInteractionEnabled = YES;
    userImg.backgroundColor = [UIColor whiteColor];
    userImg.layer.cornerRadius = 6.0f;
    userImg.layer.borderColor = [UIColor colorWithRed:170.0/255.0 green:170.0/255.0 blue:170.0/255.0 alpha:1.0f].CGColor;
    userImg.layer.borderWidth = 1;
    userImg.tag = 10002;
    [mainScrollView addSubview:userImg];
    
    for (int i=0; i<arrayUser.count; i++) {
        UserObject* one = [arrayUser objectAtIndex:i];
        
        UIImageView* head = createPortraitView(44);
        //UIImageView* head = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
        //head.backgroundColor = [UIColor clearColor];
        head.top = 15+80*(i/4);
        head.left = 25+70*(i%4);
        head.tag = USERHEADTAG+i;
        head.image = getBundleImage(@"defaultHead.png");
        if ([one.userHeadURL isKindOfClass:[NSString class]]&&one.userHeadURL.length>0) {
            NSURL *url = [NSURL URLWithString:getPicNameALL(one.userHeadURL)];
            UIImage *img = [_recvUserHead imageForKey:[one.userHeadURL lastPathComponent]                                          url:url queueIfNeeded:YES tag:head.tag];
            if (img) {
                img = roundCorners(img);
                head.image = img;
            }
        }
        head.userInteractionEnabled = YES;
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapUserHead:)];
        [head addGestureRecognizer:tap];
        [userImg addSubview:head];
        
        UILabel* name = [[UILabel alloc]initWithFrame:CGRectMake(head.left, head.bottom+4, head.width, 15)];
        name.backgroundColor = [UIColor clearColor];
        name.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0f];
        name.textAlignment = NSTextAlignmentCenter;
        name.font = [UIFont systemFontOfSize:12];
        name.text = one.userName;
        [userImg addSubview:name];
        
        if (i==arrayUser.count-1) {
            userImg.frame = CGRectMake(userImg.left, userImg.top, userImg.width, name.bottom+10);
        }
    }
    
    startPoint = userImg.bottom + 10;
    
    mainScrollView.contentSize = CGSizeMake(mainScrollView.width, startPoint);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"onChangeScrollView" object:nil];
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getGroupMember:(int)groupid {
    //[WaitTooles showHUD:@"加载数据..."];
    [[WebServiceManager sharedManager] getGroupMember:groupid encodeStr:[[DataManager sharedManager]getUser].encodeStr completion:^(NSDictionary* dic) {
        //[WaitTooles removeHUD];
        int success = [[dic objectForKey:@"success"]intValue];
        if (success == 1) {
            NSArray* array = [dic objectForKey:@"obj"];
            if ([array isKindOfClass:[NSArray class]]) {
                startPoint = 10;
                [arrayUser removeAllObjects];
                for (int i=0; i<array.count; i++) {
                    NSDictionary* dic1 = [array objectAtIndex:i];
                    UserObject* one = [UserObject getUserObj:dic1];
                    [arrayUser addObject:one];
                    
                    if ([GroupObject findMemberByGroupAndUserid:groupObj.groupid withUserid:one.userid]==nil) {
                        [GroupObject addOneMember:one withGroupid:groupObj.groupid];
                    } else {
                        [GroupObject updateOneMember:one withGroupid:groupObj.groupid];
                    }
                    
                    if ([UserObject findByID:one.userid]==nil) {
                        [UserObject addName:one];
                    } else {
                        [UserObject updataName:one];
                    }
                }
            } else {
                arrayUser = [GroupObject findMemberByGroup:groupObj.groupid];
            }
            //[WaitTooles showHUD:@"获取群风采图片..."];
            [[WebServiceManager sharedManager] getGroupPic:groupObj.groupid startPage:pageNum encodeStr:[[DataManager sharedManager]getUser].encodeStr completion:^(NSDictionary* dic1) {
                //[WaitTooles removeHUD];
                if ([[dic1 objectForKey:@"success"]intValue]==1) {
                    NSArray* arr = [dic1 objectForKey:@"obj"];
                    if ([arr isKindOfClass:[NSArray class]]) {
                        if (groupObj.arrGroupPic == nil) {
                            groupObj.arrGroupPic = [NSMutableArray new];
                        } else {
                            [groupObj.arrGroupPic removeAllObjects];
                        }
                        for (int i=0; i<arr.count; i++) {
                            NSDictionary* dic2 = [arr objectAtIndex:i];
                            GroupPicData* one = [GroupPicData getOnePic:dic2];
                            [groupObj.arrGroupPic addObject:one];
                        }
                    }
                }
                [self createView];
            }];
        } else {
            if ([[dic objectForKey:@"returnCode"]intValue]==101) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息" message:@"你的账号已经在别处登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"backToRoot" object:nil];
            }
        }
    }];
}

- (void)tapUserHead:(UITapGestureRecognizer*)sender {
    int tag = sender.view.tag-USERHEADTAG;
    UserObject* user = [arrayUser objectAtIndex:tag];
    UserDetailViewController* v = [[UserDetailViewController alloc]initWithUserid:user.userid];
    [self.navigationController pushViewController:v animated:YES];
}

- (void)gotoGroupAct {
    GroupActViewController* v = [[GroupActViewController alloc]initWithGroup:groupObj];
    [self.navigationController pushViewController:v animated:YES];
}

- (void)recvGroupHeadOnDetail:(NSNotification*)sender {
    NSDictionary *dict = [sender userInfo];
    UIImage *img = [dict objectForKey:@"image"];
    groupHead.image = img;
}

- (void)recvUserHeadOnGroupDetail:(NSNotification*)sender {
    NSDictionary *dict = [sender userInfo];
    UIImage *img = [dict objectForKey:@"image"];
    int tag = [[dict objectForKey:@"tag"] intValue];
    UIImageView* imgView = (UIImageView*)[mainScrollView viewWithTag:tag];
    imgView.image = img;
}

- (void)recvGroupPicOnGroupDetail:(NSNotification*)sender {
    NSDictionary *dict = [sender userInfo];
    UIImage *img = [dict objectForKey:@"image"];
    int tag = [[dict objectForKey:@"tag"] intValue];
    UIImageView* imgView = (UIImageView*)[groupPicScrollView viewWithTag:tag];
    imgView.image = img;
}

- (void)onCamera {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"上传群相片"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"拍照", @"从手机相册选择",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    actionSheet.delegate = self;
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

#pragma mark UIActionSheet的代理
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self addCameraEvent];
    }else if (buttonIndex == 1) {
        //[self addPicEvent];
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        if (![UIImagePickerController isSourceTypeAvailable: sourceType]) {
            sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = sourceType;
        [self presentViewController:imagePickerController animated:YES completion:^{}];
    }
}

#pragma mark 照片库的操作
-(void)cancelFoo{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)cameraTake:(CameraViewController *)picker
             image:(UIImage *)takeImage{
    if (takeImage==nil) {
        [self cancelFoo];
        return;
    }
    [self sendGroupPic:takeImage];
}

-(void)addPicEvent {
    UIImagePickerControllerSourceType sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    UIImagePickerController * picker = [[UIImagePickerController alloc]init];
    picker.delegate=self;
    picker.allowsEditing=YES;
    picker.sourceType=sourceType;
    [self.navigationController presentViewController:picker animated:YES completion:nil];
}

#pragma mark 摄像头的操作
-(void)addCameraEvent {
    UIImagePickerControllerSourceType sourceType=UIImagePickerControllerSourceTypeCamera;
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    }
    UIImagePickerController * picker = [[UIImagePickerController alloc]init];
    picker.delegate=self;
    picker.allowsEditing=YES;
    picker.sourceType=sourceType;
    [self.navigationController presentViewController:picker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage * image=[info objectForKey:UIImagePickerControllerEditedImage];
    [self sendGroupPic:image];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)sendGroupPic:(UIImage*)img {
    NSData* photoData = UIImageJPEGRepresentation(img, 0.7);
    //[WaitTooles showHUD:@"上传群图片..."];
    [[WebServiceManager sharedManager] sendGroupPic:[[DataManager sharedManager]getUser].userid groupid:groupObj.groupid imgData:photoData imgtype:@"jpg" encodeStr:[[DataManager sharedManager]getUser].encodeStr completion:^(NSDictionary* dic1) {
        //[WaitTooles removeHUD];
        pageNum = 0;
        if ([[dic1 objectForKey:@"success"]intValue]==1) {
            [[WebServiceManager sharedManager]getGroupPic:groupObj.groupid startPage:pageNum encodeStr:[[DataManager sharedManager]getUser].encodeStr completion:^(NSDictionary* dic2) {
                if ([[dic2 objectForKey:@"success"]intValue]==1) {
                    NSArray* arr = [dic2 objectForKey:@"obj"];
                    if ([arr isKindOfClass:[NSArray class]]) {
                        if (groupObj.arrGroupPic == nil) {
                            groupObj.arrGroupPic = [NSMutableArray new];
                        } else {
                            [groupObj.arrGroupPic removeAllObjects];
                        }
                        for (int i=0; i<arr.count; i++) {
                            NSDictionary* dic3 = [arr objectAtIndex:i];
                            GroupPicData* one = [GroupPicData getOnePic:dic3];
                            [groupObj.arrGroupPic addObject:one];

                        }
                    }
                }
                [self createView];
            }];
        }
    }];
}

- (void)onTapThumb:(UITapGestureRecognizer*)sender {
//    PictureViewController* v = [[PictureViewController alloc]initWithGroupPicData:groupObj.arrGroupPic whitIndex:sender.view.tag-GROUPPIC ];
//    [self.navigationController pushViewController:v animated:YES];
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:groupObj.arrGroupPic, @"array", [NSNumber numberWithInt:sender.view.tag-GROUPPIC], @"tag", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"gotoGroupPicBigImage" object:dic];
    return ;
    
    if (!_recvBigImgOnGroupPic) {
        _recvBigImgOnGroupPic = [[TKImageCache alloc] initWithCacheDirectoryName:@"activity"];
        _recvBigImgOnGroupPic.notificationName = @"recvBigImgOnGroupPic";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvBigImgOnGroupPic:) name:@"recvBigImgOnGroupPic" object:nil];
    }
    CGRect rc = [UIScreen mainScreen].bounds;
    if (lagreImg) {
        [lagreImg removeFromSuperview];
        lagreImg = nil;
    }
    lagreImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, rc.size.width, rc.size.height)];
    [[UIApplication sharedApplication].keyWindow addSubview:lagreImg];
    lagreImg.clipsToBounds = YES;
    lagreImg.backgroundColor = [UIColor clearColor];
    lagreImg.userInteractionEnabled = YES;
    
    UIView *blackImage = [[UIView alloc] initWithFrame:lagreImg.bounds];
    [lagreImg addSubview:blackImage];
    blackImage.userInteractionEnabled = NO;
    blackImage.backgroundColor = [UIColor blackColor];
    blackImage.tag = 99;
    
    myBigImg = [[UIImageView alloc]initWithFrame:sender.view.frame];
    myBigImg.tag = 100000;
    myBigImg.contentMode = UIViewContentModeScaleAspectFit;
    myBigImg.userInteractionEnabled = YES;
    UIPinchGestureRecognizer* pin = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(onBigImgScale:)];
    [myBigImg addGestureRecognizer:pin];
    [lagreImg addSubview:myBigImg];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.frame = lagreImg.frame;
    [activityIndicator startAnimating];
    activityIndicator.tag = 99;
    [lagreImg addSubview:activityIndicator];
    
    UIImageView *thumbView = (UIImageView *)sender.view;
    
    GroupPicData* one = [groupObj.arrGroupPic objectAtIndex:sender.view.tag-GROUPPIC];
    NSURL *url = [NSURL URLWithString:getPicNameALL(one.picURL)];
    UIImage *img = [_recvBigImgOnGroupPic imageForKey:[one.picURL lastPathComponent] url:url queueIfNeeded:YES ];
    if (1 ) {
        [activityIndicator stopAnimating];
        [activityIndicator removeFromSuperview];
        
//        double radio = img.size.width/320;
//        float height = img.size.height/radio;
//        [myBigImg setFrame:CGRectMake(lagreImg.left, lagreImg.top, 320, height)];
//        myBigImg.center = CGPointMake(lagreImg.width/2, lagreImg.height/2);      
        
        //myBigImg.size = CGSizeMake(0, 0);
        lagreImg.alpha = 0;
        myBigImg.frame = CGRectMake(thumbView.left, thumbView.top+64, thumbView.width, thumbView.height);
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        lagreImg.alpha = 1;
        myBigImg.frame = myBigImg.superview.bounds;
        [UIView commitAnimations];
        
        if (img) {
            myBigImg.image = img;
        }else{
            myBigImg.image = thumbView.image;
        }
        
    }else{
        
    }
    
    clickPosition_ = CGRectMake(thumbView.left, thumbView.top+64, thumbView.width, thumbView.height);
    
    UITapGestureRecognizer* tapBigImg = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTagBigImg:)];
    [lagreImg addGestureRecognizer:tapBigImg];
}

- (void)onBigImgScale:(UIPinchGestureRecognizer*)sender {
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

#pragma mark 接受大图的回调
- (void)recvBigImgOnGroupPic:(NSNotification*)sender {
    NSDictionary *dict = [sender userInfo];
    UIImage *img = [dict objectForKey:@"image"];
    UIImageView* image = (UIImageView*)[lagreImg viewWithTag:100000];
//    UIActivityIndicatorView *activity = (UIActivityIndicatorView *)[lagreImg viewWithTag:99];
//    [activity stopAnimating];
//    [activity removeFromSuperview];
//    double radio = img.size.width/320;
//    float height = img.size.height/radio;
//    [image setFrame:CGRectMake(image.left, image.top, 320, height)];
//    image.center = CGPointMake(lagreImg.width/2, lagreImg.height/2);
    image.image = img;
//    
//    [DataManager exChangeOut:image dur:0.3f];
}

#pragma mark 点击大图使大图消失
- (void)onTagBigImg:(UITapGestureRecognizer*)sender {
    
    UIView *blackImage = [lagreImg viewWithTag:99];
    blackImage.hidden = YES;
    
    if (myBigImg) {
//        CAKeyframeAnimation * animation;
//        animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
//        animation.duration = 0.3f;
//        animation.removedOnCompletion = NO;
//        animation.fillMode = kCAFillModeForwards;
//        animation.delegate = self;
//        NSMutableArray *values = [NSMutableArray array];
//        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
//        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5, 0.5, 1.0)]];
//        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.0, 0.0, 0.0)]];
//        animation.values = values;
//        animation.timingFunction = [CAMediaTimingFunction functionWithName: @"easeInEaseOut"];
//        [myBigImg.layer addAnimation:animation forKey:nil];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop)];
        myBigImg.frame = clickPosition_;
        [UIView commitAnimations];
    }
    if (_recvBigImgOnGroupPic) {
        [_recvBigImgOnGroupPic cancelOperations];
        _recvBigImgOnGroupPic = nil;
    }
}

- (void)animationDidStop{
    if (lagreImg) {
        [lagreImg removeFromSuperview];
        lagreImg = nil;
    }
}

@end
