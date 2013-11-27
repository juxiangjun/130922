//
//  UserObject.m
//  DYT
//
//  Created by zhaoliang.chen on 13-6-5.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "UserObject.h"
#import "DB.h"

@implementation UserObject

@synthesize userid;
@synthesize account;
@synthesize userName;
@synthesize password;
@synthesize sex;
@synthesize location;
@synthesize pos;
@synthesize hometown;
@synthesize explain;
@synthesize userHeadURL;
@synthesize headImage;
@synthesize encodeStr;
@synthesize userHeadLargeURL;

+(UserObject*)getUserObj:(NSDictionary*)dic {
    UserObject* one = [[UserObject alloc]init];
    one.userName = [dic objectForKey:@"name"];
    one.userid = [[dic objectForKey:@"id"]intValue];
    one.userHeadURL = [dic objectForKey:@"thumb"];
    if ([one.userHeadURL isKindOfClass:[NSNull class]] || [one.userHeadURL rangeOfString:@"null" options:NSCaseInsensitiveSearch].length>0) {
        one.userHeadURL = @"";
    }
    one.userHeadLargeURL = [dic objectForKey:@"pic"];
    if ([one.userHeadLargeURL isKindOfClass:[NSNull class]] || [one.userHeadLargeURL rangeOfString:@"null" options:NSCaseInsensitiveSearch].length>0) {
        one.userHeadLargeURL = @"";
    }
    if ([[dic objectForKey:@"sex"] isKindOfClass:[NSNumber class]]) {
        one.sex = [[dic objectForKey:@"sex"]intValue];
    } else {
        one.sex = 0;
    }
    one.hometown = [NSString stringWithFormat:@"%@%@",[dic objectForKey:@"area1"],[dic objectForKey:@"area2"]];
    if ([one.hometown isKindOfClass:[NSNull class]] || [one.hometown rangeOfString:@"null" options:NSCaseInsensitiveSearch].length>0) {
        one.hometown = @"";
    }
    one.location = [NSString stringWithFormat:@"%@",[dic objectForKey:@"job2"]];
    if ([one.location isKindOfClass:[NSNull class]] || [one.location rangeOfString:@"null" options:NSCaseInsensitiveSearch].length>0) {
        one.location = @"";
    }
    one.explain = [dic objectForKey:@"sign"];
    if ([one.explain isKindOfClass:[NSNull class]] || [one.explain rangeOfString:@"null" options:NSCaseInsensitiveSearch].length>0 || one.explain == nil) {
        one.explain = @"";
    }
    one.pos = [dic objectForKey:@"pos"];
    if ([one.pos isKindOfClass:[NSNull class]] || [one.pos rangeOfString:@"null" options:NSCaseInsensitiveSearch].length>0 || one.pos == nil) {
        one.pos = @"";
    }
    if ([UserObject findByID:one.userid]==nil) {
        [UserObject addName:one];
    } else {
        [UserObject updataName:one];
    }
    return one;
}

