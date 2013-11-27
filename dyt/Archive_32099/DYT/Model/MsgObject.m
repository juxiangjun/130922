//
//  MsgObject.m
//  DYT
//
//  Created by zhaoliang.chen on 13-6-7.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "MsgObject.h"

@implementation MsgObject

@synthesize msgTime;
@synthesize content;
@synthesize groupid;
@synthesize groupName;
@synthesize msgid;
@synthesize state;
@synthesize type;
@synthesize userid;
@synthesize picURL;
@synthesize arrayChat;
@synthesize numOfMember;
@synthesize lastName;
@synthesize lastContent;
@synthesize lastTime;
@synthesize subGroupid;
@synthesize subGroupName;
@synthesize subGroupHead;
@synthesize newMsgCount;
@synthesize lastMilli;

+(MsgObject*)getOneMsg:(NSDictionary*)dic {
    
    MsgObject* one = [[MsgObject alloc]init];
    one.groupid = [[dic objectForKey:@"mainGroupId"]intValue];
    one.groupName = [dic objectForKey:@"mainGroupName"];
    one.picURL = [dic objectForKey:@"mainGroupPic"];
    one.numOfMember = [[dic objectForKey:@"memberCount"]intValue];
    GroupObject* mainG = [[GroupObject alloc]init];
    mainG.groupid = one.groupid;
    mainG.groupName = one.groupName;
    mainG.groupHead = one.picURL;
    mainG.parentid = -1;
    mainG.memberCount = one.numOfMember;
    mainG.remark = @"";
    if ([GroupObject findByGroupid:mainG.groupid]==nil) {
        [GroupObject addOneGroup:mainG];
    } 
    NSArray* array = [dic objectForKey:@"msgs"];
    if (one.arrayChat == nil) {
        one.arrayChat = [NSMutableArray new];
    }
    one.subGroupid = [[dic objectForKey:@"id"]intValue];
    one.subGroupName = [dic objectForKey:@"name"];
    one.subGroupHead = [dic objectForKey:@"pic"];
    if ([[dic objectForKey:@"pic"] isKindOfClass:[NSNull class]]) {
        one.subGroupHead = @"";
    }
    int newCount = 0;
    if ([array isKindOfClass:[NSArray class]]) {
        for (NSDictionary* dic1 in array) {            
            ChatObject* oneChat = [ChatObject getOneChat:dic1];
            oneChat.chatStatus = eChatObjectStatus_Success;
            if (oneChat!=nil ) {
                [one.arrayChat addObject:oneChat];
                if (oneChat.userid != [[DataManager sharedManager] getUser].userid) {
                    newCount++;
                }else if (oneChat.userid == [[DataManager sharedManager]getUser].userid) {
                    continue ;
                }
                [ChatObject addOneChat:oneChat];
            }
        }
    }
    one.newMsgCount = newCount;
    ChatObject* c = [one.arrayChat objectAtIndex:one.arrayChat.count-1];;
//    for (int i=one.arrayChat.count-1; i>=0; i--) {
//        ChatObject* _c = [one.arrayChat objectAtIndex:i];
//        if (_c.userid != [[DataManager sharedManager]getUser].userid) {
//            c = _c;
//            break;
//        }
//    }
    one.lastTime = [NSString stringWithFormat:@"%@.%d",c.strTime,c.millisecond];
    //one.lastMilli = c.millisecond;
    if (c.type == eMessageType_Text) {
        one.lastContent = c.content;
    } else if (c.type == eMessageType_Image) {
        one.lastContent = @"图片";
    } else if (c.type == eMessageType_Voice) {
        one.lastContent = @"语音";
    }
    one.lastName = c.userName;
    GroupObject* g = [[GroupObject alloc]init];
    g.groupid = one.subGroupid;
    g.parentid = one.groupid;
    g.groupName = one.subGroupName;
    g.groupHead = one.subGroupHead;
    g.memberCount = one.numOfMember;
    g.remark = @"";
    if ([GroupObject findByGroupid:g.groupid]==nil) {
        [GroupObject addOneGroup:g];
    } else {
        [GroupObject updateGroup:g];
    }
    return one;
}

#pragma mark 数据库的操作
static sqlite3 *dbmain = nil;

