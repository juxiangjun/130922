package com.dyt.lpclub.activity;

import android.app.Activity;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import android.view.Window;

import com.dyt.lpclub.R;
import com.dyt.lpclub.activity.domain.User;
import com.dyt.lpclub.global.ConfigSharePref;
import com.dyt.lpclub.global.Global;
import com.dyt.lpclub.util.UtilString;
import com.dyt.lpclub.util.UtilThread;

/**
 * @ProjectName LpClub
 * @Author C.xt
 * @Version 1.0.0
 * @CreateDate： 2013-6-4 下午8:15:59
 * @JDK <JDK1.6> Description: 欢迎Activity
 */
public class ActivityWelcome extends Activity {
	Handler mHandler = new Handler();
	/**
	 * 欢迎界面图片
	 */
	Drawable pWlcome;

	private boolean autoLogon = false;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.layout_welcome);
		
		View vWelcome = findViewById(R.id.id_welcome);
		vWelcome.setBackgroundResource(R.drawable.p_welcome);
		String userId = ConfigSharePref.getInstance(this).getByArgkey(ConfigSharePref.CONST_KEY_USER_ID);
		if (!UtilString.isEmpty(userId)) {
			autoLogon = true;

			User user = new User();

			user.id = Integer.parseInt(userId);
			user.account = ConfigSharePref.getInstance(this).getByArgkey(ConfigSharePref.CONST_KEY_USER_ACCOUNT);
			user.deviceid = ConfigSharePref.getInstance(this).getByArgkey(ConfigSharePref.CONST_KEY_USER_DEVICEID);
			user.devicetype = ConfigSharePref.getInstance(this).getByArgkey(ConfigSharePref.CONST_KEY_USER_DEVICETYPE);
			user.name = ConfigSharePref.getInstance(this).getByArgkey(ConfigSharePref.CONST_KEY_USER_NAME);

			user.password = ConfigSharePref.getInstance(this).getByArgkey(ConfigSharePref.CONST_KEY_USER_PASSWORD);
			user.pic = ConfigSharePref.getInstance(this).getByArgkey(ConfigSharePref.CONST_KEY_USER_PIC);
			user.thumb = ConfigSharePref.getInstance(this).getByArgkey(ConfigSharePref.CONST_KEY_USER_THUMB);
			String userSex = ConfigSharePref.getInstance(this).getByArgkey(ConfigSharePref.CONST_KEY_USER_SEX);
			String userState = ConfigSharePref.getInstance(this).getByArgkey(ConfigSharePref.CONST_KEY_USER_STATE);

			user.area1 = ConfigSharePref.getInstance(this).getByArgkey(ConfigSharePref.CONST_KEY_USER_AREA1);
			user.area2 = ConfigSharePref.getInstance(this).getByArgkey(ConfigSharePref.CONST_KEY_USER_AREA2);
			user.job1 = ConfigSharePref.getInstance(this).getByArgkey(ConfigSharePref.CONST_KEY_USER_JOB1);
			user.job2 = ConfigSharePref.getInstance(this).getByArgkey(ConfigSharePref.CONST_KEY_USER_JOB2);
			user.pos = ConfigSharePref.getInstance(this).getByArgkey(ConfigSharePref.CONST_KEY_USER_POS);
			user.sign = ConfigSharePref.getInstance(this).getByArgkey(ConfigSharePref.CONST_KEY_USER_SIGN);

			if (!UtilString.isEmpty(userSex)) {
				user.sex = Integer.parseInt(userSex);
			}
			if (!UtilString.isEmpty(userState)) {
				user.state = Integer.parseInt(userState);
			}
			Global.userid = user.id;
			Global.getMe().setGlobalUser(user);
			String encodeStr = ConfigSharePref.getInstance(this).getByArgkey(ConfigSharePref.CONST_ENCODESTR);
			Global.getMe().setEncodeStr(encodeStr);
		}

		UtilThread.executeMore(new Runnable() {
			@Override
			public void run() {
				mHandler.postDelayed(new Runnable() {
					@Override
					public void run() {
						startMainActivity();
					}
				}, 2000);
			}
		});
	}

	/**
	 * 
	 * @Author C.xt
	 * @Title: startMainActivity
	 * @Description: 启动登陆页面
	 * @return: void
	 * @throws
	 * @date 2013-6-4 下午8:02:16
	 */
	public void startMainActivity() {
		Intent intent = null;
		if (!autoLogon) {
			intent = new Intent(ActivityWelcome.this, ActivityLogin.class);
		} else {
			intent = new Intent(ActivityWelcome.this, ActivityMain.class);
		}
		startActivity(intent);
		finish();
	}

	/**
	 * 
	 * @Author C.xt
	 * @Title: startMainActivity
	 * @Description: 清理资源
	 * @return: void
	 * @throws
	 * @date 2013-6-4 下午8:02:16
	 */
	@Override
	protected void onDestroy() {
		super.onDestroy();
		if (null != pWlcome) {
			pWlcome.setCallback(null);
			pWlcome = null;
		}
	}

}
