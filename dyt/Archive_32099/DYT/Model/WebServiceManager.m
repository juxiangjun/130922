//
//  WebServiceManager.m
//  DYT
//
//  Created by zhaoliang.chen on 13-6-5.
//  Copyright (c) 2013年 zhaoliang.chen. All rights reserved.
//

#import "WebServiceManager.h"
#import "Global.h"
static WebServiceManager *_sharedManager = nil;

@implementation WebServiceManager

+(WebServiceManager *)sharedManager{
    @synchronized( [WebServiceManager class] ){
        if(!_sharedManager)
            _sharedManager = [[self alloc] init];
        return _sharedManager;
    }
    return nil;
}

+(id)alloc {
    @synchronized ([WebServiceManager class]){
        NSAssert(_sharedManager == nil,
                 @"Attempted to allocated a second instance");
        _sharedManager = [super alloc];
        return _sharedManager;
    }
    return nil;
}

-(id)init{
    self = [super init];
    if (self) {
    }
    
    return self;
}

//总的服务器
- (NSString *)serviceURL{
    return @"http://121.199.53.25/dayetang/jsp/";
}

#pragma mark 用户登陆
- (NSString*)onLogin {
    return @"login.action?method=login";
}

- (void)onLogin:(UserObject*)userObj
     completion:(WebServiceCompletion)completion {
    RFRequest *r = [RFRequest requestWithURL:[NSURL URLWithString:[self serviceURL]]
                                        type:RFRequestMethodPost
                      resourcePathComponents:[self onLogin],
                    nil];    
    
    [r addParam:userObj.account forKey:@"userName"];
    [r addParam:userObj.password forKey:@"password"];
    [r addParam:@"ios" forKey:@"devicetype"];
    [r addParam:[NSString stringWithFormat:@"%@",[[Global sharedInstance] getDeviceToken]] forKey:@"deviceid"];
    
    [RFService execRequest:r completion:^(RFResponse *response){
        NSDictionary *dic = [response.stringValue JSONValue];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }else{
            completion(dic);
        }
    }];
}

#pragma mark 用户登出
- (NSString*)onLogOut:(int)userid {
    return [NSString stringWithFormat:@"login.action?method=logout&userid=%d",userid];
}

- (void)onLogOut:(int)userid
      completion:(WebServiceCompletion)completion {
    RFRequest *r = [RFRequest requestWithURL:[NSURL URLWithString:[self serviceURL]]
                                        type:RFRequestMethodGet
                      resourcePathComponents:[self onLogOut:userid],
                    nil];
    
    [RFService execRequest:r completion:^(RFResponse *response){
        NSDictionary *dic = [response.stringValue JSONValue];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }else{
            completion(dic);
        }
    }];
}

#pragma mark 获取公告列表
- (NSString*)getNoticeList:(int)pageNum encodeStr:(NSString*)encodeStr {
    return [NSString stringWithFormat:@"news/news.action?action=queryNewsList"];
}

- (void)getNoticeList:(int)pageNum
            encodeStr:(NSString*)encodeStr
           completion:(WebServiceCompletion)completion {
    RFRequest *r = [RFRequest requestWithURL:[NSURL URLWithString:[self serviceURL]]
                                        type:RFRequestMethodPost
                      resourcePathComponents:[self getNoticeList:pageNum encodeStr:encodeStr],
                    nil];
    
    [r addParam:[NSString stringWithFormat:@"%d",pageNum] forKey:@"start"];
    [r addParam:[NSString stringWithFormat:@"%d",NOTICELIMIT] forKey:@"limit"];
    [r addParam:encodeStr forKey:@"encodeStr"];
    
    [RFService execRequest:r completion:^(RFResponse *response){
        NSDictionary *dic = [response.stringValue JSONValue];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }else{
            completion(dic);
        }
    }];
}

