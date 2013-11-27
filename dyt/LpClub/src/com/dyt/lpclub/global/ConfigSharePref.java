package com.dyt.lpclub.global;

import android.content.Context;
import android.content.SharedPreferences;

import com.dyt.lpclub.util.UtilString;


/**
 */
public class ConfigSharePref {
	

	private static ConfigSharePref config;
	
	private SharedPreferences sp;

	public static final String CONST_ENCODESTR = "encodeStr";
	public static final String CONST_SPFILE_NAME = "config";
	public static final String CONST_KEY_USER_ID = "userid";
	public static final String CONST_KEY_USER_ACCOUNT = "useraccount";
	public static final String CONST_KEY_USER_STATE = "userstate";
	public static final String CONST_KEY_USER_NAME = "username";
	public static final String CONST_KEY_USER_PASSWORD = "userpassword";
	public static final String CONST_KEY_USER_DEVICETYPE = "userdevicetype";
	public static final String CONST_KEY_USER_DEVICEID = "userdeviceid";
	public static final String CONST_KEY_USER_PIC = "userpic";
	public static final String CONST_KEY_USER_THUMB = "userthumb";
	public static final String CONST_KEY_USER_PICURI = "userpicuri";
	public static final String CONST_KEY_USER_SEX = "usersex";
	public static final String CONST_KEY_USER_AREA1 = "userarea1";
	public static final String CONST_KEY_USER_AREA2 = "userarea2";
	public static final String CONST_KEY_USER_JOB1 = "userjob1";
	public static final String CONST_KEY_USER_JOB2 = "userjob2";
	public static final String CONST_KEY_USER_POS = "userpos";
	public static final String CONST_KEY_USER_SIGN = "usersign";
	public static final String CONST_KEY_LONGOUT_TIME = "key_longout_time";
	
	public static final String CONST_KEY_LATESTEVENT_TIME = "KEY_LATESTEVENT_TIME";

	private ConfigSharePref(Context context) {
		sp = context.getSharedPreferences(CONST_SPFILE_NAME, Context.MODE_WORLD_READABLE);
	}
	
	/**
	 * 
		 * 
		* @Author 								C.xt
		* @Title: 								getInstance
		* @Description:							
		* @param context
		* @return								ConfigSharePref
		* @throws								
		* @date 								2013-6-16下午7:56:11
	 */
	public static ConfigSharePref getInstance(Context context) {
		if (config == null)
			config = new ConfigSharePref(context);
		return config;
	}
	

	public void setByArgkey(String key, String value) {
		if(UtilString.isEmpty(value)){
			value = "";
		}
		sp.edit().putString(key, value).commit();
	}

	public String getByArgkey(String key) {
		return sp.getString(key, "");
	}

}
