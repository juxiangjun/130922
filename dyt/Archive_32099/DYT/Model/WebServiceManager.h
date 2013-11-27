//
//  WebServiceManager.h
//  DYT
//
//  Created by zhaoliang.chen on 13-6-5.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WaitTooles.h"
#import "UserObject.h"
#import "AnnObject.h"
#import "MsgObject.h"
#import "GroupObject.h"
#import "GroupPicData.h"
#import "ActiveObject.h"
#import "ChatObject.h"

typedef void (^WebServiceCompletion)(id response);

@interface WebServiceManager : NSObject

+(WebServiceManager *)sharedManager;

#pragma mark 用户登陆
- (void)onLogin:(UserObject*)userObj
     completion:(WebServiceCompletion)completion;

#pragma mark 用户登出
- (void)onLogOut:(int)userid
      completion:(WebServiceCompletion)completion;

#pragma mark 获取公告列表
- (void)getNoticeList:(int)pageNum
            encodeStr:(NSString*)encodeStr
           completion:(WebServiceCompletion)completion;

- (void)getNoticeFirst:(NSString*)encodeStr
            completion:(WebServiceCompletion)completion;

#pragma mark 发送文字消息
- (void)sendText:(int)userid
         groupid:(int)groupid
         content:(NSString*)content
          msgTag:(NSString*)tag
      completion:(WebServiceCompletion)completion;

#pragma mark 发送图片信息
- (void)sendImg:(int)userid
        groupid:(int)groupid
        imgData:(NSData*)imgData
        imgtype:(NSString*)imgtype
         msgTag:(NSString*)tag
     completion:(WebServiceCompletion)completion;

#pragma mark 发送声音消息
- (void)sendVoice:(int)userid
          groupid:(int)groupid
        voiceData:(NSData*)voiceData
           msgTag:(NSString*)msgTag
       completion:(WebServiceCompletion)completion;

#pragma mark 获取消息列表
- (void)getMsgList:(int)userid
         encodeStr:(NSString*)encodeStr
              date:(NSString*)date
        completion:(WebServiceCompletion)completion;

#pragma mark 获取用户所参与的聊天主组
- (void)getGroupMain:(int)userid
           encodeStr:(NSString*)encodeStr
          completion:(WebServiceCompletion)completion;

#pragma mark 获取用户所参与的聊天子组
- (void)getGroupChild:(int)userid
          maingroupid:(int)maingroupid
           completion:(WebServiceCompletion)completion;

#pragma mark 获取群组中成员列表
- (void)getGroupMember:(int)groupid
             encodeStr:(NSString*)encodeStr
            completion:(WebServiceCompletion)completion;

#pragma mark 修改用户密码
- (void)updatePassword:(int)userid
           oldPassword:(NSString*)oldPassword
           newPassword:(NSString*)newPassword
             encodeStr:(NSString*)encodeStr
            completion:(WebServiceCompletion)completion;

#pragma mark 修改用户昵称
- (void)updateName:(int)userid
          withName:(NSString*)userName
         encodeStr:(NSString*)encodeStr
        completion:(WebServiceCompletion)completion;

#pragma mark 修改用户头像
- (void)updateHead:(int)userid
           withPic:(NSData*)picData
         encodeStr:(NSString*)encodeStr
        completion:(WebServiceCompletion)completion;

#pragma mark 修改用户性别
- (void)updateSex:(int)userid
          withSex:(int)sex
        encodeStr:(NSString*)encodeStr
       completion:(WebServiceCompletion)completion;

#pragma mark 获取个人信息
- (void)getUserInfo:(int)userid
          encodeStr:(NSString*)encodeStr
         completion:(WebServiceCompletion)completion;

#pragma mark 获取最后一个群组活动
- (void)getLastAction:(int)groupid
            encodeStr:(NSString*)encodeStr
           completion:(WebServiceCompletion)completion;

#pragma mark 发送群风采照片
- (void)sendGroupPic:(int)userid
             groupid:(int)groupid
             imgData:(NSData*)imgData
             imgtype:(NSString*)imgtype
           encodeStr:(NSString*)encodeStr
          completion:(WebServiceCompletion)completion;

#pragma mark 获取群风采照片
- (void)getGroupPic:(int)groupid
          startPage:(int)pageNum
          encodeStr:(NSString*)encodeStr
         completion:(WebServiceCompletion)completion;

#pragma mark 获取活动成员
- (void)getActMember:(int)eventid
           encodeStr:(NSString*)encodeStr
          completion:(WebServiceCompletion)completion;

#pragma mark 我要参与活动
- (void)joinAction:(int)eventid
              user:(int)userid
         encodeStr:(NSString*)encodeStr
        completion:(WebServiceCompletion)completion;

#pragma mark 退出活动
- (void)quitAction:(int)eventid
              user:(int)userid
         encodeStr:(NSString*)encodeStr
        completion:(WebServiceCompletion)completion;

#pragma mark 更改地区
- (void)updateArea:(int)userid
             area1:(NSString*)area1
             area2:(NSString*)area2
         encodeStr:(NSString*)encodeStr
        completion:(WebServiceCompletion)completion;

#pragma mark 更改职业
- (void)updateJob:(int)userid
             Job1:(NSString*)Job1
             Job2:(NSString*)Job2
        encodeStr:(NSString*)encodeStr
       completion:(WebServiceCompletion)completion;

#pragma mark 更改个性签名
- (void)updateMask:(int)userid
              mask:(NSString*)mask
         encodeStr:(NSString*)encodeStr
        completion:(WebServiceCompletion)completion;

#pragma mark 更改职位
- (void)updatePos:(int)userid
              pos:(NSString*)pos
            encodeStr:(NSString*)encodeStr
       completion:(WebServiceCompletion)completion;

@end