- (void)getNoticeFirst:(NSString*)encodeStr
            completion:(WebServiceCompletion)completion {
    RFRequest *r = [RFRequest requestWithURL:[NSURL URLWithString:[self serviceURL]]
                                        type:RFRequestMethodPost
                      resourcePathComponents:[self getNoticeList:0 encodeStr:encodeStr],
                    nil];
    
    [r addParam:[NSString stringWithFormat:@"%d",0] forKey:@"start"];
    [r addParam:[NSString stringWithFormat:@"%d",1] forKey:@"limit"];
    [r addParam:encodeStr forKey:@"encodeStr"];
    
    [RFService execRequest:r completion:^(RFResponse *response){
        NSDictionary *dic = [response.stringValue JSONValue];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }else{
            completion(dic);
        }
    }];
}

#pragma mark 发送文字消息
- (NSString*)sendText {
    return @"msg/msg.action?action=sendTextMsg";
}

- (void)sendText:(int)userid
         groupid:(int)groupid
         content:(NSString*)content
       msgTag:(NSString*)tag
      completion:(WebServiceCompletion)completion {
    RFRequest *r = [RFRequest requestWithURL:[NSURL URLWithString:[self serviceURL]]
                                        type:RFRequestMethodPost
                      resourcePathComponents:[self sendText],
                    nil];

    [r addParam:[NSString stringWithFormat:@"%d",userid] forKey:@"userid"];
    [r addParam:[NSString stringWithFormat:@"%d",groupid] forKey:@"groupid"];
    [r addParam:content forKey:@"msg"];
    [r addParam:tag forKey:@"param"];
    [r addParam:[[DataManager sharedManager]getUser].encodeStr forKey:@"encodeStr"];
    
    
    [RFService execRequest:r completion:^(RFResponse *response){
        NSDictionary *dic = [response.stringValue JSONValue];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }else{
            completion(dic);
        }
    }];
}

#pragma mark 发送图片信息
- (NSString*)sendImg {
    return @"msg/msg.action?action=sendImgMsg";
}

- (void)sendImg:(int)userid
        groupid:(int)groupid
        imgData:(NSData*)imgData
        imgtype:(NSString*)imgtype
      msgTag:(NSString*)tag
     completion:(WebServiceCompletion)completion {
    RFRequest *r = [RFRequest requestWithURL:[NSURL URLWithString:[self serviceURL]]
                                        type:RFRequestMethodPost
                      resourcePathComponents:[self sendImg],
                    nil];
    
    [r addParam:[NSString stringWithFormat:@"%d",userid] forKey:@"userid"];
    [r addParam:[NSString stringWithFormat:@"%d",groupid] forKey:@"groupid"];
    r.bodyContentType = RFRequestBodyTypeMultiPartFormData;
    [r addData:imgData withContentType:@"image/jpeg" forKey:@"image"];
    [r addParam:imgtype forKey:@"imgtype"];
    [r addParam:[[DataManager sharedManager]getUser].encodeStr forKey:@"encodeStr"];
    [r addParam:tag forKey:@"param"];
    
    [RFService execRequest:r completion:^(RFResponse *response){
        NSDictionary *dic = [response.stringValue JSONValue];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }else{
            completion(dic);
        }
    }];
}

#pragma mark 发送声音消息
- (NSString*)sendVoice {
    return @"msg/msg.action?action=sendSoundMsg";
}

- (void)sendVoice:(int)userid
          groupid:(int)groupid
        voiceData:(NSData*)voiceData
        msgTag:(NSString*)msgTag
       completion:(WebServiceCompletion)completion {
    RFRequest *r = [RFRequest requestWithURL:[NSURL URLWithString:[self serviceURL]]
                                        type:RFRequestMethodPost
                      resourcePathComponents:[self sendVoice],
                    nil];
    
    [r addParam:[NSString stringWithFormat:@"%d",userid] forKey:@"userid"];
    [r addParam:[NSString stringWithFormat:@"%d",groupid] forKey:@"groupid"];
    [r addParam:msgTag forKey:@"param"];
    r.bodyContentType = RFRequestBodyTypeMultiPartFormData;
    [r addData:voiceData withContentType:@"image/jpeg" forKey:@"sound"];
    [r addParam:[[DataManager sharedManager]getUser].encodeStr forKey:@"encodeStr"];
    
    [RFService execRequest:r completion:^(RFResponse *response){
        NSDictionary *dic = [response.stringValue JSONValue];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }else{
            completion(dic);
        }
    }];
}

