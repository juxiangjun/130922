//
//  ChatObject.m
//  DYT
//
//  Created by zhaoliang.chen on 13-6-8.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "ChatObject.h"

@implementation ChatObject

@synthesize chatTime;
@synthesize strTime;
@synthesize groupid;
@synthesize chatid;
@synthesize userid;
@synthesize type;
@synthesize content;
@synthesize thumbURL;
@synthesize chatStatus;
@synthesize chatKey;
@synthesize userName;
@synthesize sendImg;
@synthesize millisecond;

+(ChatObject*)getOneChat:(NSDictionary*)dic {
    ChatObject* one = [[ChatObject alloc]init];
    
    [ChatObject initObject:one byDictionary:dic];

    one.chatStatus = eChatObjectStatus_Sending;
    return one;
}

+ (void)initObject:(ChatObject *)one byDictionary:(NSDictionary *)dic{
    //one.strTime = [NSString stringWithFormat:@"%@.%@",[dic objectForKey:@"TIME"],[dic objectForKey:@"send_time_milli"]];
    //one.chatTime = formatStringToDateMilli(one.strTime);
    one.strTime = [dic objectForKey:@"TIME"];
    one.chatTime = formatStringToDateEx(one.strTime);
    one.groupid = [[dic objectForKey:@"group_id"]intValue];
    one.chatid = [[dic objectForKey:@"id"]intValue];
    one.type = [[dic objectForKey:@"type"]intValue];
    one.userid = [[dic objectForKey:@"userid"]intValue];
    one.millisecond = [[dic objectForKey:@"send_time_milli"]intValue];

    if ([[dic objectForKey:@"param"] isKindOfClass:[NSString class]]) {
        one.chatKey = [[dic objectForKey:@"param"] intValue];
    } else {
        one.chatKey = 0;
    }
    
    if ([[dic objectForKey:@"content"] isKindOfClass:[NSString class]]) {
        one.content = [dic objectForKey:@"content"];
    } else {
        one.content = @"";
    }
    one.userName = [dic objectForKey:@"user_name"];
    if ([one.userName isKindOfClass:[NSNull class]] || [one.userName rangeOfString:@"null" options:NSCaseInsensitiveSearch].length>0 || one.userName==nil) {
        one.userName = @"";
    }
    one.thumbURL = [dic objectForKey:@"thumb"];
    if ([one.thumbURL isKindOfClass:[NSNull class]] || [one.thumbURL rangeOfString:@"null" options:NSCaseInsensitiveSearch].length>0 || one.thumbURL==nil) {
        one.thumbURL = @"";
    }
    
}


- (id)init{
    self = [super init];
    if (self) {
        self.chatTime = [NSDate date];
        self.groupid = 0;
        self.chatid = 0;
        self.type = 0;
        self.chatKey = -1;
        self.userid = 0;
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setTimeZone:[NSTimeZone defaultTimeZone]];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        self.strTime = [dateFormat stringFromDate:self.chatTime];
    }
    
    return self;
}





#pragma mark 数据库的操作
static sqlite3 *dbmain = nil;

