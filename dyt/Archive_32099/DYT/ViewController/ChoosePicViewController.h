//
//  ChoosePicViewController.h
//  DYT
//
//  Created by zhaoliang.chen on 13-7-3.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraViewController.h"

@interface ChoosePicViewController : UIViewController
<UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    UIImageView* m_imgView;
    UIScrollView* picScrollView;
    UIScrollView* photoScrollView;
    int picCount;
    NSMutableArray* arrayImage;
    UIButton* btAddPic;
    UIImage* m_Image;
}

-(id)initWithData:(UIImage*)image;

@end
