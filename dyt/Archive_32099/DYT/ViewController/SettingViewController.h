//
//  SettingViewController.h
//  DYT
//
//  Created by zhaoliang.chen on 13-6-3.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraViewController.h"

@class TKImageCache;
@interface SettingViewController : UIViewController
<CameraDelegate,UIImagePickerControllerDelegate,
UINavigationControllerDelegate,UIActionSheetDelegate,
UITextFieldDelegate>{
    UIImageView* imgHead;
    UITextField* nameTextField;
    UILabel* sexLabel;
    UILabel* cityLabel;
    UILabel* jobLabel;
    UIImage *photo_;
    UIActionSheet *picActionSheet;      //照片的ActionSheet
    UIActionSheet *sexActionSheet;      //性别的ActionSheet
    UserObject* myUser;
    TKImageCache* _recvUserHeadOnSetting;
    UITableView* setTableView;
    UILabel* maskLabel;
    UITextField* posTextField;
    UIScrollView* scroll;
    
    UIView* upView;
    UIView* downView;
}

@end
