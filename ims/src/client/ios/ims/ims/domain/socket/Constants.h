//
//  Constants.h
//  ims
//
//  Created by Tony Ju on 10/17/13.
//  Copyright (c) 2013 Tony Ju. All rights reserved.
//


#import <Foundation/Foundation.h>


enum {
    
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark  --------------message type--------------
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    /**未知类型*/
    MSG_TYPE_UNKNOWN = 0x0000,
    /**文本*/
    MSG_TYPE_TEXT = 0x1000,
    /**表情*/
    MSG_TYPE_EMOTICON = 0x2000,
    /**语音*/
    MSG_TYPE_VOICE = 0x3000,
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark  --------------error type--------------
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    /**未知错误*/
    ERROR_UNKNOWN = 0x0000,
    /**成功*/
    ERROR_SUCCESS = 0x0001,
    /**用户不在线*/
    ERROR_USER_NOT_ONLINE = 0x0002,
    /**当前连接不可用*/
    ERROR_NOT_CONNECTED = 0x0003,
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark  --------------message status--------------
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    MSG_STATUS_UNKNOWN = 0x0000,
    /**发送中*/
    MSG_STATUS_SENDING = 0x0001,
    /**已发送*/
    MSG_STATUS_DELIVERED = 0x0002,
    /**已读*/
    MSG_STATUS_READ = 0x0003,
    MSG_STATUS_FAILED = 0x0004,
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark  --------------message direction--------------
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    MSG_DIRECTION_UNKNOWN =  0x0000,
    MSG_DIRECTION_CLIENT_TO_SERVER = 0x1000,
    MSG_DIRECTION_SERVER_TO_CLIENT = 0x2000,
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark  --------------command lines--------------
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    COMMAND_UNKNOWN = 0x0000,
    
    /**创建连接*/
    COMMAND_REGISTRATION = 0x0001,
    /**断开连接*/
    COMMAND_DISCONNECT = 0x0002,
    
    /**.发送点对点消息*/
    COMMAND_SEND_P2P_MESSAGE = 0x1001,
    COMMAND_SEND_P2P_MESSAGE_RESPONSE = 0x1002,
    COMMAND_ON_RECEIVED_P2P_MESSAGE = 0x1003,
    
    /**群组消息*/
    COMMAND_SEND_P2G_MESSAGE = 0x1004,
    COMMAND_SEND_P2G_MESSAGE_RESPONSE = 0x1005,
    COMMAND_ON_RECEIVED_GROUP_MESSAGE = 0x1006,
    
    
    /**获取群组列表*/
    COMMAND_GET_GROUP_LIST = 0x2000,
    
    /**邀请加入群组*/
    COMMAND_SEND_GROUP_INVITATION = 0x2001,
    
    /**接受群组邀请*/
    COMMAND_ACCEPT_GROUP_INVITATION = 0x2002,
    
    /**退出群组*/
    COMMAND_QUIT_GROUP = 0x2003,
    
    /**获取好友列表*/
    COMMAND_GET_FIENDS_LIST = 0x3000,
    
    /**加好友请求*/
    COMMAND_SEND_ADD_FRIEND_REQUEST = 0x3001,
    
    /**同总加好友请求*/
    COMMAND_HANDLE_ADD_FRIEND_REQUEST = 0x3002,
    
    /**删除好友*/
    COMMAND_DELETE_FRIEND = 0x3003
    
    
};


@interface Constants : NSObject



@end