+(sqlite3 *)openDB:(int)groupid {
    if(!dbmain) {
        //目标路径
        NSString *docPath = [[YXResourceManager sharedManager] getHistoryDicrectionry];

        //原始路径
        NSString *filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/chatList_%d.sqlite",[[DataManager sharedManager]getUser].userid]];
        if (sqlite3_open([filePath UTF8String], &dbmain) != SQLITE_OK) {
            sqlite3_close(dbmain);
            NSLog(@"数据库打开失败");
        }
    }
    
    NSString *sqlCreateTable = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS chat_%d ( ID  INTEGER PRIMARY KEY AUTOINCREMENT,groupid  INTEGER, userid INTEGER, chatid INTEGER, content TEXT, thumb TEXT, publishTime TEXT, type INTEGER, status INTEGER)",groupid] ;
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

//0为全部取，1为只取图片
+(NSMutableArray *)findByGroupid:(int)groupid withType:(int)type {
    sqlite3 *db = [self openDB:groupid];
    sqlite3_stmt *stmt = nil;
    NSString *str = [NSString stringWithFormat:@"select * from chat_%d order by ID",groupid];
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    NSMutableArray* array = [NSMutableArray new];
    if (result == SQLITE_OK) {
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            ChatObject* one = [[ChatObject alloc]init];
            one.chatKey = sqlite3_column_int(stmt, 0);
            one.groupid = sqlite3_column_int(stmt, 1);
            one.userid = sqlite3_column_int(stmt, 2);
            one.chatid = sqlite3_column_int(stmt, 3);
            one.content = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)];
            one.thumbURL = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)];
            one.strTime = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 6)];
            one.type = sqlite3_column_int(stmt, 7);
            //if (one.chatid!=0) {
                if (type==0) {
                    [array addObject:one];
                } else if (type==1) {
                    if (one.type == 2) {
                        [array addObject:one];
                    }
                }
            //}
        }
    }
    sqlite3_finalize(stmt);
    return array;
}

+(ChatObject *)findByChatid:(int)groupid withChatid:(int)chatid {
    sqlite3 *db = [self openDB:groupid];
    sqlite3_stmt *stmt = nil;
    NSString *str = [NSString stringWithFormat:@"select * from chat_%d where chatid = %d", groupid,chatid];
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    ChatObject* one = nil;
    if (result == SQLITE_OK) {
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            one = [[ChatObject alloc]init];
            one.chatKey = sqlite3_column_int(stmt, 0);
            one.groupid = sqlite3_column_int(stmt, 1);
            one.userid = sqlite3_column_int(stmt, 2);
            one.chatid = sqlite3_column_int(stmt, 3);
            one.content = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)];
            one.thumbURL = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)];
            one.strTime = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 6)];
            one.type = sqlite3_column_int(stmt, 7);
            break;
        }
    }
    sqlite3_finalize(stmt);
    return one;
}

//添加元素
+(int)addOneChat:(ChatObject *)one {
    
    
    ChatObject *isExist = [ChatObject findByChatid:one.groupid withChatid:one.chatid];
    if (isExist!=nil && one.chatid>0) {
        return 0;
    }
    
    sqlite3 *db = [self openDB:one.groupid];
    one.content = [one.content stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *str = [NSString stringWithFormat:@"insert into chat_%d('groupid', 'userid', 'chatid', 'content', 'thumb', 'publishTime', 'type','status') values(%d,%d,%d,'%@','%@','%@',%d,%d)",one.groupid,one.groupid, one.userid,one.chatid,one.content,one.thumbURL,one.strTime,one.type,one.chatStatus];
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(db, [str UTF8String],-1 ,&stmt , nil);
    if (result == SQLITE_OK) {
        sqlite3_step(stmt);
    } else {
        NSLog(@"数据库添加聊天记录失败!");
    }
    sqlite3_finalize(stmt);
    
    sqlite3_stmt *init_statement = nil;
    NSString *sqlNsStr = [NSString stringWithFormat:@"select * from chat_%d order by ID desc",one.groupid];
    const char *sql = [sqlNsStr cStringUsingEncoding:NSUTF8StringEncoding];
    int lastrec=0;
    //    if(sqlite3_open([dbPath UTF8String], &masterDB) == SQLITE_OK){
    if (sqlite3_prepare_v2(db, sql, -1, &init_statement, NULL) == SQLITE_OK) {
        while(sqlite3_step(init_statement) == SQLITE_ROW) {
            lastrec = sqlite3_column_int(init_statement, 0);
            break;
        }
        sqlite3_reset(init_statement);
    }
    return lastrec;
}

//更新聊天记录
+(void)updateOneChatState:(ChatObject *)one {
    NSString *str = [NSString stringWithFormat:@"update chat_%d set status = %d where ID = %d", one.groupid, one.chatStatus, one.chatKey];
    sqlite3 *db = [self openDB:one.groupid];
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    if (result == SQLITE_OK) {
        sqlite3_step(stmt);
    } else {
        NSLog(@"更新状态失败");
    }
    sqlite3_finalize(stmt);
}

+(void)sortChat:(int)groupid {
    sqlite3 *db = [self openDB:groupid];
    NSString *str = [NSString stringWithFormat:@"select * from chat_%d order by ID",groupid];
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(db, [str UTF8String],-1 ,&stmt , nil);
    if (result == SQLITE_OK) {
        sqlite3_step(stmt);
    } else {
        NSLog(@"数据库排序聊天记录失败!");
    }
    sqlite3_finalize(stmt);
}

+(NSArray*)loadChatList:(int)groupid withPT:(int)point withALL:(BOOL)isAll {
    sqlite3 *db = [self openDB:groupid];
    NSString *str ;
    if (isAll) {
        str = [NSString stringWithFormat:@"select * from chat_%d order by ID DESC limit 0,%d",groupid,point];
    } else {
        str = [NSString stringWithFormat:@"select * from chat_%d order by ID DESC limit %d,%d",groupid,point*ONECHATINPAGE-ONECHATINPAGE,ONECHATINPAGE];
    }
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    NSMutableArray* array = [NSMutableArray new];
    if (result == SQLITE_OK) {
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            ChatObject* one = [[ChatObject alloc]init];
            one.chatKey = sqlite3_column_int(stmt, 0);
            one.groupid = sqlite3_column_int(stmt, 1);
            one.userid = sqlite3_column_int(stmt, 2);
            one.chatid = sqlite3_column_int(stmt, 3);
            one.content = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)];
            one.thumbURL = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)];
            one.strTime = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 6)];
            one.type = sqlite3_column_int(stmt, 7);
            one.chatStatus = sqlite3_column_int(stmt, 8);
            [array addObject:one];
        }
    } else {
        NSLog(@"提取记录失败");
    }
    sqlite3_finalize(stmt);
    return array;
}

