//
//  ChangePWDViewController.h
//  DYT
//
//  Created by zhaoliang.chen on 13-6-7.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangePWDViewController : UIViewController
<UITextFieldDelegate>{
    UITextField* oldPwd;
    UITextField* newPwd;
    UITextField* comfirmNewPwd;
}

@end
