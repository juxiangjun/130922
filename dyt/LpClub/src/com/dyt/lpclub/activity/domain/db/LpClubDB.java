package com.dyt.lpclub.activity.domain.db;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;

public class LpClubDB extends AbstractDataBase {

	private static final int VERSION = 1;
	private static final String DB_NAME = "lpclub.db";

	public static final String KEY_USER = "key_user_";
	public static final String CREATE_CONFIG_TABLE = "CREATE TABLE IF NOT EXISTS Config ('ID' varchar(20) PRIMARY KEY NOT NULL, 'value' varchar(10))";
	public static final String CONFIG_SELECT = "select value from Config where ID = ?";
	public static final String CONFIG_INSERT = "insert into Config values(?,?)";
	public static final String CONFIG_DELETE = "delete from Config where ID=?";

	public LpClubDB(Context c) {
		super(c, DB_NAME, VERSION);
	}

	@Override
	public void onDataBaseCreate(SQLiteDatabase db) {
		db.execSQL(CREATE_CONFIG_TABLE);
		db.execSQL(GroupTable.CREATE_TABLE);
		db.execSQL(TalkContentTable.CREATE_TABLE);
		db.execSQL(UserTable.CREATE_TABLE);
		db.execSQL(NewMsgTable.CREATE_NEWMSG_TABLE);
	}

	@Override
	public void onDataBaseUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {

	}

}