#pragma mark 获取消息列表
- (NSString*)getMsgList:(int)userid
                   date:(NSString*)date {
    return [NSString stringWithFormat:@"msg/msg.action?action=getMsgList&userid=%d&querytime=%@",userid,date];
}


-(void)addUserIDParam:(RFRequest *)request userid:(NSString *)userid{
    [request addParam:userid forKey:@"userid"];
}

- (void)addActionName:(RFRequest *)request actionName:(NSString *)name{
    [request addParam:name forKey:@"action"];
}

- (void)getMsgList:(int)userid
         encodeStr:(NSString*)encodeStr
              date:(NSString*)date
        completion:(WebServiceCompletion)completion {
    
    if (date==nil) {
        return;
    }
    
    RFRequest *r = [RFRequest requestWithURL:[NSURL URLWithString:[self serviceURL]]
                                        type:RFRequestMethodPost
                      resourcePathComponents:@"msg/msg.action",
                    nil];
    
    [self addActionName:r actionName:@"getMsgList"];
    [self addUserIDParam:r userid:[NSString stringWithFormat:@"%d",userid]];
    [r addParam:date forKey:@"querytime"];
    [r addParam:encodeStr forKey:@"encodeStr"];
    [RFService execRequest:r completion:^(RFResponse *response){
        NSDictionary *dic = [response.stringValue JSONValue];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }else{
            completion(dic);
        }
    }];
}

#pragma mark 获取用户所参与的聊天主组
- (NSString*)getGroupMain:(int)userid encodeStr:(NSString*)encodeStr {
    return [NSString stringWithFormat:@"group/group.action?action=getMemberGroup"];
}

- (void)getGroupMain:(int)userid
           encodeStr:(NSString*)encodeStr
          completion:(WebServiceCompletion)completion {
    RFRequest *r = [RFRequest requestWithURL:[NSURL URLWithString:[self serviceURL]]
                                        type:RFRequestMethodPost
                      resourcePathComponents:[self getGroupMain:userid encodeStr:encodeStr],
                    nil];
    [r addParam:encodeStr forKey:@"encodeStr"];
    [r addParam:[NSString stringWithFormat:@"%d",userid] forKey:@"userid"];
    
    [RFService execRequest:r completion:^(RFResponse *response){
        NSDictionary *dic = [response.stringValue JSONValue];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }else{
            completion(dic);
        }
    }];
}

#pragma mark 获取用户所参与的聊天子组
- (NSString*)getGroupChild:(int)userid
                maingroupid:(int)maingroupid {
    return [NSString stringWithFormat:@"member/member.action?action=getMemberSubGroup"];
}

- (void)getGroupChild:(int)userid
          maingroupid:(int)maingroupid
           completion:(WebServiceCompletion)completion {
    RFRequest *r = [RFRequest requestWithURL:[NSURL URLWithString:[self serviceURL]]
                                        type:RFRequestMethodPost
                      resourcePathComponents:[self getGroupChild:userid maingroupid:maingroupid],
                    nil];
    
    [r addParam:[NSString stringWithFormat:@"%d",userid] forKey:@"userid"];
    [r addParam:[NSString stringWithFormat:@"%d",maingroupid] forKey:@"maingroupid"];
    
    [RFService execRequest:r completion:^(RFResponse *response){
        NSDictionary *dic = [response.stringValue JSONValue];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }else{
            completion(dic);
        }
    }];
}

#pragma mark 获取群组中成员列表
- (NSString*)getGroupMember:(int)groupid encodeStr:(NSString*)encodeStr {
    return [NSString stringWithFormat:@"group/group.action?action=getGroupMemberList"];
}

