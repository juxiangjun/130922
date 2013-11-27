//
//  MyPicViewController.h
//  DYT
//
//  Created by zhaoliang.chen on 13-7-5.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyPicViewController;
@protocol MyPicViewDelete <NSObject>
@optional
- (void)finishPicture:(MyPicViewController *)picker
                array:(NSArray*)imgArray;
@end


@interface MyPicViewController : UIImagePickerController
<UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
    
}

@property (nonatomic, assign) id<MyPicViewDelete> myPicViewDelete;


@end
