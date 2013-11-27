//
//  ChoosePicViewController.m
//  DYT
//
//  Created by zhaoliang.chen on 13-7-3.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "ChoosePicViewController.h"

@interface ChoosePicViewController ()

@end

@implementation ChoosePicViewController

#define IMGTAG  1000

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        picCount = 0;
        arrayImage = [NSMutableArray new];
    }
    return self;
}

-(id)initWithData:(UIImage*)image {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        m_Image = image;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"选择照片";
    
    UIView* bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 50)];
    bottomView.bottom = self.view.height;
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    picScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, bottomView.width-80, 50)];
    picScrollView.backgroundColor = [UIColor clearColor];
    picScrollView.userInteractionEnabled = YES;
    [bottomView addSubview:picScrollView];
    
    UIButton* btFinish = createButton(@"finishOnChoosePic.png");
    btFinish.left = picScrollView.right+5;
    btFinish.centerY = picScrollView.centerY;
    [btFinish addTarget:self action:@selector(onFinish) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:btFinish];
    
    photoScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(10, self.navigationController.navigationBar.height+10, self.view.width-20, self.view.height-self.navigationController.navigationBar.height-picScrollView.height-20-20)];
    photoScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:photoScrollView];
    
    m_imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, photoScrollView.width, photoScrollView.height)];
    m_imgView.image = m_Image;
    if (m_Image.size.width>photoScrollView.width) {
        double radio = m_Image.size.width/photoScrollView.width;
        float height = m_Image.size.height/radio;
        [m_imgView setFrame:CGRectMake(0, 0, m_imgView.width, height)];
        if (height<=photoScrollView.height) {
            m_imgView.center = CGPointMake(photoScrollView.width/2, photoScrollView.height/2);
        }
        if (height>photoScrollView.height) {
            photoScrollView.contentSize = CGSizeMake(photoScrollView.width, height);
        }
    } else {
        double radio = m_imgView.width/m_Image.size.width;
        float height = m_Image.size.height*radio;
        [m_imgView setFrame:CGRectMake(0, 0, m_imgView.width, height)];
        if (height<=photoScrollView.height) {
            m_imgView.center = CGPointMake(photoScrollView.width/2, photoScrollView.height/2);
        }
        if (height>photoScrollView.height) {
            photoScrollView.contentSize = CGSizeMake(photoScrollView.width, height);
        }
    }
    [photoScrollView addSubview:m_imgView];
    
    UIImageView* img = [[UIImageView alloc]initWithFrame:CGRectMake(10+picCount*(40+10), 5, 40, 40)];
    img.image = m_Image;
    img.tag = IMGTAG+picCount;
    [picScrollView addSubview:img];
    [arrayImage addObject:m_Image];
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onDelete:)];
    [img addGestureRecognizer:tap];
    img.userInteractionEnabled = YES;
    picCount++;    
    
    btAddPic = createButton(@"btAddpic.png");
    btAddPic.left = img.right+10;
    btAddPic.centerY = img.centerY;
    btAddPic.tag = 999;
    [btAddPic addTarget:self action:@selector(addPic) forControlEvents:UIControlEventTouchUpInside];
    [picScrollView addSubview:btAddPic];
    
    picScrollView.contentSize = CGSizeMake(btAddPic.right+10, picScrollView.height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onFinish {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"onFinishChoose" object:arrayImage];
}