- (void)getGroupMember:(int)groupid
             encodeStr:(NSString*)encodeStr
            completion:(WebServiceCompletion)completion {
    RFRequest *r = [RFRequest requestWithURL:[NSURL URLWithString:[self serviceURL]]
                                        type:RFRequestMethodPost
                      resourcePathComponents:[self getGroupMember:groupid encodeStr:encodeStr],
                    nil];
    
    [r addParam:encodeStr forKey:@"encodeStr"];
    [r addParam:[NSString stringWithFormat:@"%d",groupid] forKey:@"groupid"];
    
    [RFService execRequest:r completion:^(RFResponse *response){
        NSDictionary *dic = [response.stringValue JSONValue];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }else{
            completion(dic);
        }
    }];
}

#pragma mark 修改用户密码
- (NSString*)updatePassword {
    return @"user/user.action?action=updatePwd";
}

- (void)updatePassword:(int)userid
           oldPassword:(NSString*)oldPassword
           newPassword:(NSString*)newPassword
             encodeStr:(NSString*)encodeStr
            completion:(WebServiceCompletion)completion {
    RFRequest *r = [RFRequest requestWithURL:[NSURL URLWithString:[self serviceURL]]
                                        type:RFRequestMethodPost
                      resourcePathComponents:[self updatePassword],
                    nil];
    
    [r addParam:[NSString stringWithFormat:@"%d",userid] forKey:@"userid"];
    [r addParam:oldPassword forKey:@"oldpassword"];
    [r addParam:newPassword forKey:@"password"];
    [r addParam:encodeStr forKey:@"encodeStr"];
    
    [RFService execRequest:r completion:^(RFResponse *response){
        NSDictionary *dic = [response.stringValue JSONValue];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }else{
            completion(dic);
        }
    }];
}

#pragma mark 修改用户昵称
- (NSString*)updateName {
    return @"user/user.action?action=updateMemberName";
}

- (void)updateName:(int)userid
          withName:(NSString*)userName
         encodeStr:(NSString*)encodeStr
        completion:(WebServiceCompletion)completion {
    RFRequest *r = [RFRequest requestWithURL:[NSURL URLWithString:[self serviceURL]]
                                        type:RFRequestMethodPost
                      resourcePathComponents:[self updateName],
                    nil];
    
    [r addParam:[NSString stringWithFormat:@"%d",userid] forKey:@"userid"];
    [r addParam:userName forKey:@"name"];
    [r addParam:encodeStr forKey:@"encodeStr"];
    
    [RFService execRequest:r completion:^(RFResponse *response){
        NSDictionary *dic = [response.stringValue JSONValue];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }else{
            completion(dic);
        }
    }];
}

#pragma mark 修改用户头像
- (NSString*)updateHead {
    return @"user/user.action?action=updateMemberPic";
}
- (void)updateHead:(int)userid
           withPic:(NSData*)picData
         encodeStr:(NSString*)encodeStr
        completion:(WebServiceCompletion)completion {
    RFRequest *r = [RFRequest requestWithURL:[NSURL URLWithString:[self serviceURL]]
                                        type:RFRequestMethodPost
                      resourcePathComponents:[self updateHead],
                    nil];
    
    [r addParam:[NSString stringWithFormat:@"%d",userid] forKey:@"userid"];
    r.bodyContentType = RFRequestBodyTypeMultiPartFormData;
    [r addData:picData withContentType:@"image/jpeg" forKey:@"pic"];
    [r addParam:encodeStr forKey:@"encodeStr"];
    
    [RFService execRequest:r completion:^(RFResponse *response){
        NSDictionary *dic = [response.stringValue JSONValue];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }else{
            completion(dic);
        }
    }];
}

#pragma mark 修改用户性别
- (NSString*)updateSex {
    return @"user/user.action?action=updateSex";
}

