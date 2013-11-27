																																																							package com.dyt.lpclub.activity;

import java.util.HashMap;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.Paint;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.telephony.TelephonyManager;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.dyt.lpclub.R;
import com.dyt.lpclub.activity.domain.User;
import com.dyt.lpclub.activity.domain.db.Dao;
import com.dyt.lpclub.activity.domain.db.LpClubDB;
import com.dyt.lpclub.activity.domain.result.LoginResult;
import com.dyt.lpclub.activity.domain.result.UserResult;
import com.dyt.lpclub.global.ConfigSharePref;
import com.dyt.lpclub.global.Global;
import com.dyt.lpclub.global.GlobalContants;
import com.dyt.lpclub.util.UtilHttp;
import com.dyt.lpclub.util.UtilString;
import com.dyt.lpclub.util.UtilThread;
import com.dyt.lpclub.util.ViewUtil;
import com.google.gson.Gson;

/**
 * @ProjectName LpClub
 * @Author C.xt
 * @Version 1.0.0
 * @CreateDate： 2013-6-4 下午8:24:53
 * @JDK <JDK1.6> Description: 登陆Activity
 */
public class ActivityLogin extends Activity {

	private ProgressDialog dailog;
	private EditText et_username, et_pwd;
	private Context mContext;
	private TelephonyManager tm;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		ViewUtil.fullscreen(this);
		setContentView(R.layout.layout_login);
		
		String showHelp = ConfigSharePref.getInstance(this).getByArgkey("showHelp");
		if(UtilString.isEmpty(showHelp)){
			startActivity(new Intent(this, HelpActivity.class));
			ConfigSharePref.getInstance(this).setByArgkey("showHelp", "1");
		}
		
