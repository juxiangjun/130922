//
//  DownloadURL.h
//  YueXingKong
//
//  Created by zhaoliang.chen on 10/9/12.
//  Copyright (c) 2012 YueXingKong. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YLProgressBar;
@class ProgressInDownload;
@class SongObject;
@interface DownloadURL : NSObject {
    
}

@property (strong, nonatomic) NSMutableData* receivedData;
@property (strong, nonatomic) NSString* filename;
@property (strong, nonatomic) NSURLConnection* m_conn;
@property (assign, nonatomic) int chatid;

- (void)download:(NSString *)url;
- (void)cancelDownload;

@end