- (void)updateSex:(int)userid
          withSex:(int)sex
        encodeStr:(NSString*)encodeStr
       completion:(WebServiceCompletion)completion {
    RFRequest *r = [RFRequest requestWithURL:[NSURL URLWithString:[self serviceURL]]
                                        type:RFRequestMethodPost
                      resourcePathComponents:[self updateSex],
                    nil];
    
    [r addParam:[NSString stringWithFormat:@"%d",userid] forKey:@"userid"];
    [r addParam:[NSString stringWithFormat:@"%d",sex] forKey:@"sex"];
    [r addParam:encodeStr forKey:@"encodeStr"];
    
    [RFService execRequest:r completion:^(RFResponse *response){
        NSDictionary *dic = [response.stringValue JSONValue];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }else{
            completion(dic);
        }
    }];
}

#pragma mark 获取个人信息
- (NSString*)getUserInfo:(int)userid
               encodeStr:(NSString*)encodeStr{
    return [NSString stringWithFormat:@"user/user.action?action=getMemberInfo"];
}

- (void)getUserInfo:(int)userid
          encodeStr:(NSString*)encodeStr
         completion:(WebServiceCompletion)completion {
    RFRequest *r = [RFRequest requestWithURL:[NSURL URLWithString:[self serviceURL]]
                                        type:RFRequestMethodPost
                      resourcePathComponents:[self getUserInfo:userid encodeStr:encodeStr],
                    nil];
    [r addParam:[NSString stringWithFormat:@"%d",userid] forKey:@"userid"];
    [r addParam:encodeStr forKey:@"encodeStr"];
    
    [RFService execRequest:r completion:^(RFResponse *response){
        NSDictionary *dic = [response.stringValue JSONValue];
        
        if (![dic isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }else{
            completion(dic);
        }
    }];
}

#pragma mark 获取最后一个群组活动
- (NSString*)getLastAction:(int)groupid
                 encodeStr:(NSString*)encodeStr{
    return @"group/group.action?action=getLatestEvent";
}

- (void)getLastAction:(int)groupid
            encodeStr:(NSString*)encodeStr
           completion:(WebServiceCompletion)completion {
    RFRequest *r = [RFRequest requestWithURL:[NSURL URLWithString:[self serviceURL]]
                                        type:RFRequestMethodPost
                      resourcePathComponents:[self getLastAction:groupid encodeStr:encodeStr],
                    nil];
    
    [r addParam:encodeStr forKey:@"encodeStr"];
    [r addParam:[NSString stringWithFormat:@"%d",groupid] forKey:@"groupid"];
    
    [RFService execRequest:r completion:^(RFResponse *response){
        NSDictionary *dic = [response.stringValue JSONValue];
        NSLog(@"%@",dic);
        if (![dic isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }else{
            completion(dic);
        }
    }];
}

#pragma mark 发送群风采照片
- (NSString*)sendGroupPic {
    return @"group/group.action?action=uploadGroupPic";
}

- (void)sendGroupPic:(int)userid
             groupid:(int)groupid
             imgData:(NSData*)imgData
             imgtype:(NSString*)imgtype
           encodeStr:(NSString*)encodeStr
          completion:(WebServiceCompletion)completion {
    RFRequest *r = [RFRequest requestWithURL:[NSURL URLWithString:[self serviceURL]]
                                        type:RFRequestMethodPost
                      resourcePathComponents:[self sendGroupPic],
                    nil];
    
    [r addParam:[NSString stringWithFormat:@"%d",userid] forKey:@"userid"];
    [r addParam:[NSString stringWithFormat:@"%d",groupid] forKey:@"groupid"];
    r.bodyContentType = RFRequestBodyTypeMultiPartFormData;
    [r addData:imgData withContentType:@"image/jpeg" forKey:@"pic"];
    [r addParam:imgtype forKey:@"imgType"];
    [r addParam:encodeStr forKey:@"encodeStr"];
    
    [RFService execRequest:r completion:^(RFResponse *response){
        NSDictionary *dic = [response.stringValue JSONValue];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }else{
            completion(dic);
        }
    }];
}

#pragma mark 获取群风采照片
- (NSString*)getGroupPic:(int)groupid
          startPage:(int)pageNum
          encodeStr:(NSString*)encodeStr {
    return [NSString stringWithFormat:@"group/group.action?action=getGroupPic"];
}

- (void)getGroupPic:(int)groupid
          startPage:(int)pageNum
          encodeStr:(NSString*)encodeStr
         completion:(WebServiceCompletion)completion {
    RFRequest *r = [RFRequest requestWithURL:[NSURL URLWithString:[self serviceURL]]
                                        type:RFRequestMethodPost
                      resourcePathComponents:[self getGroupPic:groupid startPage:pageNum encodeStr:encodeStr],
                    nil];
    
    
    [r addParam:encodeStr forKey:@"encodeStr"];
    [r addParam:[NSString stringWithFormat:@"%d",ONEGROUPPAGE] forKey:@"limit"];
    [r addParam:[NSString stringWithFormat:@"%d",pageNum] forKey:@"start"];
    [r addParam:[NSString stringWithFormat:@"%d",groupid] forKey:@"groupid"];
    
    [RFService execRequest:r completion:^(RFResponse *response){
        NSDictionary *dic = [response.stringValue JSONValue];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }else{
            completion(dic);
        }
    }];
}

