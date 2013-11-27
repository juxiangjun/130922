package com.dyt.lpclub.activity.domain.db;

public class UserTable {
	public static final String CONST_TALBENAME 		= 	"USER";
	public static final String CONST_ID 			= 	"_ID";
	public static final String CONST_ACCOUNT 		= 	"ACCOUNT";
	public static final String CONST_STATE 			= 	"STATE";
	public static final String CONST_NAME 			= 	"NAME";
	public static final String CONST_PASSWORD 		= 	"PASSWORD";
	public static final String CONST_DEVICETYPE 	= 	"DEVICETYPE";
	public static final String CONST_DEVICEID 		= 	"DEVICEID";
	public static final String CONST_PIC 			= 	"PIC";
	public static final String CONST_SEX 			= 	"SEX";
	public static final String CONST_POS 			= 	"POS";
	public static final String CONST_AREA1 			= 	"AREA1";
	public static final String CONST_AREA2 			= 	"AREA2";
	public static final String CONST_SIGN 			= 	"SIGN";
	public static final String CONST_JOB1 			= 	"JOB1";
	public static final String CONST_JOB2 			= 	"JOB2";
	public static final String CONST_KEY_USER 		= 	"KEY_USER_ID";
	public static final String CONST_THUMB 			= 	"THUMB";

	public static final String CONST_SELECT 		= 	"SELECT * FROM " + CONST_TALBENAME + " WHERE 1 = 1 ";

	public static final String CONST_INSERT 		= 	"INSERT INTO [" + CONST_TALBENAME + "] (" + 
														CONST_ID + ", " + 
														CONST_ACCOUNT + ", " + 
														CONST_STATE + ","	+ 
														CONST_NAME + ", " + 
														CONST_PASSWORD + ", " + 
														CONST_DEVICETYPE + ", " + 
														CONST_DEVICEID + ", " + 
														CONST_PIC +	"," + 
														CONST_SEX + ","+ 
														CONST_POS + ","+ 
														CONST_AREA1 + ","+ 
														CONST_AREA2 + ","+ 
														CONST_SIGN + ","+ 
														CONST_JOB1 + ","+ 
														CONST_JOB2 + ","+ 
														CONST_KEY_USER + ","+ 
														CONST_THUMB + 
														") " +
														"VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
	
	public static final String CREATE_TABLE 		= 	"CREATE TABLE IF NOT EXISTS [" + CONST_TALBENAME + "] (" + 
														"[" + CONST_ID + "] INTEGER," + 
														"[" + CONST_ACCOUNT+ "] VARCHAR," + 
														"[" + CONST_STATE + "] INTEGER," + 
														"[" + CONST_PASSWORD + "] VARCHAR," + 
														"[" + CONST_NAME + "] VARCHAR," + 
														"[" + CONST_DEVICETYPE + "] VARCHAR," + 
														"[" + CONST_DEVICEID + "]VARCHAR," + 
														"[" + CONST_PIC + "]VARCHAR," + 
														"[" + CONST_SEX + "]INTEGER," + 
														"[" + CONST_POS + "]VARCHAR," + 
														"[" + CONST_AREA1 + "]VARCHAR," + 
														"[" + CONST_AREA2 + "]VARCHAR," + 
														"[" + CONST_SIGN + "]VARCHAR," + 
														"[" + CONST_JOB1 + "]VARCHAR," + 
														"[" + CONST_JOB2 + "]VARCHAR," + 
														"[" + CONST_KEY_USER + "] INTEGER," +
														"[" + CONST_THUMB + "] VARCHAR" + ");";
}