+(NSMutableArray *)findPicByGroupid:(int)groupid {
    sqlite3 *db = [self openDB:groupid];
    sqlite3_stmt *stmt = nil;
    NSString *str = [NSString stringWithFormat:@"select * from chat_%d order by ID ",groupid];
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    NSMutableArray* array = [NSMutableArray new];
    if (result == SQLITE_OK) {
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            NSString* content = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)];
            NSString* thumbURL = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)];
            int type = sqlite3_column_int(stmt, 7);
            //int chatid = sqlite3_column_int(stmt, 3);
            if (type==2) {
                NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:thumbURL, @"thumb", content, @"content", nil];
                [array addObject:dic];
            }
        }
    }
    sqlite3_finalize(stmt);
    return array;
}

//根据ID删除信息
+(void)deleteOneChatList:(int)groupid {
    NSString *str = [NSString stringWithFormat:@"delete from chat_%d",groupid];
    sqlite3 *db = [self openDB:groupid];
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    if (result == SQLITE_OK) {
        sqlite3_step(stmt);
    }
    sqlite3_finalize(stmt);
}

//根据chatid删除信息
+(void)deleteOneChatByChatid:(int)groupid withChatid:(int)chatid {
    NSString *str = [NSString stringWithFormat:@"delete from chat_%d where chatid = %d",groupid,chatid];
    sqlite3 *db = [self openDB:groupid];
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    if (result == SQLITE_OK) {
        sqlite3_step(stmt);
    } else {
        NSLog(@"删除聊天记录失败");
    }
    sqlite3_finalize(stmt);
}

//根据chatkey删除信息
+(void)deleteOneChatByChatkey:(int)groupid withChatkey:(int)chatkey {
    NSString *str = [NSString stringWithFormat:@"delete from chat_%d where ID = %d",groupid,chatkey];
    sqlite3 *db = [self openDB:groupid];
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    if (result == SQLITE_OK) {
        sqlite3_step(stmt);
    } else {
        NSLog(@"删除聊天记录失败");
    }
    sqlite3_finalize(stmt);
}

@end
