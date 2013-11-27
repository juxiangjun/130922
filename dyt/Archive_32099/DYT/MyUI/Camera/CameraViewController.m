//
//  CameraViewController.m
//  YueXingKong
//
//  Created by zhaoliang.chen on 9/19/12.
//  Copyright (c) 2012 YueXingKong. All rights reserved.
//

#import "CameraViewController.h"
#import "ImageFilter.h"
#import "UITools.h"
#import "UIImage+Resize.h"

#define FILETER_NUMBER 5

@interface CameraViewController ()

@end

@implementation CameraViewController
@synthesize cameraDelegate,originalImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.delegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    //[picker dismissModalViewControllerAnimated:YES];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    //    [cameraDelegate cameraTake:self image:image];
    self.originalImage = image;
    
    filterView = [[UIView alloc] initWithFrame:self.view.bounds];
    filterView.height -= 20;
    filterView.top += 20;
    [self.view addSubview:filterView];
    filterView.backgroundColor = [UIColor blackColor];
    
    sourceView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, filterView.width, filterView.height - 80)];
    [filterView addSubview:sourceView];
    sourceView.backgroundColor = [UIColor clearColor];
    sourceView.image = image;
    sourceView.contentMode = UIViewContentModeScaleAspectFit;
    
    
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:
                            CGRectMake(0, 0, sourceView.width, 80)];
    [filterView addSubview:scroll];
    scroll.top = sourceView.bottom;
    
    int buttonSize = 60;
    
    UIImage *img = [originalImage resizedImage:CGSizeMake(buttonSize, buttonSize) interpolationQuality:kCGInterpolationDefault];
    
    for (int i = 0; i < FILETER_NUMBER; i++) {
        UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
        b.frame = CGRectMake(0, 0, buttonSize, buttonSize);
        b.center = CGPointMake(0, scroll.height/2);
        b.left = i *( b.width + 10 );
        [b setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        b.tag = i;
        [b addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [scroll addSubview:b];
        
        UIImage *bg = nil;
        int value = 2;
        switch (b.tag) {
            case 0:
                bg = img;
                break;
            case 1:
                value = 3;
                bg = [img posterize:(int)(value*10)];
                break;
            case 2:
                bg = [img saturate:(1+value-0.5)];
                break;
            case 3:
                bg = [img brightness:(1+value-0.5)];
                break;
            case 4:
                bg = [img contrast:(1+value-0.5)];
                break;
            case 5:
                value = 1;
                bg = [img gamma:(1+value-0.5)];
                break;
                
        }
        
        [b setImage:bg forState:UIControlStateNormal];
    }
    
    
    scroll.contentSize = CGSizeMake(FILETER_NUMBER*(buttonSize+10), buttonSize);
    
    UIImageView *imgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navBG.png"]];
    [filterView addSubview:imgV];
    imgV.userInteractionEnabled = YES;
    
    UILabel *l = [[UILabel alloc] initWithFrame:imgV.bounds];
    [imgV addSubview:l];
    l.text = @"选择滤镜";
    l.backgroundColor = [UIColor clearColor];
    l.textColor = [UIColor whiteColor];
    l.textAlignment = NSTextAlignmentCenter;
    l.font = [UIFont systemFontOfSize:20];
    
    
    UIButton *back = createButton(@"btBack.png");
    [imgV addSubview:back];
    [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    back.center = CGPointMake(0, imgV.height/2);
    back.left = 0;
    
    
    UIButton *go = createButton(@"btFinish.png");
    go.frame = back.frame;
    [imgV addSubview:go];
    [go addTarget:self action:@selector(go) forControlEvents:UIControlEventTouchUpInside];
    go.top = back.top;
    go.right = filterView.width-back.left-5;
}

- (void)buttonClicked:(UIButton *)b{
    float value = 2;
    switch (b.tag) {
        case 0:
            sourceView.image = originalImage;
            break;
		case 1:
            value = 0.5;
			sourceView.image = [originalImage posterize:(int)(value*10)];
			break;
		case 2:
			sourceView.image = [originalImage saturate:(1+value-0.5)];
			break;
		case 3:
			sourceView.image = [originalImage brightness:(1+value-0.5)];
			break;
		case 4:
            value = 1;
			sourceView.image = [originalImage contrast:(1+value-0.5)];
			break;
		case 5:
            value = 1;
			sourceView.image = [originalImage gamma:(1+value-0.5)];
			break;
            
    }
}

- (void)go{
    [cameraDelegate cameraTake:self image:sourceView.image];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [cameraDelegate cameraTake:self image:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)back{
    [filterView removeFromSuperview];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.parentViewController presentViewController:self animated:YES completion:nil];
    
    //    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    //    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
    //        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //    }
    //    self.allowsEditing = YES;
    //    self.sourceType = sourceType;
    
    //self.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
}


@end