		mContext = this;
		et_username = (EditText) $(R.id.et_username);
//		et_username.setText("test");
		et_pwd = (EditText) $(R.id.et_pwd);
//		et_pwd.setText("123456");
		TextView rexian = (TextView) $(R.id.rexian);
		rexian.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				  //用intent启动拨打电话  
                Intent intent = new Intent(Intent.ACTION_CALL,Uri.parse("tel:4009975277"));  
                mContext.startActivity(intent);  
			}
		});
		
		rexian.getPaint().setFlags(Paint.UNDERLINE_TEXT_FLAG);
		rexian.getPaint().setAntiAlias(true);// 抗锯齿
		dailog = new ProgressDialog(this);
		dailog.setMessage($Str(R.string.login_loading));
		View login = $(R.id.tv_login);
		tm = (TelephonyManager) getSystemService(Context.TELEPHONY_SERVICE);
		login.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				dailog.show();
				UtilThread.executeMore(new Runnable() {
					@Override
					public void run() {
						String url = GlobalContants.LOGIN_IN;
						// userName password devicetype deviceid
						url += "&userName=" + et_username.getText().toString();
						url += "&password=" + et_pwd.getText().toString();
						url += "&devicetype=android";
						url += "&deviceid=" + tm.getDeviceId();
						UtilHttp http = new UtilHttp(url, "UTF-8");
						String result = http.getResponseAsStringGET(new HashMap<String, String>());
						if (result != null) {
							try {
								Gson gson = new Gson();
								LoginResult returnResult = gson.fromJson(result, LoginResult.class);
								if (returnResult.success) {
									int id = returnResult.obj.userid;
									url = GlobalContants.GET_MEMBER_INFO;
									url += "&userid=" + id;
									url += "&encodeStr=" + returnResult.obj.encodeStr;
									http = new UtilHttp(url, "UTF-8");
									result = http.getResponseAsStringGET(new HashMap<String, String>());
									UserResult userResult = gson.fromJson(result, UserResult.class);
									User user = userResult.obj;
									if (null == user) {
										mHander.sendEmptyMessage(GlobalContants.FAIL);
										return;
									}
									user.password = et_pwd.getText().toString();
									Global.getMe().setGlobalUser(user);
									Global.userid = user.id;
									LpClubDB db = new LpClubDB(mContext);
									try {
										Dao dao = new Dao();
										boolean islogined = dao.isUserLoginedBefore(db, String.valueOf(id));
										if (!islogined) {
											dao.insertUserLogined(db, String.valueOf(id));
										}
									} catch (Exception e) {
										e.printStackTrace();
									} finally {
										db.close();
									}

									Global.getMe().setEncodeStr(returnResult.obj.encodeStr);
									ConfigSharePref.getInstance(ActivityLogin.this).setByArgkey(ConfigSharePref.CONST_ENCODESTR, returnResult.obj.encodeStr);
									ConfigSharePref.getInstance(ActivityLogin.this).setByArgkey(ConfigSharePref.CONST_KEY_USER_ID, "" + id);
									ConfigSharePref.getInstance(ActivityLogin.this).setByArgkey(ConfigSharePref.CONST_KEY_USER_ACCOUNT, user.account);
									ConfigSharePref.getInstance(ActivityLogin.this).setByArgkey(ConfigSharePref.CONST_KEY_USER_DEVICEID, user.deviceid);
									ConfigSharePref.getInstance(ActivityLogin.this).setByArgkey(ConfigSharePref.CONST_KEY_USER_DEVICETYPE, user.devicetype);
									ConfigSharePref.getInstance(ActivityLogin.this).setByArgkey(ConfigSharePref.CONST_KEY_USER_NAME, user.name);

									ConfigSharePref.getInstance(ActivityLogin.this).setByArgkey(ConfigSharePref.CONST_KEY_USER_PASSWORD, user.password);
									ConfigSharePref.getInstance(ActivityLogin.this).setByArgkey(ConfigSharePref.CONST_KEY_USER_PIC, user.pic);
									ConfigSharePref.getInstance(ActivityLogin.this).setByArgkey(ConfigSharePref.CONST_KEY_USER_THUMB, user.thumb);
									ConfigSharePref.getInstance(ActivityLogin.this).setByArgkey(ConfigSharePref.CONST_KEY_USER_SEX, "" + user.sex);
									ConfigSharePref.getInstance(ActivityLogin.this).setByArgkey(ConfigSharePref.CONST_KEY_USER_STATE, "" + user.state);
									ConfigSharePref.getInstance(ActivityLogin.this).setByArgkey(ConfigSharePref.CONST_KEY_USER_AREA1, "" + user.area1);
									ConfigSharePref.getInstance(ActivityLogin.this).setByArgkey(ConfigSharePref.CONST_KEY_USER_AREA2, "" + user.area2);
									ConfigSharePref.getInstance(ActivityLogin.this).setByArgkey(ConfigSharePref.CONST_KEY_USER_JOB1, "" + user.job1);
									ConfigSharePref.getInstance(ActivityLogin.this).setByArgkey(ConfigSharePref.CONST_KEY_USER_JOB2, "" + user.job2);
									ConfigSharePref.getInstance(ActivityLogin.this).setByArgkey(ConfigSharePref.CONST_KEY_USER_POS, "" + user.pos);
									ConfigSharePref.getInstance(ActivityLogin.this).setByArgkey(ConfigSharePref.CONST_KEY_USER_SIGN, "" + user.sign);
									mHander.sendEmptyMessage(GlobalContants.SUCCESS);
								} else {
									mHander.sendEmptyMessage(GlobalContants.FAIL);
								}
							} catch (Exception e) {
								e.printStackTrace();
								mHander.sendEmptyMessage(GlobalContants.FAIL);
							}
						} else {
							mHander.sendEmptyMessage(GlobalContants.FAIL);
						}
					}
				});
			}
		});
	}

	private Handler mHander = new Handler() {
		public void handleMessage(Message msg) {
			if (dailog != null && dailog.isShowing()) {
				dailog.dismiss();
			}
			switch (msg.what) {
			case GlobalContants.SUCCESS:
				Global.isLogin = true;
				Intent intent = new Intent(mContext, ActivityMain.class);
				startActivity(intent);
				Toast.makeText(mContext, R.string.login_success, Toast.LENGTH_SHORT).show();
				finish();
				break;
			case GlobalContants.FAIL:
				Toast.makeText(mContext, R.string.login_fail, Toast.LENGTH_SHORT).show();
				break;
			case GlobalContants.INVALID:
				Toast.makeText(mContext, "你的账号已失效", Toast.LENGTH_SHORT).show();
				break;
			default:
				break;
			}
		};
	};

	private String $Str(int resId) {
		return getString(resId);
	}

	private View $(int resId) {
		return findViewById(resId);
	}
}
