//
//  CameraViewController.h
//  YueXingKong
//
//  Created by zhaoliang.chen on 9/19/12.
//  Copyright (c) 2012 YueXingKong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CameraViewController;

@protocol CameraDelegate <NSObject>

- (void)cameraTake:(CameraViewController *)picker
             image:(UIImage *)takeImage;

@end

@interface CameraViewController : UIImagePickerController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    UIView *filterView;
    
    UIImageView *sourceView;
    
    UIImage *originalImage;
}

@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, assign) id<CameraDelegate> cameraDelegate;

@end
