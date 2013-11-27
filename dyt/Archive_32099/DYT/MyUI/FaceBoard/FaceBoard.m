//
//  FaceBoard.m
//
//  Created by blue on 12-9-26.
//  Copyright (c) 2012年 blue. All rights reserved.
//  Email - 360511404@qq.com
//  http://github.com/bluemood

#import "FaceBoard.h"

@implementation FaceBoard

- (void)dealloc
{
//    [_faceMap release];
//    [_inputTextField release];
//    [_inputTextView release];
//    [faceView release];
//    [facePageControl release];
//    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:243.0/255.0 green:243.0/255.0 blue:243.0/255.0 alpha:1];
        //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
        //if ([[languages objectAtIndex:0] hasPrefix:@"zh"]) {
        //    _faceMap = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"faceMap_ch" ofType:@"plist"]];
        //} else {
            _faceMap = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"faceMap_en" ofType:@"plist"]];
        //}
        
        int max_row = 3;
        int max_col = 7;
        int page_number = max_row*max_col;
        int emoji_size = 44;
        
        UIView *bottomBoard = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 44)];
        bottomBoard.backgroundColor = [UIColor colorWithRed:49/255.0 green:52/255.0 blue:53/255.0 alpha:1];
        [self addSubview:bottomBoard];
        bottomBoard.bottom = self.height;
        
        UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *img = [UIImage imageNamed:@"group_default.png"];
        [b setImage:img forState:UIControlStateNormal];
        b.frame = CGRectMake(0, -2, img.size.width, img.size.height);
        [bottomBoard addSubview:b];
        b.left = 0;
        
        UIButton *send = [UIButton buttonWithType:UIButtonTypeCustom];
        img = [UIImage imageNamed:@"face_send.png"];
        [send setImage:img forState:UIControlStateNormal];
        send.frame = CGRectMake(0, 0, img.size.width, img.size.height+6);
        [bottomBoard addSubview:send];
        send.center = CGPointMake(0, bottomBoard.height/2);
        send.right = bottomBoard.width;
        [send addTarget:self action:@selector(sendmsg) forControlEvents:UIControlEventTouchUpInside];
        
        //表情盘
        faceView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.width, emoji_size*max_row+10)];
        faceView.pagingEnabled = YES;
        faceView.contentSize = CGSizeMake((_faceMap.allKeys.count/page_number+1)*faceView.width, faceView.height);
        faceView.showsHorizontalScrollIndicator = NO;
        faceView.showsVerticalScrollIndicator = NO;
        faceView.delegate = self;
        
        int page = _faceMap.allKeys.count/page_number+1;
        
        int number = _faceMap.allKeys.count+page;
        
        int j = 0;
        for (int idx = 1; idx<=number; idx++) {
            
            int facePage = idx/page_number;
            if ((idx-1)%(page_number)==page_number-1) {
                //删除键
                UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
                [back setTitle:@"删除" forState:UIControlStateNormal];
                [back setImage:[UIImage imageNamed:@"backFace"] forState:UIControlStateNormal];
                [back setImage:[UIImage imageNamed:@"backFaceSelect"] forState:UIControlStateSelected];
                [back addTarget:self action:@selector(backFace) forControlEvents:UIControlEventTouchUpInside];
                back.frame = CGRectMake((((idx-1)%page_number)%max_col)*emoji_size+6+((idx-1)/page_number*320), (((idx-1)%page_number)/max_col)*emoji_size+8, emoji_size, emoji_size);
                [faceView addSubview:back];
            }else{
                
                j = idx -facePage;
                FaceButton *faceButton = [FaceButton buttonWithType:UIButtonTypeCustom];
                faceButton.buttonIndex = j;
                
                [faceButton addTarget:self
                               action:@selector(faceButton:)
                     forControlEvents:UIControlEventTouchUpInside];
                
                //计算每一个表情按钮的坐标和在哪一屏
                faceButton.frame = CGRectMake((((idx-1)%page_number)%max_col)*emoji_size+6+((idx-1)/page_number*320), (((idx-1)%page_number)/max_col)*emoji_size+8, emoji_size, emoji_size);
                
                [faceButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%03d",j]] forState:UIControlStateNormal];
                [faceView addSubview:faceButton];
            }
        }
        
        //添加PageControl
        facePageControl = [[GrayPageControl alloc]initWithFrame:CGRectMake(110, 190, 100, 20)];
        facePageControl.center = CGPointMake(self.width/2, 0);
        facePageControl.top = faceView.bottom;
        
        [facePageControl addTarget:self
                            action:@selector(pageChange:)
                  forControlEvents:UIControlEventValueChanged];
        
        facePageControl.numberOfPages = 85/page_number+1;
        facePageControl.currentPage = 0;
        [self addSubview:facePageControl];
        
        //添加键盘View
        [self addSubview:faceView];
        
//        UIButton* send = getButtonByImageName(@"sendExp.png");
//
//        send.top=back.top;
//        send.right=back.left;
//        [self addSubview:send];
    }
    return self;
}

//停止滚动的时候
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [facePageControl setCurrentPage:faceView.contentOffset.x/320];
    [facePageControl updateCurrentPageDisplay];
}

- (void)pageChange:(id)sender {
    [faceView setContentOffset:CGPointMake(facePageControl.currentPage*320, 0) animated:YES];
    [facePageControl setCurrentPage:facePageControl.currentPage];
}

- (void)faceButton:(id)sender {
    int i = ((FaceButton*)sender).buttonIndex;
    NSString* faceString = [_faceMap objectForKey:[NSString stringWithFormat:@"%03d",i]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"onRecvEmjoy" object:faceString];
}

- (void)backFace{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"onRecvDeleteEmjoy" object:nil];
}

- (void)sendmsg {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sendChatMsg" object:nil];
}

@end
