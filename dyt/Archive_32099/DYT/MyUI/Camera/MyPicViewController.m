//
//  MyPicViewController.m
//  DYT
//
//  Created by zhaoliang.chen on 13-7-5.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "MyPicViewController.h"
#import "ChoosePicViewController.h"
#import "Global.h"
@interface MyPicViewController ()

@end

@implementation MyPicViewController

@synthesize myPicViewDelete;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFinishChoose:) name:@"onFinishChoose" object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onFinishChoose:(NSNotification*)sender{
    NSArray* array = (NSArray*)sender.object;
    [myPicViewDelete finishPicture:self array:array];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage * image=[info objectForKey:UIImagePickerControllerOriginalImage];
    
    float maxWidthScale = 840;
    float maxHeightScale = 1024;
    CGSize size;
    if (image.size.width>image.size.height && image.size.height > maxHeightScale) {
        size = CGSizeMake(maxHeightScale/image.size.height*image.size.width, maxHeightScale);
        image = [[Global sharedInstance] imageWithImage:image scaledToSize:size];//[image imageToFitSize:size method:MGImageResizeScale];
    }else if(image.size.width<image.size.height && image.size.width > maxWidthScale){
        size = CGSizeMake(maxWidthScale, maxWidthScale/image.size.width*image.size.height);
        image = [[Global sharedInstance] imageWithImage:image scaledToSize:size];
    }
    
    ChoosePicViewController* v = [[ChoosePicViewController alloc]initWithData:image];
    [self pushViewController:v animated:YES];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
