//
//  NSBubbleData.m
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import "NSBubbleData.h"
#import <QuartzCore/QuartzCore.h>
#import "TKImageCache.h"
#import "DownloadURL.h"
#import "EmotionLabel.h"

#import "UIBubbleTableViewCell.h"

float DegreesToRads(float degree){
    return degree/180*M_PI;
}

@implementation NSBubbleData

#pragma mark - Properties

@synthesize date = _date;
@synthesize type = _type;
@synthesize view = _view;
@synthesize insets = _insets;
@synthesize avatar = _avatar;
@synthesize avatarURL;
@synthesize chatObj;
@synthesize soundPath;

#pragma mark - Lifecycle
- (void)setupData:(ChatObject*)one {
    self.chatObj = one;
}

- (void)dealloc {
    [_recvImgOnChat cancelOperations];
    [_recvBigImgOnChat cancelOperations];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#if !__has_feature(objc_arc)
    [_date release];
	_date = nil;
    [_view release];
    _view = nil;
    
    self.avatar = nil;
    [super dealloc];
#endif
}

#pragma mark - Text bubble
const UIEdgeInsets textInsetsMine = {5, 10, 11, 17};
const UIEdgeInsets textInsetsSomeone = {5, 15, 11, 10};

+ (id)dataWithText:(NSString *)text withObj:(ChatObject*)obj withName:(NSString*)name date:(NSDate *)date type:(NSBubbleType)type {
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithText:text withObj:obj withName:name date:date type:type] autorelease];
#else
    return [[NSBubbleData alloc] initWithText:text withObj:obj withName:name date:date type:type];
#endif    
}

- (id)initWithText:(NSString *)text withObj:(ChatObject*)obj withName:(NSString*)name date:(NSDate *)date type:(NSBubbleType)type {
    [self setupData:obj];
    UIFont *font = [UIFont systemFontOfSize:30];
    CGSize size = [(text ? text : @"") sizeWithFont:font constrainedToSize:CGSizeMake(180, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    
    UIView* backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 180, 200)];
    backView.backgroundColor = [UIColor clearColor];
    
//    UILabel* lName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
//    lName.text = [NSString stringWithFormat:@"%@ : ",name];
//    lName.font = font;
//    lName.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0f];
//    lName.backgroundColor = [UIColor clearColor];
//    lName.width = [lName.text sizeWithFont:lName.font].width;
//    lName.userInteractionEnabled = YES;
//    [backView addSubview:lName];
    
    
//    CGSize size_ = [@"test" sizeWithFont:font];
//    int row = ceil(size.height/size_.height);
    EmotionLabel *label = [[EmotionLabel alloc] initWithFrame:CGRectMake(10, 0, backView.width, size.height+10)];
    //label.numberOfLines = 0;
    //label.lineBreakMode = NSLineBreakByWordWrapping;
    
    
    if (type == BubbleTypeMine) {
        label.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    }else{
        label.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    }
    label.text = (text ? text : @"");
    label.font = font;
    
    label.backgroundColor = [UIColor clearColor];
    label.userInteractionEnabled = YES;

    CGSize ss = [label attributedStringSizeThatFits:backView.width];

    
    label.frame = CGRectMake(0, 0, ss.width, ss.height);
    
    backView.bounds = label.bounds;
//    if (row==1) {
//        label.width = [label.text sizeWithFont:label.font].width;
//    }
    [backView addSubview:label];
    
    [backView setFrame:CGRectMake(0, 0, backView.width, label.height)];
    
#if !__has_feature(objc_arc)
    [label autorelease];
#endif
    
    UIEdgeInsets insets = (type == BubbleTypeMine ? textInsetsMine : textInsetsSomeone);
    return [self initWithView:backView date:date type:type insets:insets];
}

#pragma mark - Image bubble

const UIEdgeInsets imageInsetsMine = {6, 6, 11, 17};
const UIEdgeInsets imageInsetsSomeone = {7, 15, 9, 5};

+ (id)dataWithImage:(UIImage *)image withObj:(ChatObject*)obj date:(NSDate *)date type:(NSBubbleType)type {
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithImage:image withObj:obj date:date type:type] autorelease];
#else
    return [[NSBubbleData alloc] initWithImage:image withObj:obj date:date type:type];
#endif    
}

