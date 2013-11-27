//
//  LoginViewController.h
//  DYT
//
//  Created by zhaoliang.chen on 13-5-31.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
<UITextFieldDelegate> {
}

@property(nonatomic,strong)UITextField* nameTextField;
@property(nonatomic,strong)UITextField* psdTextField;
@property(atomic,assign)BOOL isRecv;

@end
