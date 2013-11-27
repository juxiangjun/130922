//
//  GroupPicData.m
//  DYT
//
//  Created by zhaoliang.chen on 13-6-27.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "GroupPicData.h"

@implementation GroupPicData

@synthesize groupid;
@synthesize picid;
@synthesize userid;
@synthesize thumbURL;
@synthesize picURL;
@synthesize uptime;

+ (GroupPicData*)getOnePic:(NSDictionary*)dic {
    GroupPicData* one = [[GroupPicData alloc]init];
    one.groupid = [[dic objectForKey:@"group_id"]intValue];
    one.userid = [[dic objectForKey:@"user_id"]intValue];
    one.picid = [[dic objectForKey:@"id"]intValue];
    one.thumbURL = [dic objectForKey:@"thumb"];
    one.picURL = [dic objectForKey:@"pic"];
    one.uptime = [dic objectForKey:@"time"];
    if ([GroupPicData findByGroupPic:one.groupid withPicid:one.picid]==nil) {
        [GroupPicData addOneGroupPic:one];
    }
    return one;
}

#pragma mark 数据库的操作
static sqlite3 *dbmain = nil;

+(sqlite3 *)openDB:(int)groupid {
    if(!dbmain) {
        //目标路径
        NSString *docPath = [[YXResourceManager sharedManager] getHistoryDicrectionry];
        
        //原始路径
        NSString *filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/groupList_%d.sqlite",[[DataManager sharedManager]getUser].userid]];
        if (sqlite3_open([filePath UTF8String], &dbmain) != SQLITE_OK) {
            sqlite3_close(dbmain);
            NSLog(@"数据库打开失败");
        }
    }
    
    NSString *sqlCreateTable = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS groupPic_%d ( ID  INTEGER PRIMARY KEY AUTOINCREMENT,groupid  INTEGER, userid INTEGER, picid INTEGER, thumbURL TEXT, picURL TEXT , uptime TEXT)",groupid] ;
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

//添加元素
+(void)addOneGroupPic:(GroupPicData *)one {
    sqlite3 *db = [self openDB:one.groupid];
    NSString *str = [NSString stringWithFormat:@"insert into groupPic_%d('groupid', 'userid', 'picid', 'thumbURL', 'picURL','uptime') values(%d,%d,%d,'%@','%@','%@')",one.groupid,one.groupid, one.userid,one.picid,one.thumbURL,one.picURL,one.uptime];
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(db, [str UTF8String],-1 ,&stmt , nil);
    if (result == SQLITE_OK) {
        sqlite3_step(stmt);
    } else {
        NSLog(@"数据库添加聊天记录失败!");
    }
    sqlite3_finalize(stmt);
}

+(GroupPicData *)findByGroupPic:(int)groupid withPicid:(int)picid {
    sqlite3 *db = [self openDB:groupid];
    sqlite3_stmt *stmt = nil;
    NSString *str = [NSString stringWithFormat:@"select * from groupPic_%d where picid = %d", groupid, picid];
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    GroupPicData* one = nil;
    if (result == SQLITE_OK) {
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            one = [[GroupPicData alloc]init];
            one.groupid = sqlite3_column_int(stmt, 1);
            one.userid = sqlite3_column_int(stmt, 2);
            one.picid = sqlite3_column_int(stmt, 3);
            one.thumbURL = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)];
            one.picURL = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)];
            one.uptime = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 6)];
            break;
        }
    }
    sqlite3_finalize(stmt);
    return one;
}

+(NSMutableArray*)loadGroupPic:(int)groupid {
    sqlite3 *db = [self openDB:groupid];
    NSString *str = [NSString stringWithFormat:@"select * from groupPic_%d order by uptime desc limit 0, 8", groupid];

    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    NSMutableArray* array = [NSMutableArray new];
    if (result == SQLITE_OK) {
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            GroupPicData* one = [[GroupPicData alloc]init];
            one.groupid = sqlite3_column_int(stmt, 1);
            one.userid = sqlite3_column_int(stmt, 2);
            one.picid = sqlite3_column_int(stmt, 3);
            one.thumbURL = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)];
            one.picURL = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)];
            one.uptime = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 6)];
            [array addObject:one];
        }
    } else {
        NSLog(@"提取记录失败");
    }
    sqlite3_finalize(stmt);
    return array;
}

@end