- (id)initWithImage:(UIImage *)image withObj:(ChatObject*)obj date:(NSDate *)date type:(NSBubbleType)type {
    CGSize size = image.size;
    [self setupData:obj];
    if (size.width > 220)
    {
        size.height /= (size.width / 220);
        size.width = 220;
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    imageView.image = image;
    imageView.layer.cornerRadius = 5.0;
    imageView.layer.masksToBounds = YES;

    
#if !__has_feature(objc_arc)
    [imageView autorelease];
#endif
    
    UIEdgeInsets insets = (type == BubbleTypeMine ? imageInsetsMine : imageInsetsSomeone);
    return [self initWithView:imageView date:date type:type insets:insets];       
}

+ (id)dataWithURLImage:(NSString *)imgUrl withObj:(ChatObject*)obj withName:(NSString*)name date:(NSDate *)date type:(NSBubbleType)type {
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithURLImage:imgUrl withObj:obj withName:name date:date type:type] autorelease];
#else
    return [[NSBubbleData alloc] initWithURLImage:imgUrl withObj:obj withName:name date:date type:type];
#endif
}

- (id)initWithURLImage:(NSString *)imgUrl withObj:(ChatObject*)obj withName:(NSString*)name date:(NSDate *)date type:(NSBubbleType)type {
    if (!_recvImgOnChat) {
        _recvImgOnChat = [[TKImageCache alloc] initWithCacheDirectoryName:@"activity"];
        _recvImgOnChat.notificationName = @"recvImgOnChat";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvImgOnChat:) name:@"recvImgOnChat" object:nil];
    }
    [self setupData:obj];
    
    
    UIView* backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, THUMBWIDTH, THUMBHEIGHT)];
    backView.backgroundColor = [UIColor clearColor];
    
    UILabel* lName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, backView.width, 18)];
    lName.text = [NSString stringWithFormat:@"%@ : ",name];
    lName.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    lName.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0f];
    lName.backgroundColor = [UIColor clearColor];
    lName.width = [lName.text sizeWithFont:lName.font].width;
    //[backView addSubview:lName];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, THUMBWIDTH, THUMBHEIGHT)];
    imageView.tag = 9999;
    imageView.layer.cornerRadius = 5.0;
    imageView.layer.masksToBounds = YES;
    imageView.userInteractionEnabled = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    UITapGestureRecognizer* tapThumb = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTagThumb:)];
    [imageView addGestureRecognizer:tapThumb];

    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activityIndicator startAnimating];
    activityIndicator.tag = 99;
    [imageView addSubview:activityIndicator];
    imageView.backgroundColor = [UIColor grayColor];
    
    NSURL *url = [NSURL URLWithString:imgUrl];
    
    UIImage *img = nil;
    if ([imgUrl hasPrefix:@"/Users"] || [imgUrl hasPrefix:@"/var"]) {
        img = [UIImage imageWithContentsOfFile:imgUrl];
        [activityIndicator stopAnimating];
        [activityIndicator removeFromSuperview];
    }else{
        img = [_recvImgOnChat imageForKey:[url lastPathComponent] url:url queueIfNeeded:YES tag:obj.chatid];
        if (img) {
            [activityIndicator stopAnimating];
            [activityIndicator removeFromSuperview];            
        }
    }
    
    if (img.size.width>img.size.height) {
//        double radio = img.size.height/THUMBHEIGHT;
//        float width = img.size.width/radio;
//        if (width>100) {
//            width = 100;
//        }
        [imageView setFrame:CGRectMake(imageView.left, imageView.top, 120, THUMBHEIGHT)];
    }else{
//        double radio = img.size.width/THUMBHEIGHT;
//        float height = img.size.height/radio;
//        if (height>100) {
//            height = 120;
//        }
        [imageView setFrame:CGRectMake(imageView.left, imageView.top, THUMBHEIGHT, 120)];
    }
    
    activityIndicator.center = CGPointMake(imageView.width/2, imageView.height/2);
    imageView.image = img;
    [backView addSubview:imageView];
    
    [backView setFrame:CGRectMake(backView.left, backView.top, imageView.width, imageView.height-4)];
    if (type==BubbleTypeMine) {
        imageView.left = -3;
        imageView.top = -2;
    }else{
        imageView.left = 4;
        imageView.top = -2;
    }

    
#if !__has_feature(objc_arc)
    [imageView autorelease];
#endif
    
    UIEdgeInsets insets = (type == BubbleTypeMine ? imageInsetsMine : imageInsetsSomeone);
    return [self initWithView:backView date:date type:type insets:insets];
}

