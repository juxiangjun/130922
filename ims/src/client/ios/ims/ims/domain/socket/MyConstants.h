//
//  MyConstants.h
//  ims
//
//  Created by Tony Ju on 10/18/13.
//  Copyright (c) 2013 Tony Ju. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyConstants : NSObject

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark  --------------message type--------------
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/**未知类型*/
extern const int MSG_TYPE_UNKNOWN;
/**文本*/
extern const int MSG_TYPE_TEXT;
/**表情*/
extern const int MSG_TYPE_EMOTICON;
/**语音*/
extern const int MSG_TYPE_VOICE;
/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark  --------------error type--------------
/////////////////////////////////////////////////////////////////////////////////////////////////////////
/**未知错误*/
extern const int ERROR_UNKNOWN;
/**成功*/
extern const int ERROR_SUCCESS;
/**用户不在线*/
extern const int ERROR_USER_NOT_ONLINE;
/**当前连接不可用*/
extern const int ERROR_NOT_CONNECTED;

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark  --------------message status--------------
/////////////////////////////////////////////////////////////////////////////////////////////////////////

extern const int MSG_STATUS_UNKNOWN;
/**发送中*/
extern const int MSG_STATUS_SENDING;
/**已发送*/
extern const int MSG_STATUS_DELIVERED;
/**已读*/
extern const int MSG_STATUS_READ;
extern const int MSG_STATUS_FAILED;


/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark  --------------message direction--------------
/////////////////////////////////////////////////////////////////////////////////////////////////////////

extern const int MSG_DIRECTION_UNKNOWN;
extern const int MSG_DIRECTION_CLIENT_TO_SERVER;
extern const int MSG_DIRECTION_SERVER_TO_CLIENT;


/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark  --------------command lines--------------
/////////////////////////////////////////////////////////////////////////////////////////////////////////

extern const int COMMAND_UNKNOWN;

/**创建连接*/
extern const int COMMAND_CONNECT;
/**断开连接*/
extern const int COMMAND_DISCONNECT;

/**.发送点对点消息*/
extern const int COMMAND_SEND_P2P_MESSAGE;
extern const int COMMAND_SEND_P2P_MESSAGE_RESPONSE;
extern const int COMMAND_ON_RECEIVED_P2P_MESSAGE;

/**群组消息*/
extern const int COMMAND_SEND_P2G_MESSAGE;
extern const int COMMAND_SEND_P2G_MESSAGE_RESPONSE;
extern const int COMMAND_ON_RECEIVED_GROUP_MESSAGE;


/**获取群组列表*/
extern const int COMMAND_GET_GROUP_LIST;

/**邀请加入群组*/
extern const int COMMAND_SEND_GROUP_INVITATION;

/**接受群组邀请*/
extern const int COMMAND_ACCEPT_GROUP_INVITATION;

/**退出群组*/
extern const int COMMAND_QUIT_GROUP;

/**获取好友列表*/
extern const int COMMAND_GET_FIENDS_LIST;

/**加好友请求*/
extern const int COMMAND_SEND_ADD_FRIEND_REQUEST;

/**同总加好友请求*/
extern const int COMMAND_HANDLE_ADD_FRIEND_REQUEST;

/**删除好友*/
extern const int COMMAND_DELETE_FRIEND;


@end