+(UserObject*)getUserObjByOne:(NSDictionary*)dic {
    UserObject* one = [[UserObject alloc]init];
    NSDictionary* d = [dic objectForKey:@"obj"];
    one.userName = [d objectForKey:@"name"];
    one.userid = [[d objectForKey:@"id"]intValue];
    one.userHeadURL = [d objectForKey:@"thumb"];
    if ([one.userHeadURL isKindOfClass:[NSNull class]] || [one.userHeadURL rangeOfString:@"null" options:NSCaseInsensitiveSearch].length>0) {
        one.userHeadURL = @"";
    }
    one.userHeadLargeURL = [d objectForKey:@"pic"];
    if ([one.userHeadLargeURL isKindOfClass:[NSNull class]] || [one.userHeadLargeURL rangeOfString:@"null" options:NSCaseInsensitiveSearch].length>0) {
        one.userHeadLargeURL = @"";
    }
    if ([[d objectForKey:@"sex"] isKindOfClass:[NSNumber class]]) {
        one.sex = [[d objectForKey:@"sex"]intValue];
    } else {
        one.sex = 0;
    }
    one.hometown = [NSString stringWithFormat:@"%@%@",[d objectForKey:@"area1"],[d objectForKey:@"area2"]];
    if ([one.hometown isKindOfClass:[NSNull class]] || [one.hometown rangeOfString:@"null" options:NSCaseInsensitiveSearch].length>0) {
        one.hometown = @"";
    }
    one.location = [NSString stringWithFormat:@"%@",[d objectForKey:@"job2"]];
    if ([one.location isKindOfClass:[NSNull class]] || [one.location rangeOfString:@"null" options:NSCaseInsensitiveSearch].length>0) {
        one.location = @"";
    }
    one.explain = [d objectForKey:@"sign"];
    if ([one.explain isKindOfClass:[NSNull class]] || [one.explain rangeOfString:@"null" options:NSCaseInsensitiveSearch].length>0 || one.explain == nil) {
        one.explain = @"";
    }
    one.pos = [d objectForKey:@"pos"];
    if ([one.pos isKindOfClass:[NSNull class]] || [one.pos rangeOfString:@"null" options:NSCaseInsensitiveSearch].length>0 || one.pos == nil) {
        one.pos = @"";
    }
    if ([UserObject findByID:one.userid]==nil) {
        [UserObject addName:one];
    } else {
        [UserObject updataName:one];
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
        NSString *filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/contact_%d.sqlite",[[DataManager sharedManager]getUser].userid]];
        if (sqlite3_open([filePath UTF8String], &dbmain) != SQLITE_OK) {
            sqlite3_close(dbmain);
            NSLog(@"数据库打开失败");
        }
    }
    
    NSString *sqlCreateTable = @"CREATE TABLE IF NOT EXISTS contact ( userid  INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, head TEXT, sex INTEGER, eara TEXT, job TEXT, pos TEXT, sign TEXT , headlarge TEXT)";
    char *err;
    if (sqlite3_exec(dbmain, [sqlCreateTable UTF8String], NULL, NULL, &err) != SQLITE_OK) {
        sqlite3_close(dbmain);
        NSLog(@"数据库创建用户表失败!");
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

-(id)initWithName:(NSString *)name head:(NSString *)head sex:(int)aSex ID:(int)ID {
    //[super init];
    if (self) {
        self.userName = name;
        self.userHeadURL = head;
        self.sex = aSex;
        self.userid = ID;
    }
    return self;
}

+(NSMutableArray *)findAll {
    sqlite3 *db = [self openDB];
    sqlite3_stmt *stmt = nil;//创建一个声明对象
    int result = sqlite3_prepare_v2(db, "select * from contact order by ID ", -1, &stmt, nil);
    NSMutableArray *persons = nil;
    if (result == SQLITE_OK) {
        persons = [[NSMutableArray alloc]init];
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            int ID = sqlite3_column_int(stmt, 0);
            const unsigned char *name = sqlite3_column_text(stmt, 1);
            const unsigned char *head = sqlite3_column_text(stmt, 2);
            int aSex = sqlite3_column_int(stmt, 3);
            UserObject *p = [[UserObject alloc]initWithName:[NSString stringWithUTF8String:(const char *)name] head:[NSString stringWithUTF8String:(const char *)head] sex:aSex ID:ID];
            [persons addObject:p];
        }
    } else {
        persons = [[NSMutableArray alloc]init];
    }
    sqlite3_finalize(stmt);
    return persons;
}

+(int)count {
    sqlite3 *db = [self openDB];
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(db, "select count(ID) from contact", -1, &stmt, nil);
    
    if (result == SQLITE_OK) {
        int count = 0;
        if (sqlite3_step(stmt)) {
            count = sqlite3_column_int(stmt, 0);
        }
        sqlite3_finalize(stmt);
        return count;
    } else {
        sqlite3_finalize(stmt);
        return 0;
    }
}

+(UserObject *)findByID:(int)ID {
    sqlite3 *db = [self openDB];
    sqlite3_stmt *stmt = nil;
    NSString *str = [NSString stringWithFormat:@"select * from contact where userid = %d",ID];
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    UserObject* one = nil;
    if (result == SQLITE_OK) {
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            one = [[UserObject alloc]init];
            one.userid = sqlite3_column_int(stmt, 0);
            one.userName = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)];
            one.userHeadURL = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)];
            one.sex = sqlite3_column_int(stmt, 3);
            one.hometown = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)];
            one.location = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)];
            one.pos = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 6)];
            one.explain = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 7)];
            one.userHeadLargeURL = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 8)];

            break;
        }
    }
    sqlite3_finalize(stmt);
    return one;
}

//添加元素
+(void)addName:(UserObject *)user {
    sqlite3 *db = [self openDB];
    NSString *str = [NSString stringWithFormat:@"insert into contact('userid','name','head','sex','eara', 'job','pos',  'sign' ,'headlarge') values(%d,'%@','%@',%d,'%@','%@','%@','%@','%@')",user.userid,user.userName,user.userHeadURL,user.sex,user.hometown,user.location,user.pos,user.explain,user.userHeadLargeURL];
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(db, [str UTF8String],-1 ,&stmt , nil);
    if (result == SQLITE_OK) {
        sqlite3_step(stmt);
    } else {
        NSLog(@"数据库操作添加一个用户元素失败!");
    }
    sqlite3_finalize(stmt);
}

//根据ID删除信息
+(void)deleteByID:(int)ID {
    NSString *str = [NSString stringWithFormat:@"delete from contact where userid = %d",ID];
    sqlite3 *db = [self openDB];
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    if (result == SQLITE_OK) {
        sqlite3_step(stmt);
    }
    sqlite3_finalize(stmt);
}

//更新
+(void)updataName:(UserObject *)user {
    NSString *str = [NSString stringWithFormat:@"update contact set name = '%@',head = '%@',sex = %d,eara = '%@', job = '%@', pos = '%@', sign = '%@' ,headlarge ='%@' where userid = %d",user.userName,user.userHeadURL,user.sex,user.hometown,user.location,user.pos,user.explain,user.userHeadLargeURL,user.userid];
    sqlite3 *db = [self openDB];
    sqlite3_stmt *stmt = nil;    
    int result = sqlite3_prepare_v2(db, [str UTF8String], -1, &stmt, nil);
    if (result == SQLITE_OK) {
        sqlite3_step(stmt);
    }
    sqlite3_finalize(stmt);
}


















@end