#pragma mark 接收缩略图的回调函数
- (void)recvImgOnChat:(NSNotification*)sender {
    NSDictionary *dict = [sender userInfo];
    UIImage *img = [dict objectForKey:@"image"];
    int tag = [[dict objectForKey:@"tag"] intValue];
    
    if (tag == chatObj.chatid) {
        UIImageView* imgView = (UIImageView*)[_view viewWithTag:9999];
        UIActivityIndicatorView *activity = (UIActivityIndicatorView *)[imgView viewWithTag:99];
        [activity stopAnimating];
        [activity removeFromSuperview];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        
        if (img.size.width>img.size.height) {
            [imgView setFrame:CGRectMake(imgView.left, imgView.top, 120, THUMBHEIGHT)];
        }else{
            [imgView setFrame:CGRectMake(imgView.left, imgView.top, THUMBHEIGHT, 120)];
        }
        
//        double radio = img.size.height/THUMBHEIGHT;
//        float width = img.size.width/radio;
//        [imgView setFrame:CGRectMake(imgView.left, imgView.top, width, THUMBHEIGHT)];
//        [imgView.superview setFrame:CGRectMake(imgView.superview.left, imgView.superview.top, width, THUMBHEIGHT+30)];
        
        imgView.image = img;
        
        [imgView.superview setFrame:CGRectMake(imgView.superview.left, imgView.superview.top, imgView.width, imgView.height-4)];
        if (_type==BubbleTypeMine) {
            imgView.left = -3;
            imgView.top = -2;
        }else{
            imgView.left = 4;
            imgView.top = -2;
        }
        
        UIBubbleTableViewCell *bubbleCell = (UIBubbleTableViewCell *)(self.view.superview);
        [bubbleCell setFrame:bubbleCell.frame];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadChatTableView" object:self];
    }
}

#pragma mark 点击缩略图出现大图的手势
- (void)onTagThumb:(UITapGestureRecognizer*)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"gotoPicView" object:chatObj];
//    if (!_recvBigImgOnChat) {
//        _recvBigImgOnChat = [[TKImageCache alloc] initWithCacheDirectoryName:@"activity"];
//        _recvBigImgOnChat.notificationName = @"recvBigImgOnChat";
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvBigImgOnChat:) name:@"recvBigImgOnChat" object:nil];
//    }
//    CGRect rc = [UIScreen mainScreen].bounds;
//    lagreImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, rc.size.width, rc.size.height)];
//    [[UIApplication sharedApplication].keyWindow addSubview:lagreImg];
//    lagreImg.backgroundColor = [UIColor blackColor];
//    lagreImg.userInteractionEnabled = YES;
//    
//    UIImageView* myBigImg = [[UIImageView alloc]initWithFrame:lagreImg.frame];
//    myBigImg.tag = 100000;
//    myBigImg.userInteractionEnabled = YES;
//    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTagBigImg:)];
//    [myBigImg addGestureRecognizer:tap];
//    [lagreImg addSubview:myBigImg];
//    
//    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//    activityIndicator.frame = lagreImg.frame;
//    [activityIndicator startAnimating];
//    activityIndicator.tag = 99;
//    [lagreImg addSubview:activityIndicator];
//    
//    NSURL *url = [NSURL URLWithString:getPicNameALL(chatObj.content)];
//    UIImage *img = [_recvBigImgOnChat imageForKey:[getPicNameALL(chatObj.content) lastPathComponent] url:url queueIfNeeded:YES ];
//    if (img) {
//        [activityIndicator stopAnimating];
//        [activityIndicator removeFromSuperview];
//        
//        double radio = img.size.width/320;
//        float height = img.size.height/radio;
//        [myBigImg setFrame:CGRectMake(lagreImg.left, lagreImg.top, 320, height)];
//        myBigImg.center = CGPointMake(lagreImg.width/2, lagreImg.height/2);
//    }
//    myBigImg.image = img;
//    UITapGestureRecognizer* tapBigImg = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTagBigImg:)];
//    [lagreImg addGestureRecognizer:tapBigImg];
}