#pragma mark 照片库的操作
-(void)addPicEvent {
    UIImagePickerControllerSourceType sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        sourceType=UIImagePickerControllerSourceTypeCamera;
    }
    UIImagePickerController * picker = [[UIImagePickerController alloc]init];
    picker.delegate=self;
    picker.allowsEditing=NO;
    picker.sourceType=sourceType;
    [self.navigationController presentViewController:picker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage * image=[info objectForKey:UIImagePickerControllerOriginalImage];
    [self performSelector:@selector(updateScrollView:) withObject:image afterDelay:0.5];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateScrollView:(UIImage*)image {
    if (btAddPic) {
        [btAddPic removeFromSuperview];
        btAddPic = nil;
    }
    [m_imgView setSize:CGSizeMake(photoScrollView.width, photoScrollView.height)];
    photoScrollView.contentSize = CGSizeMake(photoScrollView.width, photoScrollView.height);
    m_imgView.image = image;
    if (image.size.width>m_imgView.width) {
        double radio = image.size.width/m_imgView.width;
        float height = image.size.height/radio;
        [m_imgView setFrame:CGRectMake(0, 0, m_imgView.width, height)];
        if (height<=photoScrollView.height) {
            m_imgView.center = CGPointMake(photoScrollView.width/2, photoScrollView.height/2);
        }
        if (height>photoScrollView.height) {
            photoScrollView.contentSize = CGSizeMake(photoScrollView.width, height);
        }
    } else {
        double radio = m_imgView.width/image.size.width;
        float height = image.size.height*radio;
        [m_imgView setFrame:CGRectMake(0, 0, m_imgView.width, height)];
        if (height<=photoScrollView.height) {
            m_imgView.center = CGPointMake(photoScrollView.width/2, photoScrollView.height/2);
        }
        if (height>photoScrollView.height) {
            photoScrollView.contentSize = CGSizeMake(photoScrollView.width, height);
        }
    }
    
    UIImageView* img = [[UIImageView alloc]initWithFrame:CGRectMake(10+picCount*(40+10), 5, 40, 40)];
    img.image = image;    
    img.tag = IMGTAG+picCount;
    [picScrollView addSubview:img];
    [arrayImage addObject:image];
    img.userInteractionEnabled = YES;
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onDelete:)];
    [img addGestureRecognizer:tap];
    picCount++;
    
    btAddPic = createButton(@"btAddpic.png");
    btAddPic.left = img.right+10;
    btAddPic.centerY = img.centerY;
    btAddPic.tag = 999;
    [btAddPic addTarget:self action:@selector(addPic) forControlEvents:UIControlEventTouchUpInside];
    [picScrollView addSubview:btAddPic];
    
    picScrollView.contentSize = CGSizeMake(btAddPic.right+10, picScrollView.height);
    
    if (btAddPic.right>picScrollView.width) {
        [picScrollView setContentOffset:CGPointMake(picScrollView.contentSize.width-picScrollView.width, 0) animated:YES];
    }
}

- (void)addPic {
    [self addPicEvent];
}

- (void)onDelete:(UITapGestureRecognizer*)sender {
    if (picCount==1) {
        [self.navigationController popViewControllerAnimated:YES];
        return ;
    }
    int tag = sender.view.tag;    
    if (tag-IMGTAG == picCount-1) {
        [m_imgView setSize:CGSizeMake(photoScrollView.width, photoScrollView.height)];
        photoScrollView.contentSize = CGSizeMake(photoScrollView.width, photoScrollView.height);
        m_imgView.image = [arrayImage objectAtIndex:picCount-2];
        if (m_imgView.image.size.width>m_imgView.width) {
            double radio = m_imgView.image.size.width/m_imgView.width;
            float height = m_imgView.image.size.height/radio;
            [m_imgView setFrame:CGRectMake(0, 0, m_imgView.width, height)];
            if (height<=photoScrollView.height) {
                m_imgView.center = CGPointMake(photoScrollView.width/2, photoScrollView.height/2);
            }
            if (height>photoScrollView.height) {
                photoScrollView.contentSize = CGSizeMake(photoScrollView.width, height);
            }
        } else {
            double radio = m_imgView.width/m_imgView.image.size.width;
            float height = m_imgView.image.size.height*radio;
            [m_imgView setFrame:CGRectMake(0, 0, m_imgView.width, height)];
            if (height<=photoScrollView.height) {
                m_imgView.center = CGPointMake(photoScrollView.width/2, photoScrollView.height/2);
            }
            if (height>photoScrollView.height) {
                photoScrollView.contentSize = CGSizeMake(photoScrollView.width, height);
            }
        }
    }
    for (UIView* v in picScrollView.subviews) {
        if (v.tag > 100) {
            [v removeFromSuperview];
        }
    }
    UIImageView *deleteV = (UIImageView*)sender.view;
    for (int i=0; i<arrayImage.count; i++) {
        UIImage* image = [arrayImage objectAtIndex:i];
        if (image == deleteV.image) {
            [arrayImage removeObjectAtIndex:i];
            break;
        }
    }
    for (int i=0; i<arrayImage.count; i++) {
        UIImage* image = [arrayImage objectAtIndex:i];
        UIImageView* img = [[UIImageView alloc]initWithFrame:CGRectMake(10+i*(40+10), 5, 40, 40)];
        img.image = image;
        img.tag = IMGTAG+i;
        [picScrollView addSubview:img];
        img.userInteractionEnabled = YES;
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onDelete:)];
        [img addGestureRecognizer:tap];
        if (i==arrayImage.count-1) {      
            btAddPic = createButton(@"btAddpic.png");
            btAddPic.left = img.right+10;
            btAddPic.centerY = img.centerY;
            btAddPic.tag = 999;
            [btAddPic addTarget:self action:@selector(addPic) forControlEvents:UIControlEventTouchUpInside];
            [picScrollView addSubview:btAddPic];
        }
    }
    picScrollView.contentSize = CGSizeMake(btAddPic.right+10, picScrollView.height);
    if (btAddPic.right>picScrollView.width) {
        [picScrollView setContentOffset:CGPointMake(picScrollView.contentSize.width-picScrollView.width, 0) animated:YES];
    }
    
    picCount = arrayImage.count;
}

@end
