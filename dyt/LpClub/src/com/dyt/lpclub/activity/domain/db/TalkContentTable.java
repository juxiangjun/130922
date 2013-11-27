package com.dyt.lpclub.activity.domain.db;

public class TalkContentTable {
	public static final String CONST_TALBENAME = "TALK_CONTENT";

	public static final String CONST_ID = "_ID";
	public static final String CONST_CONTENT = "CONTENT";
	public static final String CONST_GROUP_ID = "GROUP_ID";
	public static final String CONST_TYPE = "TYPE";
	public static final String CONST_TIME = "TIME";
	public static final String CONST_STATE = "STATE";
	public static final String CONST_THUMB = "THUMB";
	public static final String CONST_NEWMSGPOS = "NEWMSGPOS";
	public static final String CONST_SOUNDTIME = "SOUNDTIME";
	public static final String CONST_SOUNDLOCAL = "SOUNDLOCAL";
	public static final String CONST_USERID = "USERID";
	public static final String CONST_NEWMSG_ID = "NEWMSGID";
	public static final String CONST_KEY_USER = "KEY_USER_ID";

	public static final String CONST_SELECT_ALL = "SELECT * FROM " + CONST_TALBENAME + " WHERE 1=1 ";
	public static final String CONST_SELECT_COL = "SELECT %s  FROM " + CONST_TALBENAME + " WHERE 1=1 ";
	public static final String CONST_INSERT = "INSERT INTO " + CONST_TALBENAME + "(" + CONST_ID + ", " + CONST_CONTENT + ", " + CONST_USERID + ","
			+ CONST_GROUP_ID + ", " + CONST_TYPE + ", " + CONST_TIME + ", " + CONST_STATE + ", " + CONST_THUMB + "" + "," + CONST_NEWMSGPOS + ","
			+ CONST_SOUNDTIME + "," + CONST_SOUNDLOCAL + "," + CONST_NEWMSG_ID + "," + CONST_KEY_USER + ") VALUES(?, ?, ?, ?, ?, ?, ?, ?,?,?,?,?,?)";
	public static final String CREATE_TABLE = "CREATE TABLE IF NOT EXISTS [" + CONST_TALBENAME + "] (" + "[" + CONST_ID + "] VARCHAR PRIMARY KEY," + "[" + CONST_CONTENT
			+ "] TEXT NOT NULL," + "[" + CONST_USERID + "] VARCHAR," + "[" + CONST_GROUP_ID + "] INTEGER ," + "[" + CONST_TYPE + "] CHAR(1)," + "[" + CONST_TIME
			+ "] VARCHAR," + "[" + CONST_STATE + "] VARCHAR," + "[" + CONST_THUMB + "] VARCHAR," + "[" + CONST_NEWMSGPOS + "] INTEGER," + "[" + CONST_SOUNDTIME
			+ "] VARCHAR," + "[" + CONST_NEWMSG_ID + "] INTEGER," + "[" + CONST_SOUNDLOCAL + "] CHAR(1)," + "[" + CONST_KEY_USER + "] INTEGER);";

	public static final String SELECT_BY_NEWMSG_ID = "SELECT * FROM [" + CONST_TALBENAME
			+ "] WHERE NEWMSGID = ? and KEY_USER_ID = ? ORDER BY TIME DESC LIMIT 1";

	public static final String DELETE_BY_NEWMSG_ID = "DELETE FROM [" + CONST_TALBENAME + "] WHERE NEWMSGID = ? and KEY_USER_ID = ?";

}
