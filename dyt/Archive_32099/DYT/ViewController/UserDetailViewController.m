//
//  UserDetailViewController.m
//  DYT
//
//  Created by zhaoliang.chen on 13-6-3.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "UserDetailViewController.h"
#import "TKImageCache.h"
#import "UserDetailCell.h"

@interface UserDetailViewController (){
    CGRect clickPosition_;
}

@end

@implementation UserDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _recvUserHeadOnDetial = [[TKImageCache alloc] initWithCacheDirectoryName:@"activity"];
        _recvUserHeadOnDetial.notificationName = @"recvUserHeadOnDetial";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvUserHeadOnDetial:) name:@"recvUserHeadOnDetial" object:nil];
        
        titleArray = [NSArray arrayWithObjects:@"性       别", @"地       区", @"职       业", @"职       位", @"个性签名", nil];
    }
    return self;
}

- (id)initWithUserid:(int)userid {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        m_nUserid = userid;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.navigationController.navigationBar setBackgroundImage:getBundleImage(@"navBG.png") forBarMetrics:UIBarMetricsDefault];
    self.view.backgroundColor = [UIColor colorWithPatternImage:getBundleImage(@"loginBG.png")];
    self.title = @"详细资料";
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    UIButton *button1 = getButtonByImageName(@"btBack.png");
    [button1 addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn1 = [[UIBarButtonItem alloc] initWithCustomView:button1];
    self.navigationItem.leftBarButtonItem = btn1;
    
    UIImageView* bg = getImageViewByImageName(@"userDetailBG.png");
    bg.top = 10;
    bg.centerX = self.view.width/2;
    //[self.view addSubview:bg];
    
    head = createPortraitViewRadius(84);
    head.layer.cornerRadius = 8;
    head.centerX = bg.width/2;
    head.top = 10;
    head.image = getBundleImage(@"defaultHead.png");
    head.userInteractionEnabled = YES;
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapThumb:)];
    [head addGestureRecognizer:tap];
    [self.view addSubview:head];
    
    name = [[UILabel alloc]initWithFrame:CGRectMake(head.left-20, head.bottom+5, head.width, 20)];
    name.backgroundColor = [UIColor clearColor];
    name.textColor = [UIColor blackColor];
    name.textAlignment = NSTextAlignmentLeft;
    name.font = [UIFont fontWithName:@"STHeitiTC-Medium" size:16];
    [self.view addSubview:name];
    
    sex = [[UILabel alloc]initWithFrame:CGRectMake(name.right+2, name.bottom, 40, 20)];
    sex.backgroundColor = [UIColor clearColor];
    sex.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0f];
    sex.textAlignment = NSTextAlignmentLeft;
    sex.font = [UIFont systemFontOfSize:16];
    //[self.view addSubview:sex];
    
    infoTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, name.bottom, self.view.width, 350) style:UITableViewStyleGrouped];
    infoTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    infoTableView.separatorColor = [UIColor colorWithRed:149.0/255.0 green:149.0/255.0 blue:149.0/255.0 alpha:1.0f];
    infoTableView.delegate = self;
    infoTableView.dataSource = self;
    infoTableView.bounces = NO;
    infoTableView.backgroundView = nil;
    [self.view addSubview:infoTableView];
    
    if (m_nUserid == [[DataManager sharedManager]getUser].userid) {
        m_User = [[DataManager sharedManager]getUser];
        [self loadUserInfo:nil];
        contentArray = [NSArray arrayWithObjects:m_User.sex==1?@"男":@"女", m_User.hometown, m_User.location, m_User.pos,m_User.explain, nil];
        [infoTableView reloadData];
    } else {
        m_User = [UserObject findByID:m_nUserid];
        [self loadUserInfo:nil];
        if (m_User==nil) {
            contentArray = [NSArray arrayWithObjects:@"未知",@"未知",@"未知",@"未知",@"未知",nil];
        }
        [infoTableView reloadData];
    }
    //[WaitTooles showHUD:@""];
    [[WebServiceManager sharedManager] getUserInfo:m_nUserid encodeStr:[[DataManager sharedManager] getUser].encodeStr completion:^(NSDictionary* dic) {
        //[WaitTooles removeHUD];
        if ([dic isKindOfClass:[NSDictionary class]]) {
            m_User = [UserObject getUserObjByOne:dic];
        } else {
            m_User = [UserObject findByID:m_nUserid];
        }
        [self loadUserInfo:nil];
        contentArray = [NSArray arrayWithObjects:m_User.sex==1?@"男":@"女", m_User.hometown, m_User.location, m_User.pos,m_User.explain, nil];
        [infoTableView reloadData];
    }];
}

