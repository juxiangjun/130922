//
//  AnnObject.m
//  DYT
//
//  Created by zhaoliang.chen on 13-6-7.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "AnnObject.h"

@implementation AnnObject

@synthesize publishTime;
@synthesize content;
@synthesize annID;
@synthesize picURL;
@synthesize state;
@synthesize title;
@synthesize videoURL;
@synthesize videoPic;

+ (AnnObject*)getOneAnnObject:(NSDictionary*)dic {
    AnnObject* one = [[AnnObject alloc]init];
    one.publishTime = [dic objectForKey:@"TIME"];
    one.content = [dic objectForKey:@"content"];
    one.annID = [[dic objectForKey:@"id"]intValue];
    one.picURL = [dic objectForKey:@"pic"];
    if ([[dic objectForKey:@"state"] isKindOfClass:[NSNumber class]]) {
        one.state = [[dic objectForKey:@"state"]intValue];
    } else {
        one.state = 1;
    }
    one.videoURL = [dic objectForKey:@"video"];
    one.videoPic = [dic objectForKey:@"video_pic"];
    one.title = [dic objectForKey:@"title"];
    return one;
}

#pragma mark 数据库的操作
static sqlite3 *dbmain = nil;

+(sqlite3 *)openDB {
    if(!dbmain) {
        //目标路径
        NSString *docPath = [[YXResourceManager sharedManager] getHistoryDicrectionry];
        
        //原始路径
        NSString *filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/Announcement_%d.sqlite",[[DataManager sharedManager]getUser].userid]];
        if (sqlite3_open([filePath UTF8String], &dbmain) != SQLITE_OK) {
            sqlite3_close(dbmain);
            NSLog(@"数据库打开失败");
        }
    }
    
    NSString *sqlCreateTable = @"CREATE TABLE IF NOT EXISTS Ann ( annID INTEGER PRIMARY KEY AUTOINCREMENT,publishTime  TEXT, title TEXT, content TEXT, videoURL TEXT, videoPic TEXT, picURL TEXT)";
    char *err;
    if (sqlite3_exec(dbmain, [sqlCreateTable UTF8String], NULL, NULL, &err) != SQLITE_OK) {
        sqlite3_close(dbmain);
        NSLog(@"数据库创建聊天记录表失败!");
    }
    return dbmain;
}

-(void)closeDB {
    if (dbmain) {
        sqlite3_close(dbmain);
    }
}

+ (void)closeSql {
    if (dbmain) {
        sqlite3_close(dbmain);
    }
    dbmain = nil;
}

+(AnnObject *)findAnnByID:(int)annID {
    sqlite3 *db = [self openDB];
    sqlite3_stmt *stmt = nil;
    NSString *str = [NSString stringWithFormat:@"select * from Ann where annID = %d", annID];
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    AnnObject* one = nil;
    if (result == SQLITE_OK) {
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            one = [[AnnObject alloc]init];
            one.annID = sqlite3_column_int(stmt, 0);
            one.publishTime = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)];
            one.title = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)];
            one.content = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3)];
            one.videoURL = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)];
            one.videoPic = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)];
            one.picURL = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 6)];
            break;
        }
    }
    sqlite3_finalize(stmt);
    return one;
}

//添加元素
+(void)addOneAnn:(AnnObject *)one {
    sqlite3 *db = [self openDB];
    one.content = [one.content stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    one.title = [one.title stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *str = [NSString stringWithFormat:@"insert into Ann('annID', 'publishTime', 'title', 'content', 'videoURL', 'videoPic', 'picURL') values(%d,'%@','%@','%@','%@','%@','%@')",one.annID, one.publishTime,one.title,one.content,one.videoURL,one.videoPic,one.picURL];
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(db, [str UTF8String],-1 ,&stmt , nil);
    if (result == SQLITE_OK) {
        sqlite3_step(stmt);
    } else {
        NSLog(@"数据库添加一条公告失败!");
    }
    sqlite3_finalize(stmt);
}

+(NSMutableArray*)loadAnnList:(int)point {
    sqlite3 *db = [self openDB];
    NSString *str = [NSString stringWithFormat:@"select * from Ann order by annID DESC limit %d, %d", point, NOTICELIMIT];
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    NSMutableArray* array = [NSMutableArray new];
    if (result == SQLITE_OK) {
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            AnnObject* one = [[AnnObject alloc]init];
            one.annID = sqlite3_column_int(stmt, 0);
            one.publishTime = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)];
            one.title = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)];
            one.content = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3)];
            one.videoURL = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)];
            one.videoPic = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)];
            one.picURL = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 6)];
            [array addObject:one];
        }
    } else {
        NSLog(@"提取公告记录失败");
    }
    sqlite3_finalize(stmt);
    return array;
}

+(int)getAnnCount{
    sqlite3 *db = [self openDB];
    NSString *str = @"select count(*) from Ann";
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    if (result == SQLITE_OK) {
        int count = 0;
        if (sqlite3_step(stmt)) {
            count = sqlite3_column_int(stmt, 0);
        }
        sqlite3_finalize(stmt);
        return count;
    } else {
        NSLog(@"提取公告记录失败");
        sqlite3_finalize(stmt);
        return -1;
    }
}

+(AnnObject*)getFirstAnn {
    sqlite3 *db = [self openDB];
    NSString *str = @"select * from Ann order by annID DESC";
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    AnnObject* one = nil;
    if (result == SQLITE_OK) {
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            one = [[AnnObject alloc]init];
            one.annID = sqlite3_column_int(stmt, 0);
            one.publishTime = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)];
            one.title = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)];
            one.content = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3)];
            one.videoURL = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)];
            one.videoPic = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)];
            one.picURL = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 6)];
            break;
        }
    } else {
        NSLog(@"提取第一条公告失败");
    }
    sqlite3_finalize(stmt);
    return one;
}

@end