#pragma mark 接受大图的回调
- (void)recvBigImgOnChat:(NSNotification*)sender {
    NSDictionary *dict = [sender userInfo];
    UIImage *img = [dict objectForKey:@"image"];
    UIImageView* image = (UIImageView*)[lagreImg viewWithTag:100000];
    UIActivityIndicatorView *activity = (UIActivityIndicatorView *)[lagreImg viewWithTag:99];
    [activity stopAnimating];
    [activity removeFromSuperview];
    double radio = img.size.width/320;
    float height = img.size.height/radio;
    [image setFrame:CGRectMake(image.left, image.top, 320, height)];
    image.center = CGPointMake(lagreImg.width/2, lagreImg.height/2);
    image.image = img;
}

#pragma mark 点击大图使大图消失
- (void)onTagBigImg:(UITapGestureRecognizer*)sender {
    if (lagreImg) {
        [lagreImg removeFromSuperview];
        lagreImg = nil;
    }
    [_recvBigImgOnChat cancelOperations];
}

+ (id)dataWithVoice:(NSString *)soundUrl withObj:(ChatObject*)obj withName:(NSString*)name date:(NSDate *)date type:(NSBubbleType)type {
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithVoice:soundUrl withObj:obj withName:name date:date type:type] autorelease];
#else
    return [[NSBubbleData alloc] initWithVoice:soundUrl withObj:obj withName:name date:date type:type];
#endif
}

- (id)initWithVoice:(NSString *)soundUrl withObj:(ChatObject*)obj withName:(NSString*)name date:(NSDate *)date type:(NSBubbleType)type {
    _type = type;
    [self setupData:obj];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getVoiceLength:) name:@"getVoiceLength" object:nil];
    UIFont *font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    float firstWidth = 60;
    voiceView = [[UIView alloc]initWithFrame:CGRectMake(10, 0, firstWidth, 20)];
    voiceView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playVoice:)];
    [voiceView addGestureRecognizer:tap];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, firstWidth, 20)];
    label.centerY = voiceView.height/2;
    label.textColor = [UIColor blackColor];
    label.text = [NSString stringWithFormat:@"%@:",name];
    label.font = font;
    label.backgroundColor = [UIColor clearColor];
    label.userInteractionEnabled = YES;
    label.width = [label.text sizeWithFont:label.font].width;
    //[voiceView addSubview:label];
#if !__has_feature(objc_arc)
    [label autorelease];
#endif
    
    UIImageView* voice = getImageViewByImageName(@"voiceByMe.png");    
    if (type == BubbleTypeMine) {
        voice.left = 10;
    } else {
        voice.transform = CGAffineTransformMakeRotation(M_PI);
        voice.left = 10;
    }
    voice.centerY = label.centerY;
    [voiceView addSubview:voice];
    _voiceImg = voice;

    voiceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 15)];
    voiceLabel.textColor = [UIColor colorWithRed:189.0/255.0 green:189.0/255.0 blue:189.0/255.0 alpha:1.0f];
    voiceLabel.font = [UIFont systemFontOfSize:12];
    voiceLabel.backgroundColor = [UIColor clearColor];
    voiceLabel.textAlignment = NSTextAlignmentRight;
    [voiceView addSubview:voiceLabel];    
    if (!file_exists([NSString stringWithFormat:@"%@/%@",[[YXResourceManager sharedManager]getSoundDirectionary],[soundUrl lastPathComponent]])) {
        
        if ([[soundUrl lastPathComponent] hasSuffix:@"amr"]) {
            DownloadURL* down = [[DownloadURL alloc]init];
            down.chatid = self.chatObj.chatid;
            [down download:soundUrl];
            
            voiceLabel.hidden = YES;
            
            CABasicAnimation *opacityAnim1 = [CABasicAnimation animationWithKeyPath:@"opacity"];
            opacityAnim1.fromValue = [NSNumber numberWithFloat:10.0];
            opacityAnim1.toValue = [NSNumber numberWithFloat:0.1];
            opacityAnim1.duration = 0.25;
            opacityAnim1.repeatCount = 9999;
            opacityAnim1.removedOnCompletion = NO;
            
            CABasicAnimation *opacityAnim2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
            opacityAnim2.fromValue = [NSNumber numberWithFloat:0.1];
            opacityAnim2.toValue = [NSNumber numberWithFloat:1.0];
            opacityAnim1.duration = 0.25;
            opacityAnim2.removedOnCompletion = NO;
            
            CAAnimationGroup *animGroup = [CAAnimationGroup animation];
            animGroup.animations = [NSArray arrayWithObjects:opacityAnim1, opacityAnim2, nil];
            animGroup.duration = 0.5;
            animGroup.repeatCount = 99999;
            animGroup.removedOnCompletion = YES;
            [voiceView.layer addAnimation:animGroup forKey:@"animationFallingRotate"];
        }

    } else {
        
        voiceLabel.right = voiceView.width-15;
        voiceLabel.centerY = voiceView.height/2;
        if (type == BubbleTypeMine) {
            voiceLabel.right = voiceView.width-15;
        } else {
            voiceLabel.left = 10;
        }
        
        [self updateVoiceLabel:[NSString stringWithFormat:@"%@/%@",[[YXResourceManager sharedManager]getSoundDirectionary],[soundUrl lastPathComponent]] withID:self.chatObj.chatid];
    }
    
    soundPath = [NSString stringWithFormat:@"%@/%@",[[YXResourceManager sharedManager]getSoundDirectionary], [soundUrl lastPathComponent] ];
    
    UIEdgeInsets insets = (type == BubbleTypeMine ? textInsetsMine : textInsetsSomeone);
    return [self initWithView:voiceView date:date type:type insets:insets];
}

