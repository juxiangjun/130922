package com.eme.ims.codec;

public class MsgProtocol {

	public class Public {
		public final static String MINA_SESSION_KEY = "SESSION_KEY";
	}
	
	public class MsgType {
		/**未知类型*/
		public final static short UNKNOWN = 0x0000;
		/**文本消息*/
		public final static short TEXT = 0x1000;
		/**表情消息*/
		public final static short EMOTICON = 0x2000;
		/**语音留言*/
		public final static short VOICE = 0x3000;
		/**语音流*/
		public final static short AUDIO_STREAM = 0x4000;
	}
	
	public class Error {
		/**未知错误*/
		public final static short UNKNOWN = 0x0000;
		/**成功*/
		public final static short SUCCESS = 0x0001;
		/**用户不在线*/
		public final static short USER_NOT_ONLINE = 0x0002;
		/**未连接*/
		public final static short NOT_CONNECTED = 0x0003;
	}
	
	public class MsgDirection {
		/**未知方向*/
		public final static short UNKNOWN = 0x000;
		/**客户端至服务器*/
		public final static short CLIENT_TO_SERVER = 0x1000;
		/**服务器至客户端*/
		public final static short SERVER_TO_CLIENT = 0x2000;
	}
	
	/**
	 * 
	 * 消息状态
	 * @author tju
	 *
	 */
	public class MsgStatus {
		/**未知状态*/
		public final static short UNKNOWN = 0x000;
		/**发送中*/
		public final static short SENDING = 0x0001;
		/**已发送*/
		public final static short DELIVERED = 0x0002;
		/**已读*/
		public final static short READ = 0x0003;
		/**发送失败*/
		public final static short FAILED = 0x0004;
	}
	
	
	
	public class Command {
		
		/**未知行为*/
		public final static int UNKNOWN = 0x0000;
		
		/**建立连接*/
		public final static int REGISTRATION = 0x0001;
		/**断开连接*/
		public final static int DISCONNECT = 0x0002;
		
		/**
		 * 消息处理
		 * =====================================================================
		 */
		/**.发送点对点消息*/
		public final static int SEND_P2P_MESSAGE = 0x1001;
		public final static int SEND_P2P_MESSAGE_RESPONSE = 0x1002;
		public final static int ON_RECEIVED_P2P_MESSAGE = 0x1003;
		
		/**群组消息*/
		public final static int SEND_P2G_MESSAGE = 0x1004;
		public final static int SEND_P2G_MESSAGE_RESPONSE = 0x1005;
		public final static int ON_RECEIVED_GROUP_MESSAGE =  0x1006;
		
		/**
		 * 群组操作
		 * =====================================================================
		 */
		
		/**获取群组列表*/
		public final static int GET_GROUP_LIST = 0x2000;
		
		/**邀请加入群组*/
		public final static int SEND_GROUP_INVITATION = 0x2001;
		
		/**接受群组邀请, 需要更新群组列表...*/
		public final static int ACCEPT_GROUP_INVITATION = 0x2002;
		
		/**退出群组， 需更新群组列表*/
		public final static int QUIT_GROUP = 0x2003;
		
		/** 移除群组成员 */
		public final static int REMOVE_MEMBER_FROM_GROUP = 0x2004;
		
		/**删除群组, 创建人退出群组 */
		public final static int REMOVE_GROUP = 0x2005;
		
		/**
		 * 好友操作
		 * ===================================================================
		 */
		
		/**获取好友列表*/
		public final static int GET_FIENDS_LIST = 0x3000;
		
		/**加好友请求*/
		public final static int SEND_ADD_FRIEND_REQUEST = 0x3001;
		
		/**同意加好友请求*/
		public final static int HANDLE_ADD_FRIEND_REQUEST = 0x3002;
		
		/**删除好友*/
		public final static int DELETE_FRIEND = 0x3003;
		
	}
	
}