#pragma mark 获取活动成员
- (NSString*)getActMember:(int)eventid
                encodeStr:(NSString*)encodeStr {
    return [NSString stringWithFormat:@"group/group.action?action=getEventUsers"];
}

- (void)getActMember:(int)eventid
           encodeStr:(NSString*)encodeStr
          completion:(WebServiceCompletion)completion {
    RFRequest *r = [RFRequest requestWithURL:[NSURL URLWithString:[self serviceURL]]
                                        type:RFRequestMethodPost
                      resourcePathComponents:[self getActMember:eventid encodeStr:encodeStr],
                    nil];
    
    [r addParam:[NSString stringWithFormat:@"%d",eventid] forKey:@"eventid"];
    [r addParam:encodeStr forKey:@"encodeStr"];    
    
    [RFService execRequest:r completion:^(RFResponse *response){
        NSDictionary *dic = [response.stringValue JSONValue];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }else{
            completion(dic);
        }
    }];
}


#pragma mark 我要参与活动
- (NSString*)joinAction {
    return @"group/group.action?action=addToEvent";
}

- (void)joinAction:(int)eventid
              user:(int)userid
         encodeStr:(NSString*)encodeStr
        completion:(WebServiceCompletion)completion {
    RFRequest *r = [RFRequest requestWithURL:[NSURL URLWithString:[self serviceURL]]
                                        type:RFRequestMethodPost
                      resourcePathComponents:[self joinAction],
                    nil];
    
    [r addParam:[NSString stringWithFormat:@"%d",eventid] forKey:@"eventid"];
    [r addParam:[NSString stringWithFormat:@"%d",userid] forKey:@"userid"];
    [r addParam:encodeStr forKey:@"encodeStr"];
    
    [RFService execRequest:r completion:^(RFResponse *response){
        NSDictionary *dic = [response.stringValue JSONValue];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }else{
            completion(dic);
        }
    }];
}


#pragma mark 退出活动
- (NSString*)quitAction {
    return @"group/group.action?action=removeFromEvent";
}

- (void)quitAction:(int)eventid
              user:(int)userid
         encodeStr:(NSString*)encodeStr
        completion:(WebServiceCompletion)completion {
    RFRequest *r = [RFRequest requestWithURL:[NSURL URLWithString:[self serviceURL]]
                                        type:RFRequestMethodPost
                      resourcePathComponents:[self quitAction],
                    nil];
    
    [r addParam:[NSString stringWithFormat:@"%d",eventid] forKey:@"eventid"];
    [r addParam:[NSString stringWithFormat:@"%d",userid] forKey:@"userid"];
    [r addParam:encodeStr forKey:@"encodeStr"];
    
    [RFService execRequest:r completion:^(RFResponse *response){
        NSDictionary *dic = [response.stringValue JSONValue];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }else{
            completion(dic);
        }
    }];
}

