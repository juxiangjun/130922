//
//  DownloadURL.m
//  YueXingKong
//
//  Created by zhaoliang.chen on 10/9/12.
//  Copyright (c) 2012 YueXingKong. All rights reserved.
//

#import "DownloadURL.h"

@implementation DownloadURL

@synthesize receivedData;
@synthesize filename;
@synthesize m_conn;
@synthesize chatid;

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *new = [searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *urlString = [NSString stringWithFormat:@"http://192.168.1.104/test.php?cid=%@",new];
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
    NSString *strUrld8 = [urlString stringByAddingPercentEscapesUsingEncoding:enc];
    //调用http get请求方法
    [self sendRequestByGet:strUrld8];
}

- (void)download:(NSString *)url {
    int index = 0;
    for (int i=url.length-1; i>=0; i--) {
        char c = [url characterAtIndex:i];
        if (c == '/') {
            index = i+1;
            break;
        }
    }
    filename = [url substringFromIndex:index];
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
    NSString *strUrld8 = [url stringByAddingPercentEscapesUsingEncoding:enc];
    //调用http get请求方法
    [self sendRequestByGet:strUrld8];
}

//HTTP get请求方法
- (void)sendRequestByGet:(NSString*)urlString {
    NSURL *url=[NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                            timeoutInterval:60];
    //设置请求方式为get
    [request setHTTPMethod:@"GET"];
    //添加用户会话id
    [request addValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
    //连接发送请求
    receivedData=[[NSMutableData alloc] initWithData:nil];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    m_conn = conn;
}

- (void)connection:(NSURLConnection *)aConn didReceiveResponse:(NSURLResponse *)response {
    // 注意这里将NSURLResponse对象转换成NSHTTPURLResponse对象才能去
//    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
//    if ([response respondsToSelector:@selector(allHeaderFields)]) {
//        NSDictionary *dictionary = [httpResponse allHeaderFields];
//        NSLog(@"dictionary=%@",[dictionary description]);
//    }
}

//接收NSData数据
- (void)connection:(NSURLConnection *)aConn didReceiveData:(NSData *)data {
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)aConn didFailWithError:(NSError *)error{
    
}

//接收完毕,显示结果
- (void)connectionDidFinishLoading:(NSURLConnection *)aConn {
    NSString *results = [[NSString alloc]
                         initWithBytes:[receivedData bytes]
                         length:[receivedData length]
                         encoding:NSUTF8StringEncoding];
    NSString* path = [[YXResourceManager sharedManager] getSoundDirectionary];
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",filename]];
    [self writeToFile:receivedData fileName:path];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:path, @"path", [NSNumber numberWithInt:self.chatid], @"chatid", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"getVoiceLength" object:dic];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"getVoiceLengthInCell" object:dic];
    NSLog(@"path=%@,results=%@",path,results);
}

//接收的数据写入文件
-(void)writeToFile:(NSData *)data fileName:(NSString*)_fileName{
    NSString *filePath=[NSString stringWithFormat:@"%@",_fileName];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath] == NO){
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    } else {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    }
    FILE *file = fopen([_fileName UTF8String], [@"ab+" UTF8String]);
    int readSize = [data length];
    fwrite((const void *)[data bytes], readSize, 1, file);
    fclose(file);
}

- (void)cancelDownload {
    [m_conn cancel];
}


@end