- (void)getVoiceLength:(NSNotification*)sender {
    NSDictionary* dic = (NSDictionary*)sender.object;
    [self updateVoiceLabel:[dic objectForKey:@"path"] withID:[[dic objectForKey:@"chatid"]intValue]];
}

- (void)updateVoiceLabel:(NSString*)path withID:(int)chatid {
    if (chatid == self.chatObj.chatid) {
        float length = [[YXSoundManager sharedManager]getVoiceLength:path];
        if (length < 1) {
            length = 1;
        }
        
       voiceLabel.hidden = NO;
       voiceLabel.text = [NSString stringWithFormat:@"%d''",(int)length];
       //voiceLabel.width = [voiceLabel.text sizeWithFont:voiceLabel.font].width;
       voiceView.width += (length-1)*5;
       [voiceView.layer removeAllAnimations];
       if (voiceView.width > 200) {
           voiceView.width = 200;
       }
      voiceLabel.right = voiceView.width;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"resizeBubble" object:self];
    }
}

- (void)playVoice:(UITapGestureRecognizer*)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pauseAudio" object:nil];
    if (![soundPath hasSuffix:@"amr"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息" message:@"语音文件错误!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return ;
    }
    if ([[YXSoundManager sharedManager] isPlaying]) {
        [[YXSoundManager sharedManager] playStop];
    } else {
        [[YXSoundManager sharedManager] playStop];
        if([[YXSoundManager sharedManager] playStart:soundPath]){
            [YXSoundManager sharedManager].delegate = self;
            if (_type == BubbleTypeMine) {
                _voiceImg.animationImages=[NSArray arrayWithObjects:
                                           getBundleImage(@"speakMe_1.png"),
                                           getBundleImage(@"speakMe_2.png"),
                                           getBundleImage(@"speakMe_3.png"),nil ];
            } else {
                _voiceImg.animationImages=[NSArray arrayWithObjects:                                          getBundleImage(@"speakMe_1.png"),                                          getBundleImage(@"speakMe_2.png"),                                           getBundleImage(@"speakMe_3.png"),nil ];
            }
            _voiceImg.animationDuration=1.0;
            //设定重复播放次数
            _voiceImg.animationRepeatCount=LONG_MAX;
            //开始播放动画
            [_voiceImg startAnimating];
        }
    }
}

- (void)soudnManagerPlayFinish {
    [_voiceImg stopAnimating];
    _voiceImg.image = getBundleImage(@"voiceByMe.png");
    if (_type == BubbleTypeSomeoneElse) {
        _voiceImg.transform = CGAffineTransformMakeRotation(M_PI);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"continueAudio" object:nil];
}

- (void)soudnManagerRecordFinish:(NSString *)soundDataPath {
    
}

- (void)soudnManagerError:(NSError *)error {
    [_voiceImg stopAnimating];
    _voiceImg.image = getBundleImage(@"voiceByMe.png");
    if (_type == BubbleTypeSomeoneElse) {
        _voiceImg.transform = CGAffineTransformMakeRotation(M_PI);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"continueAudio" object:nil];
}

#pragma mark - Custom view bubble

+ (id)dataWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type insets:(UIEdgeInsets)insets {
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithView:view date:date type:type insets:insets] autorelease];
#else
    return [[NSBubbleData alloc] initWithView:view date:date type:type insets:insets];
#endif    
}

