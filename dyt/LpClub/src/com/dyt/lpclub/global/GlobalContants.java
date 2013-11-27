package com.dyt.lpclub.global;

import android.os.Environment;

/**
 * 类描述:
 * 
 * @Author:solotiger
 * @Date:2013-6-10
 */
public class GlobalContants {

	public final static int MSG_TYPE_WORD = 1;
	public final static int MSG_TYPE_IMG = 2;
	public final static int MSG_TYPE_VOICE = 3;

	public final static int SUCCESS = 100;
	public final static int FAIL = -100;
	public final static int NETWORK_FAIL = -101;
	public final static int NOT_HAVE_EVENT = -102;
	public final static int REFRESH = 101;
	public final static int NEWTALK = 102;
	public final static int INVALID = 103;
	public final static int ADDEVENTSUCC = 104;
	public final static int ADDEVENTFAIL = 105;
	public final static int QUITEVENTFAIL = 106;
	public final static int QUITEVENTSUCC = 107;

	public final static int HAVE_NEW_EVENT = 108;

	public final static String CONST_STR_BASE_URL = "http://121.199.53.25/dayetang/";
	public final static String HOST = CONST_STR_BASE_URL + "jsp/";
	public final static String MSG_ACTION = HOST + "msg/msg.action?";
	public final static String GROUP_ACTION = HOST + "group/group.action?";
	public final static String USER_ACTION = HOST + "user/user.action?";
	public final static String NEWS_ACTION = HOST + "news/news.action?";

	// 用户登录
	public final static String LOGIN_IN = HOST + "login.action?method=login";
	// 用户登出
	public final static String LOGIN_OUT = HOST + "login.action?method=logout";
	// 发送文字消息参数userid groupid msg
	public final static String SEND_TEXT_MSG = MSG_ACTION + "action=sendTextMsg";
	// 发送声音消息
	public final static String SEND_SOUND_MSG = MSG_ACTION + "action=sendSoundMsg";

	// 发送发送图片消息消息
	public final static String SEND_IMAGE_MSG = MSG_ACTION + "action=sendImgMsg";

	// 获取消息列表
	public final static String GET_MSG_LIST = MSG_ACTION + "action=getMsgList";

	// 获取用户所参与的聊天主组
	public final static String GET_MEMBER_GROUP = GROUP_ACTION + "action=getMemberGroup";
	// 获取用户所参与的聊天子组
	public final static String GET_MEMBER_SUB_GROUP = GROUP_ACTION + "action=getMemberSubGroup";
	// 获取群组中成员列表
	public final static String GET_GROUP_MEMBER_LIST = GROUP_ACTION + "action=getGroupMemberList";

	public final static String GET_GROUP_PIC = GROUP_ACTION + "action=getGroupPic";

	// 用户昵称修改
	public final static String UPDATE_MEMBER_NAME = USER_ACTION + "action=updateMemberName";
	public final static String UPDATE_MEMBER_AREA = USER_ACTION + "action=updateMemberArea";
	public final static String UPDATE_MEMBER_JOB = USER_ACTION + "action=updateMemberJob";
	public final static String UPDATE_MEMBER_POS = USER_ACTION + "action=updateMemberPos";
	public final static String UPDATE_MEMBER_SIGN = USER_ACTION + "action=updateMemberSign";
	// 用户头像修改action=updateMemberPic
	public final static String UPDATE_MEMBER_PIC = USER_ACTION + "action=updateMemberPic";
	// 用户密码修改
	public final static String UPDATE_PWD = USER_ACTION + "action=updatePwd";
	// 获取用户信息action=getMemberInfo
	public final static String GET_MEMBER_INFO = USER_ACTION + "action=getMemberInfo";
	// 修改用户性别action=updateSex
	public final static String UPDATE_SEX = USER_ACTION + "action=updateSex";

	// 获取公告列表
	public final static String QUERY_NEWS_LIST = NEWS_ACTION + "action=queryNewsList";

	/**
	 * 活动信息
	 */

	public final static String CONST_GROUP_EVENT_MSGS = GROUP_ACTION + "action=getLatestEvent";
	public final static String CONST_GROUP_EVENT_USERS = GROUP_ACTION + "action=getEventUsers";
	public final static String CONST_GROUP_EVENT_ADD = GROUP_ACTION + "action=addToEvent";
	public final static String CONST_GROUP_EVENT_QUIT = GROUP_ACTION + "action=removeFromEvent";

	/**
	 * 1:文字 2:图片 3:音频
	 */
	public static final int CONST_INT_MES_TYPE_TEXT = 1;
	public static final int CONST_INT_MES_TYPE_IMG = 2;
	public static final int CONST_INT_MES_TYPE_SOUND = 3;

	/**
	 * png
	 */
	public static final String IMAGE_PNG = "image/png";

	/** BASE_DIR */
	public final static String BASE_DIR = Environment.getExternalStorageDirectory() + "/LPclub/";
	
	/** 图标缓存目录 */
	public static final String CONST_DIR_CACHE = BASE_DIR + "Cache/";
	/** 图标缓存目录 */
	public static final String CONST_DIR_CACHE_IMG = BASE_DIR + "img/";
	/** 图标缩略图缓存目录 */
	public static final String CONST_DIR_THUMB_IMG = BASE_DIR + "thumb/";
	/** 视频图标缓存目录 */
	public static final String CONST_VIDEO_CACHE_IMG = BASE_DIR + "video/";
	
	// 获取用户所参与的聊天主组
	public final static String UPLOADGROUPPIC = GROUP_ACTION + "action=uploadGroupPic";

}