- (void)loadUserInfo:(NSDictionary *)dic1cc {
    if (m_nUserid == [[DataManager sharedManager] getUser].userid) {
        if (m_User.headImage) {
            head.image = m_User.headImage;
        } else {
            if ([m_User.userHeadLargeURL isKindOfClass:[NSString class]] && m_User.userHeadLargeURL.length>0) {
                NSURL *url = [NSURL URLWithString:getPicNameALL(m_User.userHeadLargeURL)];
                UIImage *img = [_recvUserHeadOnDetial imageForKey:[m_User.userHeadLargeURL lastPathComponent] url:url queueIfNeeded:YES];
                if (img) {
                    head.image = img;
                }
            }
        }
    } else {        
        if ([m_User.userHeadLargeURL isKindOfClass:[NSString class]] && m_User.userHeadLargeURL.length>0) {
            NSURL *url = [NSURL URLWithString:getPicNameALL(m_User.userHeadLargeURL)];
            UIImage *img = [_recvUserHeadOnDetial imageForKey:[m_User.userHeadLargeURL lastPathComponent] url:url queueIfNeeded:YES];
            if (img) {
                head.image = img;
            }
        }
    }
    name.text = m_User.userName;
    name.width = [name.text sizeWithFont:name.font].width;
    name.centerX = head.centerX;
    if (m_User.sex==1) {
        sex.text = @"先生";
    } else {
        sex.text = @"女士";
    }
    sex.width = [sex.text sizeWithFont:sex.font].width;
    sex.centerX = name.centerX;
    

    //todo
//    UserObject* p = [UserObject findByID:m_User.userid];
//    if (m_User==nil) {
//        [UserObject addName:m_User];
//    } else {
//        
//    }
    
//    [UserObject updataName:m_User];
//    UserObject *user = m_User;
//    
//    user.hometown = [NSString stringWithFormat:@"%@%@",[dic1cc objectForKey:@"area1"],[dic1cc objectForKey:@"area2"]];
//    if ([user.hometown isKindOfClass:[NSNull class]] || [user.hometown rangeOfString:@"null" options:NSCaseInsensitiveSearch].length>0) {
//        user.hometown = @"";
//    }
//    user.location = [NSString stringWithFormat:@"%@",[dic1cc objectForKey:@"job2"]];
//    if ([user.location isKindOfClass:[NSNull class]] || [user.location rangeOfString:@"null" options:NSCaseInsensitiveSearch].length>0) {
//        user.location = @"";
//    }
//    user.explain = [dic1cc objectForKey:@"sign"];
//    if ([user.explain isKindOfClass:[NSNull class]] || [user.explain rangeOfString:@"null" options:NSCaseInsensitiveSearch].length>0 || user.explain == nil) {
//        user.explain = @"";
//    }
//    user.pos = [dic1cc objectForKey:@"pos"];
//    if ([user.pos isKindOfClass:[NSNull class]] || [user.pos rangeOfString:@"null" options:NSCaseInsensitiveSearch].length>0 || user.pos == nil) {
//        user.pos = @"";
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_recvUserHeadOnDetial cancelOperations];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)recvUserHeadOnDetial:(NSNotification*)sender {
    NSDictionary *dict = [sender userInfo];
    UIImage *img = [dict objectForKey:@"image"];
    head.image = img;
}

#pragma mark TableView的代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *UserCell = @"UserCell";
    
    UserDetailCell *cell = (UserDetailCell*)[tableView dequeueReusableCellWithIdentifier:UserCell];
    if (cell == nil) {
        cell = [[UserDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UserCell];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (contentArray != nil) {
        [cell setCell:[titleArray objectAtIndex:indexPath.row] withContent:[contentArray objectAtIndex:indexPath.row]];
    }
    
    return cell;
}

-(NSIndexPath*)tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath {
	return indexPath;
}

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    UILabel* l = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 40)];
    l.font = [UIFont systemFontOfSize:16];
    l.numberOfLines = 0;
    CGSize size = CGSizeMake(l.width,2000);
    NSString* str = [contentArray objectAtIndex:indexPath.row];
    CGSize labelsize = [str sizeWithFont:l.font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
    if (labelsize.height <= l.height) {
        return 40;
    } else {
        return labelsize.height+20;
    }
}

- (void)onTapThumb:(UITapGestureRecognizer*)sender {
    
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
    
    NSURL *url = [NSURL URLWithString:getPicNameALL(m_User.userHeadLargeURL)];
    UIImage *img = [_recvUserHeadOnDetial imageForKey:[m_User.userHeadLargeURL lastPathComponent] url:url queueIfNeeded:YES];


//    UIImage *img = [_recvBigImgOnGroupPic imageForKey:[one.picURL lastPathComponent] url:url queueIfNeeded:YES ];
    if (1) {
        [activityIndicator stopAnimating];
        [activityIndicator removeFromSuperview];
        
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

#pragma mark 接受大图的回调
- (void)recvBigImgOnGroupPic:(NSNotification*)sender {
    NSDictionary *dict = [sender userInfo];
    UIImage *img = [dict objectForKey:@"image"];
    UIImageView* image = (UIImageView*)[lagreImg viewWithTag:100000];
        image.image = img;

}

#pragma mark 点击大图使大图消失
- (void)onTagBigImg:(UITapGestureRecognizer*)sender {
    
    UIView *blackImage = [lagreImg viewWithTag:99];
    blackImage.hidden = YES;
    
    if (myBigImg) {
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop)];
        myBigImg.frame = clickPosition_;
        [UIView commitAnimations];
    }
    
}
- (void)animationDidStop{
    if (lagreImg) {
        [lagreImg removeFromSuperview];
        lagreImg = nil;
    }
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

@end
