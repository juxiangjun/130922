//
//  MyConstants.m
//  ims
//
//  Created by Tony Ju on 10/18/13.
//  Copyright (c) 2013 Tony Ju. All rights reserved.
//

#import "MyConstants.h"

@implementation MyConstants

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark  --------------message type--------------
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/**未知类型*/
const int MSG_TYPE_UNKNOWN = 0x0000;
/**文本*/
const int MSG_TYPE_TEXT = 0x1000;
/**表情*/
const int MSG_TYPE_EMOTICON = 0x2000;
/**语音*/
const int MSG_TYPE_VOICE = 0x3000;
/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark  --------------error type--------------
/////////////////////////////////////////////////////////////////////////////////////////////////////////
/**未知错误*/
const int ERROR_UNKNOWN = 0x0000;
/**成功*/
const int ERROR_SUCCESS = 0x0001;
/**用户不在线*/
const int ERROR_USER_NOT_ONLINE = 0x0002;
/**当前连接不可用*/
const int ERROR_NOT_CONNECTED = 0x0003;

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark  --------------message status--------------
/////////////////////////////////////////////////////////////////////////////////////////////////////////

const int MSG_STATUS_UNKNOWN = 0x0000;
/**发送中*/
const int MSG_STATUS_SENDING = 0x0001;
/**已发送*/
const int MSG_STATUS_DELIVERED = 0x0002;
/**已读*/
const int MSG_STATUS_READ = 0x0003;
const int MSG_STATUS_FAILED = 0x0004;


/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark  --------------message direction--------------
/////////////////////////////////////////////////////////////////////////////////////////////////////////

const int MSG_DIRECTION_UNKNOWN =  0x0000;
const int MSG_DIRECTION_CLIENT_TO_SERVER = 0x0001;
const int MSG_DIRECTION_SERVER_TO_CLIENT = 0x0002;


/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark  --------------command lines--------------
/////////////////////////////////////////////////////////////////////////////////////////////////////////

const int COMMAND_UNKNOWN = 0x0000;

/**创建连接*/
const int COMMAND_CONNECT = 0x0001;
/**断开连接*/
const int COMMAND_DISCONNECT = 0x0002;

/**.发送点对点消息*/
const int COMMAND_SEND_P2P_MESSAGE = 0x1001;
const int COMMAND_SEND_P2P_MESSAGE_RESPONSE = 0x1002;
const int COMMAND_ON_RECEIVED_P2P_MESSAGE = 0x1003;

/**群组消息*/
const int COMMAND_SEND_P2G_MESSAGE = 0x1004;
const int COMMAND_SEND_P2G_MESSAGE_RESPONSE = 0x1005;
const int COMMAND_ON_RECEIVED_GROUP_MESSAGE = 0x1006;


/**获取群组列表*/
const int COMMAND_GET_GROUP_LIST = 0x2000;

/**邀请加入群组*/
const int COMMAND_SEND_GROUP_INVITATION = 0x2001;

/**接受群组邀请*/
const int COMMAND_ACCEPT_GROUP_INVITATION = 0x2002;

/**退出群组*/
const int COMMAND_QUIT_GROUP = 0x2003;

/**获取好友列表*/
const int COMMAND_GET_FIENDS_LIST = 0x3000;

/**加好友请求*/
const int COMMAND_SEND_ADD_FRIEND_REQUEST = 0x3001;

/**同总加好友请求*/
const int COMMAND_HANDLE_ADD_FRIEND_REQUEST = 0x3002;

/**删除好友*/
const int COMMAND_DELETE_FRIEND = 0x3003;

@end
