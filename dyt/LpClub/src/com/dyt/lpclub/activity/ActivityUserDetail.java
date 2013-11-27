package com.dyt.lpclub.activity;

import java.util.HashMap;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.dyt.lpclub.R;
import com.dyt.lpclub.activity.domain.User;
import com.dyt.lpclub.activity.domain.result.AbstractResult;
import com.dyt.lpclub.activity.domain.result.UserResult;
import com.dyt.lpclub.activity.imgbrowse.ActivityImgBrowse;
import com.dyt.lpclub.global.Global;
import com.dyt.lpclub.global.GlobalContants;
import com.dyt.lpclub.util.UtilHttp;
import com.dyt.lpclub.util.UtilString;
import com.dyt.lpclub.util.UtilThread;
import com.dyt.lpclub.util.ViewUtil;
import com.google.gson.Gson;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.display.RoundedBitmapDisplayer;

public class ActivityUserDetail extends Activity {

	private TextView 				username, 
									sex,
									pos,
									area,
									job,
									sign;
	private ImageView 				headImage;
	private DisplayImageOptions 	options;
	private ProgressDialog 			dailog;
	private User 					user;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		ViewUtil.fullscreen(this);
		setContentView(R.layout.layout_activity_user_detail);
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
		final int userId 		= 	getIntent().getIntExtra("userid", 0);
		username 		= 	(TextView) $(R.id.username);
		sex 			= 	(TextView) $(R.id.sex);
		pos 			= 	(TextView) $(R.id.pos);
		area 			= 	(TextView) $(R.id.area);
		job 			= 	(TextView) $(R.id.job);
		sign 			= 	(TextView) $(R.id.sign);
		headImage 		= 	(ImageView) $(R.id.imageHead);
		this.options 	= 	new DisplayImageOptions.Builder()
								.showStubImage(R.drawable.default_head)
								.showImageForEmptyUri(R.drawable.default_head)
								.showImageOnFail(R.drawable.default_head)
								.cacheInMemory(true)
								.cacheOnDisc(true)
								.displayer(new RoundedBitmapDisplayer(8))
								.build();
		this.dailog 	= 	new ProgressDialog(this);
		
		
		headImage.setImageResource(R.drawable.default_head);
		
		headImage.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				Intent intent = new Intent(ActivityUserDetail.this, ActivityImgBrowse.class);
				intent.putExtra("showPic", true);
				intent.putExtra("nowUrl",  user.pic);
				intent.putExtra("userName",  user.name);
				startActivity(intent);
			}
		});
		
		$(R.id.btn_back).setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				finish();
			}
		});

		dailog.setMessage("获取数据中..");
		dailog.show();
		UtilThread.executeMore(new Runnable() {
			@Override
			public void run() {
				String url = GlobalContants.GET_MEMBER_INFO;
				url += "&userid=" + userId;
				url += "&encodeStr=" + Global.getMe().getEncodeStr();
				UtilHttp http = new UtilHttp(url, "UTF-8");
				String result = http
						.getResponseAsStringGET(new HashMap<String, String>());
				if (result != null) {
					try {
						Gson gson = new Gson();
						UserResult userResult = gson.fromJson(result, UserResult.class);
						//账号失效
						if (userResult.returnCode == AbstractResult.RETURN_CODE_INVALID) {
							mHander.sendEmptyMessage(GlobalContants.INVALID);
							return;
						}
						user = userResult.obj;
						mHander.sendEmptyMessage(GlobalContants.SUCCESS);
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
	
	private Handler mHander = new Handler() {
		public void handleMessage(Message msg) {
			if (dailog != null && dailog.isShowing()) {
				dailog.dismiss();
			}
			switch (msg.what) {
			case GlobalContants.SUCCESS:
				refresh(user);
				break;
			case GlobalContants.FAIL:
				Toast.makeText(ActivityUserDetail.this, R.string.data_load_fail, Toast.LENGTH_SHORT).show();
				break;
			case GlobalContants.INVALID:
				finish();
				ActivityMain.instance.exit("大业堂提示", "你的账号已失效,\n点击[确定]退出重新登录");
				break;
			default:
				break;
			}
		};
	};

	private void refresh(final User user) {
		headImage.setImageResource(R.drawable.default_head);

		if (!UtilString.isEmpty(user.thumb)) {
			ImageLoader.getInstance().displayImage(GlobalContants.CONST_STR_BASE_URL + user.thumb, headImage, options);
		}

		username.setText(user.name);
		if (user.sex == 1) {
			sex.setText(R.string.male);
		} else {
			sex.setText(R.string.remale);
		}
		
		if(!UtilString.isEmpty(user.pos)){
			pos.setText(user.pos);
		}
		
		if(!UtilString.isEmpty(user.area1)){
			area.setText(user.area1 + "-" + user.area2);
		}
		
		if(!UtilString.isEmpty(user.job1)){
			job.setText( user.job2);
		}
		
		if(!UtilString.isEmpty(user.sign)){
			sign.setText(user.sign);
		}
		
	}

	private View $(int resId) {
		return findViewById(resId);
	}
}
