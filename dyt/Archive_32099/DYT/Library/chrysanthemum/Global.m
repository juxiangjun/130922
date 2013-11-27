//
//  Global.m
//  YueXingKong
//
//  Created by yihang zhuang on 8/9/12.
//  Copyright (c) 2012 YueXingKong. All rights reserved.
//

#import "Global.h"

//NSString *formatDateToString( NSDate *date ){
//    NSString *s = [NSString stringWithFormat:@"%04d-%02d-%02d",
//                   date.year,date.month,date.day];
//    return s;
//}
//
//NSDate *formatStringToDate( NSString *string ){
//    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setTimeZone:[NSTimeZone defaultTimeZone];];
//    [dateFormat setDateFormat:@"yyyy-MM-dd"];
//    NSDate *date = [dateFormat dateFromString:string];
//    return date;
//}

static MBProgressHUD *gsProgress = nil;;
void showProgressView(){
    if (gsProgress) {
        return;
    }
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];    
    gsProgress = [MBProgressHUD showHUDAddedTo:window animated:YES];
    gsProgress.removeFromSuperViewOnHide = YES;
}
void hideProgressView(){
    [gsProgress hide:YES];
    gsProgress = nil;
}

void update_portrait_bg(UIView *v){
    v.layer.borderWidth = 1;
    v.layer.borderColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:0.5].CGColor;
    v.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    v.layer.shadowColor = [UIColor grayColor].CGColor;
    v.layer.shadowOffset = CGSizeMake(0.5,-0.5);
    v.layer.shadowOpacity = 0.2;
}

//NSDate *formatStringToDateEx( NSString *string ){
//    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setTimeZone:[NSTimeZone defaultTimeZone];];
//    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSDate *date = [dateFormat dateFromString:string];
//    
//    NSTimeZone *zone = [NSTimeZone systemTimeZone];
//    NSInteger interval = [zone secondsFromGMTForDate: date];
//    NSDate *localeDate = [date  dateByAddingTimeInterval:-interval];
//    
//    return localeDate;
//}

















