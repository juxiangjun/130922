package com.dyt.lpclub.activity.view;

import java.util.HashMap;

import android.app.ProgressDialog;
import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.util.AttributeSet;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import com.dyt.lpclub.R;
import com.dyt.lpclub.activity.ActivityMain;
import com.dyt.lpclub.activity.domain.Result;
import com.dyt.lpclub.activity.domain.User;
import com.dyt.lpclub.global.ConfigSharePref;
import com.dyt.lpclub.global.Global;
import com.dyt.lpclub.global.GlobalContants;
import com.dyt.lpclub.util.UtilHttp;
import com.dyt.lpclub.util.UtilString;
import com.google.gson.Gson;

/**
 * 描述:设置界面
 * 
 * @author linqiang(866116)
 * @Since 2013-6-6
 */
public class PwdAppView extends CommonAppView implements OnClickListener {

	private ActivityMain mContext;
	private TextView oldPwd, newPwd, comfirmPwd;
	private Button submit, reset;
	private ProgressDialog dailog;
	private User user;

	public PwdAppView(Context paramContext) {
		super(paramContext);
		mContext = (ActivityMain) paramContext;
		init();
	}

	public PwdAppView(Context paramContext, AttributeSet paramAttributeSet) {
		super(paramContext, paramAttributeSet);
		mContext = (ActivityMain) paramContext;
		init();
	}

	/**
	 * 
	 * 方法描述:初始化
	 * 
	 * @Author:solotiger
	 * @Date:2013-6-4
	 * @return:void
	 */
	private void init() {
		user = Global.getMe().getGlobalUser();
		addView(R.layout.layout_pwd);
		dailog = new ProgressDialog(mContext);
		oldPwd = (TextView) $(R.id.eidt_old_pwd);
		newPwd = (TextView) $(R.id.eidt_new_pwd);
		comfirmPwd = (TextView) $(R.id.eidt_confirm_pwd);
		submit = (Button) $(R.id.submit);
		submit.setOnClickListener(this);
		reset = (Button) $(R.id.reset);
		reset.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				reset();
			}
		});

	}

	public void reset() {
		oldPwd.setText("");
		newPwd.setText("");
		comfirmPwd.setText("");
	}

	private Handler mHander = new Handler() {
		public void handleMessage(Message msg) {
			if (dailog != null && dailog.isShowing()) {
				dailog.dismiss();
			}
			if (msg.what == GlobalContants.SUCCESS) {
				Result ps = (Result) msg.obj;
				if (ps.success) {
					ConfigSharePref.getInstance(mContext).setByArgkey(ConfigSharePref.CONST_KEY_USER_PASSWORD, newPwd.getText().toString());
					Toast.makeText(mContext, "密码修改成功!", Toast.LENGTH_SHORT).show();
				} else {
					Toast.makeText(mContext, "密码修改错误!", Toast.LENGTH_SHORT).show();
				}
			} else {
				Toast.makeText(mContext, "密码修改错误!", Toast.LENGTH_SHORT).show();
			}
			reset();
		};
	};

	private View $(int resId) {
		return findViewById(resId);
	}

	@Override
	public void onClick(View v) {

		if (UtilString.isEmpty(newPwd.getText().toString())) {
			Toast.makeText(mContext, "密码不能为空!", Toast.LENGTH_SHORT).show();
			return;
		}

		if (!newPwd.getText().toString().equals(comfirmPwd.getText().toString())) {
			Toast.makeText(mContext, "两次输入的密码不一致!", Toast.LENGTH_SHORT).show();
			return;
		}
		dailog.show();
		String url = GlobalContants.UPDATE_PWD;
		// userName password devicetype deviceid
		url += "&userid=" + user.id;
		url += "&password=" + newPwd.getText().toString();
		url += "&oldpassword=" + oldPwd.getText().toString();
		url += "&encodeStr=" + Global.getMe().getEncodeStr();
		UtilHttp http = new UtilHttp(url, "UTF-8");
		String result = http.getResponseAsStringGET(new HashMap<String, String>());
		Message msg = new Message();
		msg.what = GlobalContants.FAIL;
		if (result != null) {
			try {
				Gson gson = new Gson();
				Result ps = gson.fromJson(result, Result.class);
				msg.what = GlobalContants.SUCCESS;
				msg.obj = ps;
				mHander.sendMessage(msg);
			} catch (Exception e) {
				e.printStackTrace();
				mHander.sendMessage(msg);
			}
		} else {
			mHander.sendMessage(msg);
		}

	}
}