+(sqlite3 *)openDB {
    if(!dbmain) {
        //目标路径
        NSString *docPath = [[YXResourceManager sharedManager] getHistoryDicrectionry];
        //原始路径
        NSString *filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/RecentContacts_%d.sqlite",[[DataManager sharedManager]getUser].userid]];
        if (sqlite3_open([filePath UTF8String], &dbmain) != SQLITE_OK) {
            sqlite3_close(dbmain);
            NSLog(@"数据库打开失败");
        }
    }
    
    NSString *sqlCreateTable = @"CREATE TABLE IF NOT EXISTS recentContacts ( ID INTEGER PRIMARY KEY AUTOINCREMENT, groupid  INTEGER, groupName TEXT, groupHead TEXT, memberCount INTEGER, lastName TEXT, lastContent TEXT, lastTime TEXT, newMsgCount INTEGER )";
    char *err;
    if (sqlite3_exec(dbmain, [sqlCreateTable UTF8String], NULL, NULL, &err) != SQLITE_OK) {
        sqlite3_close(dbmain);
        NSLog(@"添加最近联系人的表失败!");
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

//找出所有的
+(NSMutableArray *)findAll {
    sqlite3 *db = [self openDB];
    sqlite3_stmt *stmt = nil;//创建一个声明对象
    int result = sqlite3_prepare_v2(db, "select * from recentContacts order by lastTime desc", -1, &stmt, nil);
    NSMutableArray *array = nil;
    if (result == SQLITE_OK) {
        array = [[NSMutableArray alloc]init];
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            MsgObject* one = [[MsgObject alloc]init];
            one.subGroupid = sqlite3_column_int(stmt, 1);
            one.subGroupName = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)];
            one.subGroupHead = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3)];
            one.numOfMember = sqlite3_column_int(stmt, 4);
            one.lastName = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)];
            
            one.lastContent = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 6)];
            one.lastTime = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 7)];
            one.newMsgCount = sqlite3_column_int(stmt, 8);
            [array addObject:one];
        }
    } 
    sqlite3_finalize(stmt);
    return array;
}

//添加元素
+(void)addOneLast:(MsgObject *)one {
    sqlite3 *db = [self openDB];
    NSString *str = [NSString stringWithFormat:@"insert into recentContacts( 'groupid', 'groupName', 'groupHead', 'memberCount', 'lastName', 'lastContent', 'lastTime', 'newMsgCount') values(%d,'%@','%@',%d,'%@','%@','%@',%d)",one.subGroupid, one.subGroupName,one.subGroupHead,one.numOfMember,one.lastName,one.lastContent,one.lastTime,one.newMsgCount];
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(db, [str UTF8String],-1 ,&stmt , nil);
    if (result == SQLITE_OK) {
        sqlite3_step(stmt);
    } else {
        NSLog(@"添加一条最后联系人消息失败!%@",str);
    }
    sqlite3_finalize(stmt);
}

//根据ID删除信息
+(void)deleteByID:(int)groupid {
    NSString *str = [NSString stringWithFormat:@"delete from recentContacts where groupid = %d",groupid];
    sqlite3 *db = [self openDB];
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    if (result == SQLITE_OK) {
        sqlite3_step(stmt);
    }
    sqlite3_finalize(stmt);
}

+(MsgObject *)findByID:(int)groupid {
    sqlite3 *db = [self openDB];
    sqlite3_stmt *stmt = nil;
    MsgObject* one = nil;
    NSString *str = [NSString stringWithFormat:@"select * from recentContacts where groupid = %d",groupid];
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    if (result == SQLITE_OK) {
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            one = [[MsgObject alloc]init];
            one.subGroupid = sqlite3_column_int(stmt, 1);
            one.subGroupName = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)];
            one.subGroupHead = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3)];
            one.numOfMember = sqlite3_column_int(stmt, 4);
            one.lastName = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)];
            one.lastContent = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 6)];
            one.lastTime = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 7)];
            one.newMsgCount = sqlite3_column_int(stmt, 8);
            break;
        }
    }
    sqlite3_finalize(stmt);
    return one;
}

//更新最近联系人的记录
+(void)updateByID:(MsgObject *)one {
    NSString *str = [NSString stringWithFormat:@"update recentContacts set groupName = '%@', groupHead = '%@', memberCount = %d, lastName = '%@', lastContent = '%@', lastTime = '%@', newMsgCount = %d where groupid = %d ", one.subGroupName, one.subGroupHead, one.numOfMember, one.lastName, one.lastContent, one.lastTime, one.newMsgCount, one.subGroupid];
    sqlite3 *db = [self openDB];
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    if (result == SQLITE_OK) {
        sqlite3_step(stmt);
    }
    sqlite3_finalize(stmt);
}

+(void)updateCount:(int)groupid withNewCount:(int)newCount {
    NSString *str = [NSString stringWithFormat:@"update recentContacts set newMsgCount = %d where groupid = %d ", newCount, groupid];
    sqlite3 *db = [self openDB];
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    if (result == SQLITE_OK) {
        sqlite3_step(stmt);
    }
    sqlite3_finalize(stmt);
}

+(int)findCountByID:(int)groupid {
    sqlite3 *db = [self openDB];
    sqlite3_stmt *stmt = nil;
    NSString *str = [NSString stringWithFormat:@"select newMsgCount from recentContacts where groupid = %d",groupid];
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    int count = 0;
    if (result == SQLITE_OK) {
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            count = sqlite3_column_int(stmt, 0);
            break;
        }
    }
    sqlite3_finalize(stmt);
    return count;
}

+(void)sortMsg {
    sqlite3 *db = [self openDB];
    NSString *str = [NSString stringWithFormat:@"select * from recentContacts order by lastTime desc"];
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(db, [str UTF8String],-1 ,&stmt , nil);
    if (result == SQLITE_OK) {
        sqlite3_step(stmt);
    } else {
        NSLog(@"数据库排序消息记录失败!");
    }
    sqlite3_finalize(stmt);
}

@end
