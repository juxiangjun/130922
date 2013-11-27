//
//  GroupObject.m
//  DYT
//
//  Created by zhaoliang.chen on 13-6-7.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "GroupObject.h"

@implementation GroupObject

@synthesize groupid;
@synthesize groupName;
@synthesize remark;
@synthesize parentid;
@synthesize groupHead;
@synthesize subGroup;
@synthesize memberCount;
@synthesize arrGroupPic;

+(GroupObject*)getOneGroup:(NSDictionary*)dic {
    GroupObject* one = [[GroupObject alloc]init];
    one.groupid = [[dic objectForKey:@"id"]intValue];
    one.groupName = [dic objectForKey:@"name"];
    if ([[dic objectForKey:@"parent"] isKindOfClass:[NSNumber class]]) {
        one.parentid = [[dic objectForKey:@"parent"]intValue];
    } else {
        one.parentid = -1;
    }
    one.groupHead = [dic objectForKey:@"pic"];
    if ([one.groupHead isKindOfClass:[NSNull class]]) {
        one.groupHead = @"";
    }
    one.remark = [dic objectForKey:@"remark"];
    one.memberCount = [[dic objectForKey:@"memberCount"]intValue];
    NSArray* array = [dic objectForKey:@"subGroup"];
    if ([array isKindOfClass:[NSArray class]]) {
        one.subGroup = [NSMutableArray new];
        for (int i=0; i<array.count; i++) {
            NSDictionary* dic1 = [array objectAtIndex:i];
            GroupObject* g = [GroupObject getOneGroup:dic1];
            [one.subGroup addObject:g];           
            
            if ([GroupObject findByGroupid:g.groupid]==nil) {
                [GroupObject addOneGroup:g];
            } else {
                [GroupObject updateGroup:g];
            }
        }
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
        NSString *filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/groupList_%d.sqlite",[[DataManager sharedManager]getUser].userid]];
        if (sqlite3_open([filePath UTF8String], &dbmain) != SQLITE_OK) {
            sqlite3_close(dbmain);
            NSLog(@"数据库打开失败");
        }
    }
    
    NSString *sqlCreateTable = @"CREATE TABLE IF NOT EXISTS groupList ( groupid INTEGER PRIMARY KEY AUTOINCREMENT,parentid  INTEGER, groupName TEXT, remark TEXT, groupHead TEXT, memberCount INTEGER )";
    char *err;
    if (sqlite3_exec(dbmain, [sqlCreateTable UTF8String], NULL, NULL, &err) != SQLITE_OK) {
        sqlite3_close(dbmain);
        NSLog(@"数据库操作数据失败!");
    }
    
    sqlCreateTable = @"CREATE TABLE IF NOT EXISTS groupMember ( ID INTEGER PRIMARY KEY AUTOINCREMENT, userid INTEGER, groupid  INTEGER, name TEXT, pic TEXT )";
    if (sqlite3_exec(dbmain, [sqlCreateTable UTF8String], NULL, NULL, &err) != SQLITE_OK) {
        sqlite3_close(dbmain);
        NSLog(@"数据库操作数据失败!");
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

//根据groupid寻找组
+(GroupObject *)findByGroupid:(int)groupid {
    sqlite3 *db = [self openDB];
    sqlite3_stmt *stmt = nil;
    NSString *str = [NSString stringWithFormat:@"select * from groupList where groupid = %d",groupid];
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    GroupObject* one = nil;
    if (result == SQLITE_OK) {
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            one = [[GroupObject alloc]init];
            one.groupid = sqlite3_column_int(stmt, 0);
            one.parentid = sqlite3_column_int(stmt, 1);
            one.groupName = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)];
            one.remark = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3)];
            one.groupHead = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)];
            one.memberCount = sqlite3_column_int(stmt, 5);
            break;
        }
    }
    sqlite3_finalize(stmt);
    return one;
}

//寻找同一级的组
+(NSMutableArray *)findByParentid:(int)parentid {
    sqlite3 *db = [self openDB];
    sqlite3_stmt *stmt = nil;
    NSString *str = [NSString stringWithFormat:@"select * from groupList where parentid = %d",parentid];
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    NSMutableArray* array = [NSMutableArray new];
    if (result == SQLITE_OK) {
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            GroupObject* one = [[GroupObject alloc]init];
            one.groupid = sqlite3_column_int(stmt, 0);
            one.parentid = sqlite3_column_int(stmt, 1);
            one.groupName = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)];
            one.remark = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3)];
            
            NSString *res = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)];
            NSLog(@"test:%@,%@,%d",res,[res class],res.length);
            
            one.groupHead = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)];
            one.memberCount = sqlite3_column_int(stmt, 5);
            [array addObject:one];
        }
    }
    sqlite3_finalize(stmt);
    return array;
}