#pragma mark 更改地区
- (NSString*)updateArea {
    return @"user/user.action?action=updateMemberArea";
}
- (void)updateArea:(int)userid
             area1:(NSString*)area1
             area2:(NSString*)area2
         encodeStr:(NSString*)encodeStr
        completion:(WebServiceCompletion)completion {
    RFRequest *r = [RFRequest requestWithURL:[NSURL URLWithString:[self serviceURL]]
                                        type:RFRequestMethodPost
                      resourcePathComponents:[self updateArea],
                    nil];
    
    [r addParam:[NSString stringWithFormat:@"%d",userid] forKey:@"userid"];
    [r addParam:area1 forKey:@"area1"];
    [r addParam:area2 forKey:@"area2"];
    [r addParam:encodeStr forKey:@"encodeStr"];
    
    [RFService execRequest:r completion:^(RFResponse *response){
        NSDictionary *dic = [response.stringValue JSONValue];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }else{
            completion(dic);
        }
    }];
}


//updateMemberJob
#pragma mark 更改职业
- (NSString*)updateJob {
    return @"user/user.action?action=updateMemberJob";
}
- (void)updateJob:(int)userid
             Job1:(NSString*)Job1
             Job2:(NSString*)Job2
        encodeStr:(NSString*)encodeStr
       completion:(WebServiceCompletion)completion {
    RFRequest *r = [RFRequest requestWithURL:[NSURL URLWithString:[self serviceURL]]
                                        type:RFRequestMethodPost
                      resourcePathComponents:[self updateJob],
                    nil];
    
    [r addParam:[NSString stringWithFormat:@"%d",userid] forKey:@"userid"];
    [r addParam:Job1 forKey:@"job1"];
    [r addParam:Job2 forKey:@"job2"];
    [r addParam:encodeStr forKey:@"encodeStr"];
    
    [RFService execRequest:r completion:^(RFResponse *response){
        NSDictionary *dic = [response.stringValue JSONValue];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }else{
            completion(dic);
        }
    }];
}


#pragma mark 更改职业
- (NSString*)updateMask {
    return @"user/user.action?action=updateMemberSign";
}
- (void)updateMask:(int)userid
              mask:(NSString*)mask
         encodeStr:(NSString*)encodeStr
        completion:(WebServiceCompletion)completion {
    RFRequest *r = [RFRequest requestWithURL:[NSURL URLWithString:[self serviceURL]]
                                        type:RFRequestMethodPost
                      resourcePathComponents:[self updateMask],
                    nil];
    
    [r addParam:[NSString stringWithFormat:@"%d",userid] forKey:@"userid"];
    [r addParam:mask forKey:@"sign"];
    [r addParam:encodeStr forKey:@"encodeStr"];
    
    [RFService execRequest:r completion:^(RFResponse *response){
        NSDictionary *dic = [response.stringValue JSONValue];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }else{
            completion(dic);
        }
    }];
}

#pragma mark 更改职位
- (NSString*)updatePos {
    return @"user/user.action?action=updateMemberPos";
}

- (void)updatePos:(int)userid
              pos:(NSString*)pos
        encodeStr:(NSString*)encodeStr
       completion:(WebServiceCompletion)completion {
    RFRequest *r = [RFRequest requestWithURL:[NSURL URLWithString:[self serviceURL]]
                                        type:RFRequestMethodPost
                      resourcePathComponents:[self updatePos],
                    nil];
    
    [r addParam:[NSString stringWithFormat:@"%d",userid] forKey:@"userid"];
    [r addParam:pos forKey:@"pos"];
    [r addParam:encodeStr forKey:@"encodeStr"];
    
    [RFService execRequest:r completion:^(RFResponse *response){
        NSDictionary *dic = [response.stringValue JSONValue];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }else{
            completion(dic);
        }
    }];
}


@end