- (id)initWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type insets:(UIEdgeInsets)insets {
    self = [super init];
    if (self)
    {
#if !__has_feature(objc_arc)
        _view = [view retain];
        _date = [date retain];
#else
        _view = view;
        _date = date;
#endif
        _type = type;
        _insets = insets;
    }
    return self;
}

- (UIImage *)scaleAndRotateImage:(UIImage *)image forAngle: (double) angle {    
    float radians=angle;
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0, image.size.width, image.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(radians);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //Rotate the image context
    CGContextRotateCTM(bitmap, radians);
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-image.size.width/2, -image.size.height/2 , image.size.width, image.size.height), image.CGImage );
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


+ (id)dataWithVoiceNew:(NSString *)soundUrl withObj:(ChatObject*)obj withName:(NSString*)name date:(NSDate *)date type:(NSBubbleType)type withLen:(float)len {
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithVoiceNew:soundUrl withObj:obj withName:name date:date type:type withLen:len] autorelease];
#else
    return [[NSBubbleData alloc] initWithVoiceNew:soundUrl withObj:obj withName:name date:date type:type withLen:len];
#endif
}

- (id)initWithVoiceNew:(NSString *)soundUrl withObj:(ChatObject*)obj withName:(NSString*)name date:(NSDate *)date type:(NSBubbleType)type withLen:(float)len {
    _type = type;
    [self setupData:obj];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getVoiceLength:) name:@"getVoiceLength" object:nil];
    UIFont *font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    float firstWidth = 60;
    voiceView = [[UIView alloc]initWithFrame:CGRectMake(10, 0, firstWidth, 20)];
    voiceView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playVoice:)];
    [voiceView addGestureRecognizer:tap];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, firstWidth, 20)];
    label.centerY = voiceView.height/2;
    label.textColor = [UIColor blackColor];
    label.text = [NSString stringWithFormat:@"%@:",name];
    label.font = font;
    label.backgroundColor = [UIColor clearColor];
    label.userInteractionEnabled = YES;
    label.width = [label.text sizeWithFont:label.font].width;
    //[voiceView addSubview:label];
#if !__has_feature(objc_arc)
    [label autorelease];
#endif
    
    UIImageView* voice = getImageViewByImageName(@"voiceByMe.png");
    if (type == BubbleTypeMine) {
        voice.left = 10;
    } else {
        voice.transform = CGAffineTransformMakeRotation(M_PI);
        voice.left = 10;
    }
    voice.centerY = label.centerY;
    [voiceView addSubview:voice];
    _voiceImg = voice;

    voiceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    if (!file_exists([NSString stringWithFormat:@"%@/%@",[[YXResourceManager sharedManager]getSoundDirectionary],[soundUrl lastPathComponent]])) {
        DownloadURL* down = [[DownloadURL alloc]init];
        down.chatid = self.chatObj.chatid;
        [down download:soundUrl];
        voiceLabel.hidden = YES;
    }else{

        voiceLabel.right = voiceView.width-15;
        voiceLabel.centerY = voiceView.height/2;
        voiceLabel.textColor = [UIColor colorWithRed:189.0/255.0 green:189.0/255.0 blue:189.0/255.0 alpha:1.0f];
        voiceLabel.font = [UIFont systemFontOfSize:12];
        voiceLabel.backgroundColor = [UIColor clearColor];
        [voiceView addSubview:voiceLabel];
        if (type == BubbleTypeMine) {
            voiceLabel.right = voiceView.width-15;
        } else {
            voiceLabel.left = 10;
        }
    }
    [self updateVoiceLabelNew:(int)len withID:self.chatObj.chatid];
    soundPath = [NSString stringWithFormat:@"%@/%@",[[YXResourceManager sharedManager]getSoundDirectionary], [soundUrl lastPathComponent] ];
    
    UIEdgeInsets insets = (type == BubbleTypeMine ? textInsetsMine : textInsetsSomeone);
    return [self initWithView:voiceView date:date type:type insets:insets];
}

- (void)updateVoiceLabelNew:(int)len withID:(int)chatid {
    if (chatid == self.chatObj.chatid) {
        if (len < 1) {
            len = 1;
        }
        voiceLabel.text = [NSString stringWithFormat:@"%d''",(int)len];
        voiceLabel.width = [voiceLabel.text sizeWithFont:voiceLabel.font].width;
        voiceView.width += (len-1)*5;
        if (voiceView.width > 200) {
            voiceView.width = 200;
        }
        voiceLabel.right = voiceView.width;
    }
}


@end
