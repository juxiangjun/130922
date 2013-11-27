package com.dyt.lpclub.activity.domain.db;

public class GroupTable {
	public static final String CONST_TALBENAME = "LPGROUP";
	public static final String CONST_ID = "_ID";
	public static final String CONST_NAME = "NAME";
	public static final String CONST_STATE = "STATE";
	public static final String CONST_REMARK = "REMARK";
	public static final String CONST_PIC = "PIC";
	public static final String CONST_NEWS = "NEWS";
	public static final String CONST_TYPE = "TYPE";
	public static final String CONST_RESID = "RESID";
	public static final String CONST_PARENT = "PARENT";
	public static final String CONST_MEMBERCOUNT = "MEMBERCOUNT";
	public static final String CONST_USERID = "USERID";
	public static final String CONST_SPELL = "SPELL";

	public static final String CREATE_TABLE = "CREATE TABLE IF NOT EXISTS [" + CONST_TALBENAME + "] (" 
												+ "[" + CONST_ID + "] VARCHAR," 
												+ "[" + CONST_NAME+ "] VARCHAR," 
												+ "[" + CONST_STATE + "] VARCHAR," 
												+ "[" + CONST_USERID + "] VARCHAR," 
												+ "[" + CONST_REMARK + "] VARCHAR," 
												+ "[" + CONST_PIC + "] VARCHAR," 
												+ "[" + CONST_NEWS + "] VARCHAR," 
												+ "[" + CONST_TYPE + "] VARCHAR," 
												+ "[" + CONST_RESID + "] VARCHAR," 
												+ "[" + CONST_PARENT + "] VARCHAR," 
												+ "[" + CONST_MEMBERCOUNT + "] VARCHAR," 
												+ "[" + CONST_SPELL + "] VARCHAR" 
												+ ");";

	public static final String CONST_SELECT = "SELECT * FROM [" + CONST_TALBENAME + "] WHERE 1 = 1 ";

	public static final String CONST_INSERT = "INSERT INTO [" + CONST_TALBENAME + "] (" 
												+ CONST_ID + ", " 
												+ CONST_NAME + ", " 
												+ CONST_STATE + ","
												+ CONST_USERID + ", " 
												+ CONST_REMARK + ", " 
												+ CONST_PIC + ", " 
												+ CONST_NEWS + ", " 
												+ CONST_TYPE + "," 
												+ CONST_RESID + "," 
												+ CONST_PARENT + ","
												+ CONST_MEMBERCOUNT + "," 
												+ CONST_SPELL + 
												") VALUES(?,?,?,?,?,?,?,?,?,?,?,?)";
}
