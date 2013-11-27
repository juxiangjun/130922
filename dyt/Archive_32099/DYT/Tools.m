//
//  Tools.m
//  DYT
//
//  Created by zhuang yihang on 6/19/13.
//  Copyright (c) 2013 zhaoliang.chen. All rights reserved.
//

#import "Tools.h"


BOOL check_string_valid(NSString *target){
    if (![target isKindOfClass:[NSString class]]) {
        return NO;
    }
    
    if (target.length==0) {
        return NO;
    }
    
    if ([target isEqualToString:@"<null>"]) {
        return NO;
    }
    
    if ([target isEqualToString:@"(null)"]) {
        return NO;
    }
    
    return YES;
}


void set_default_portrait(UIImageView *portraitView){
    portraitView.image = [UIImage imageNamed:@"defaultHead.png"];
}