//添加元素
+(void)addOneGroup:(GroupObject *)one {
    sqlite3 *db = [self openDB];
    NSString *str = [NSString stringWithFormat:@"insert into groupList('groupid', 'parentid', 'groupName', 'remark', 'groupHead', 'memberCount') values(%d,%d,'%@','%@','%@',%d)",one.groupid, one.parentid,one.groupName,one.remark,one.groupHead,one.memberCount];
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(db, [str UTF8String],-1 ,&stmt , nil);
    if (result == SQLITE_OK) {
        sqlite3_step(stmt);
    } else {
        NSLog(@"数据库添加一个群组失败!");
    }
    sqlite3_finalize(stmt);
}

//更新群组
+(void)updateGroup:(GroupObject *)one {
    NSString *str = [NSString stringWithFormat:@"update groupList set parentid = %d, groupName = '%@',remark = '%@', groupHead = '%@', memberCount = %d  where groupid = %d",one.parentid,one.groupName,one.remark,one.groupHead,one.memberCount,one.groupid];
    sqlite3 *db = [self openDB];
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    if (result == SQLITE_OK) {
        sqlite3_step(stmt);
    }
    sqlite3_finalize(stmt);
}

//根据groupid删除信息
+(void)deleteByGroupid:(int)groupid {
    NSString *str = [NSString stringWithFormat:@"delete from groupList where groupid = %d",groupid];
    sqlite3 *db = [self openDB];
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    if (result == SQLITE_OK) {
        sqlite3_step(stmt);
    }
    sqlite3_finalize(stmt);
}

//根据groupid删除信息
+(void)deleteAllGroupid {
    NSString *str = @"delete from groupList";
    sqlite3 *db = [self openDB];
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    if (result == SQLITE_OK) {
        sqlite3_step(stmt);
    } else {
        NSLog(@"全部删除群组失败");
    }
    sqlite3_finalize(stmt);
}

//寻找同一组的成员
+(UserObject *)findMemberByGroupAndUserid:(int)groupid withUserid:(int)userid {
    sqlite3 *db = [self openDB];
    sqlite3_stmt *stmt = nil;
    NSString *str = [NSString stringWithFormat:@"select * from groupMember where groupid = %d AND userid = %d",groupid,userid];
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    UserObject* one = nil;
    if (result == SQLITE_OK) {
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            one = [[UserObject alloc]init];
            one.userid = sqlite3_column_int(stmt, 0);
            one.userName = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)];
            one.userHeadURL = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3)];
            break;
        }
    }
    sqlite3_finalize(stmt);
    return one;
}

//寻找同一组的成员
+(NSMutableArray *)findMemberByGroup:(int)groupid {
    sqlite3 *db = [self openDB];
    sqlite3_stmt *stmt = nil;
    NSString *str = [NSString stringWithFormat:@"select * from groupMember where groupid = %d",groupid];
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    NSMutableArray* array = [NSMutableArray new];
    if (result == SQLITE_OK) {
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            UserObject* one = [[UserObject alloc]init];
            one.userid = sqlite3_column_int(stmt, 1);
            one.userName = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3)];
            one.userHeadURL = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)];
            [array addObject:one];
        }
    }
    sqlite3_finalize(stmt);
    return array;
}

+(void)addOneMember:(UserObject*)user withGroupid:(int)groupid {
    sqlite3 *db = [self openDB];
    NSString *str = [NSString stringWithFormat:@"insert into groupMember('userid', 'groupid', 'name', 'pic') values(%d,%d,'%@','%@')",user.userid, groupid,user.userName,user.userHeadURL];
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(db, [str UTF8String],-1 ,&stmt , nil);
    if (result == SQLITE_OK) {
        sqlite3_step(stmt);
    } else {
        NSLog(@"数据库操作数据失败!");
    }
    sqlite3_finalize(stmt);
}

+(void)updateOneMember:(UserObject*)user withGroupid:(int)groupid {
    NSString *str = [NSString stringWithFormat:@"update groupMember set name = '%@',pic = '%@' where userid = %d AND groupid = %d",user.userName,user.userHeadURL,user.userid,groupid];
    sqlite3 *db = [self openDB];
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    if (result == SQLITE_OK) {
        sqlite3_step(stmt);
    }
    sqlite3_finalize(stmt);
}


@end
