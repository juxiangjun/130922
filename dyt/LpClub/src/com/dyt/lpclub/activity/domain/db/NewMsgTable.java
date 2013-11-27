package com.dyt.lpclub.activity.domain.db;

public class NewMsgTable {

	public static final String CONST_TALBENAME = "NEWMSG";
	public static final String CONST_ID = "_ID";
	public static final String CONST_NEW_MSG_ID = "new_msg_id";
	public static final String CONST_KEY_USER = "KEY_USER_ID";

	public static final String CREATE_NEWMSG_TABLE = "CREATE TABLE IF NOT EXISTS [" + CONST_TALBENAME + "] (" + "[" + CONST_ID
			+ "] INTEGER PRIMARY KEY autoincrement," + "[" + CONST_NEW_MSG_ID + "] INTEGER,[" + CONST_KEY_USER + "] INTEGER);";
	public static final String NEW_MSG_COUNT_SELECT = "select * FROM [" + CONST_TALBENAME + "] where new_msg_id = ? and KEY_USER_ID = ?";
	public static final String NEW_MSG_COUNT_SELECT_ALL = "select * FROM [" + CONST_TALBENAME + "] where KEY_USER_ID = ?";
	public static final String NEW_MSG_COUNT_INSERT = "INSERT INTO [" + CONST_TALBENAME + "] (" + CONST_NEW_MSG_ID + "," + CONST_KEY_USER + ") VALUES(?,?)";
	public static final String NEW_MSG_COUNT_DELETE = "delete from [" + CONST_TALBENAME + "] where new_msg_id=? and KEY_USER_ID = ?";
}
