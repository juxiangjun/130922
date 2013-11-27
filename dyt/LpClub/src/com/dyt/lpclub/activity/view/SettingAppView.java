package com.dyt.lpclub.activity.view;

import java.lang.ref.SoftReference;
import java.util.HashMap;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Handler;
import android.os.Message;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import com.dyt.lpclub.R;
import com.dyt.lpclub.activity.ActivityMain;
import com.dyt.lpclub.activity.HelpActivity;
import com.dyt.lpclub.activity.domain.Result;
import com.dyt.lpclub.activity.domain.User;
import com.dyt.lpclub.activity.domain.result.AbstractResult;
import com.dyt.lpclub.activity.view.util.AnimationController;
import com.dyt.lpclub.global.ConfigSharePref;
import com.dyt.lpclub.global.Global;
import com.dyt.lpclub.global.GlobalContants;
import com.dyt.lpclub.util.UtilBitmap;
import com.dyt.lpclub.util.UtilHttp;
import com.dyt.lpclub.util.UtilString;
import com.dyt.lpclub.util.UtilThread;
import com.google.gson.Gson;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.display.RoundedBitmapDisplayer;

/**
 * 描述:设置界面
 * 
 * @author linqiang(866116)
 * @Since 2013-6-6
 */
public class SettingAppView extends CommonAppView implements OnClickListener {

	private ActivityMain 		mContext;
	private RelativeLayout 		headLayout, 
								nameLayout, 
								sexLayout,
								pwdLayout,
								posLayout,
								areaLayout,
								jobLayout,
								signLayout;
	private TextView 			userName, 
								sex,
								pos,
								area,
								job,
								sign;
	private ImageView 			headImg;
	private Button 				logout;
	private ProgressDialog 		dailog;
	private User 				user;
	private String[] 			mStr;
	private static final int 	LOGIN_OUT = 1, 
								UPDATE_NAME = 2, 
								UPDATE_SEX = 3,
								UPDATE_AREA = 4,
								UPDATE_JOB = 5,
								UPDATE_POS = 6,
								UPDATE_SIGN = 7;
	private static final int 	SET_HEAD_MSG = 0;
	private int 				newSex;
	private PwdAppView 			pwdAppView;
	private View 				mainView;
	private AnimationController ctl;
	private boolean 			isPwdView;
	private DisplayImageOptions options;
	private int[] 				county = { 	R.array.area0, R.array.area1, R.array.area2, R.array.area3, R.array.area4, R.array.area5, R.array.area6, R.array.area7,
											R.array.area8, R.array.area9, R.array.area10, R.array.area11, R.array.area12, R.array.area13, R.array.area14, R.array.area15, R.array.area16,
											R.array.area17, R.array.area18, R.array.area19, R.array.area20, R.array.area21, R.array.area22, R.array.area23, R.array.area24, R.array.area25,
											R.array.area26, R.array.area27, R.array.area28, R.array.area29, R.array.area30, R.array.area31, R.array.area32, R.array.area33,
											};
	private int[] 				jobs = { 	R.array.job0, R.array.job1, R.array.job2, R.array.job3, R.array.job4, R.array.job5, R.array.job6, R.array.job7,
											R.array.job8, R.array.job9};
	private ArrayAdapter<CharSequence> county_adapter;
	private ArrayAdapter<CharSequence> job_adapter;
	
	public SettingAppView(Context paramContext) {
		super(paramContext);
		mContext = (ActivityMain) paramContext;
		init();
	}

	public SettingAppView(Context paramContext, AttributeSet paramAttributeSet) {
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
		options 	= 	new DisplayImageOptions.Builder()
							.showStubImage(R.drawable.default_head)
							.showImageForEmptyUri(R.drawable.default_head)
							.showImageOnFail(R.drawable.default_head)
							.cacheInMemory(true)
							.cacheOnDisc(true)
							.displayer(new RoundedBitmapDisplayer(8))
							.build();
		ctl 		=	 new AnimationController();
		user 		= 	Global.getMe().getGlobalUser();
		mainView 	= 	LayoutInflater.from(mContext).inflate(R.layout.layout_setting, null);
		addView(mainView);
		dailog 		= 	new ProgressDialog(mContext);
		headLayout 	= 	(RelativeLayout) $(R.id.headLayout);
		nameLayout 	= 	(RelativeLayout) $(R.id.nameLayout);
		sexLayout 	= 	(RelativeLayout) $(R.id.sexLayout);
		pwdLayout 	= 	(RelativeLayout) $(R.id.pwdLayout);
		posLayout 	= 	(RelativeLayout) $(R.id.posLayout);
		areaLayout 	= 	(RelativeLayout) $(R.id.areaLayout);
		jobLayout 	= 	(RelativeLayout) $(R.id.jobLayout);
		signLayout 	= 	(RelativeLayout) $(R.id.signLayout);
		logout 		= 	(Button) $(R.id.logout);
		headImg 	= 	(ImageView) $(R.id.headImg);
		userName 	= 	(TextView) $(R.id.userName);
		sex 		= 	(TextView) $(R.id.sex);
		pos 		= 	(TextView) $(R.id.pos);
		area 		= 	(TextView) $(R.id.area);
		job 		= 	(TextView) $(R.id.job);
		sign 		= 	(TextView) $(R.id.sign);
		mStr 		= 	new String[] { $Str(R.string.male), $Str(R.string.remale) };
		
		headImg.setImageResource(R.drawable.default_head);
		
		headLayout.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				mContext.showSelectHeadDialog();
			}
		});
		
		$(R.id.rexianLayout).setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				  //用intent启动拨打电话  
                Intent intent = new Intent(Intent.ACTION_CALL,Uri.parse("tel:4009975277"));  
                mContext.startActivity(intent);  
			}
		});
		
		$(R.id.aboutLayout).setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				  //用intent启动拨打电话  
                Intent intent = new Intent(mContext,HelpActivity.class);  
                mContext.startActivity(intent);  
			}
		});

		mContext.setOnBackListener(this);
		pwdLayout.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				if (pwdAppView == null) {
					pwdAppView = new PwdAppView(mContext);
				}
				if (pwdAppView != null) {
					ctl.slideOut(mainView, 500, 0);
					ctl.slideIn(pwdAppView, 500, 0);
					SettingAppView.this.removeAllViews();
					SettingAppView.this.addView(pwdAppView);
					mContext.setOnBackVisbility(View.VISIBLE);
					isPwdView = true;
				}
				setTitle();
			}
		});

		nameLayout.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				View view = LayoutInflater.from(mContext).inflate(R.layout.layout_dialog_text, null);
				final EditText newName = (EditText) view.findViewById(R.id.newText);
				new AlertDialog.Builder(mContext).setTitle("修改姓名").setView(view).setPositiveButton("确定", new DialogInterface.OnClickListener() {
					@Override
					public void onClick(DialogInterface dialog, int which) {
						final String name = newName.getText().toString();
						if (UtilString.isEmpty(name)) {
							Toast.makeText(mContext, "姓名不能为空", Toast.LENGTH_LONG).show();
							return;
						}
						dailog.setMessage($Str(R.string.progress));
						dailog.show();
						UtilThread.executeMore(new Runnable() {
							@Override
							public void run() {
								String url = GlobalContants.UPDATE_MEMBER_NAME;
								// userName password devicetype deviceid
								url += "&userid=" + user.id;
								url += "&name=" + name;
								url += "&encodeStr=" + Global.getMe().getEncodeStr();
								UtilHttp http = new UtilHttp(url, "UTF-8");
								String result = http.getResponseAsStringGET(new HashMap<String, String>());
								Message msg = new Message();
								msg.what = UPDATE_NAME;
								Result ps = new Result();
								ps.success = false;
								ps.msg = "修改失败";
								msg.obj = ps;
								if (result != null) {
									try {
										Gson gson = new Gson();
										ps = gson.fromJson(result, Result.class);
										//账号失效
										if (ps.returnCode == AbstractResult.RETURN_CODE_INVALID) {
											mHander.sendEmptyMessage(GlobalContants.INVALID);
											return;
										}
										ps.obj = name;
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
						});
					}
				}).setNegativeButton("取消", new DialogInterface.OnClickListener() {
					@Override
					public void onClick(DialogInterface dialog, int which) {
						dialog.dismiss();
					}
				}).show();
			}
		});

		sexLayout.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {

				View view = LayoutInflater.from(mContext).inflate(R.layout.layout_dialog_spinner, null);
				final Spinner spinner = (Spinner) view.findViewById(R.id.newText);
				ArrayAdapter<String> adapter = new ArrayAdapter<String>(mContext, android.R.layout.simple_spinner_item, mStr);
				//设置下拉列表的风格  
				adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
				spinner.setAdapter(adapter);
				spinner.setOnItemSelectedListener(new SpinnerSelectedListener());
				new AlertDialog.Builder(mContext).setTitle("修改性别").setView(view).setPositiveButton("确定", new DialogInterface.OnClickListener() {
					@Override
					public void onClick(DialogInterface dialog, int which) {
						dailog.setMessage($Str(R.string.progress));
						dailog.show();
						UtilThread.executeMore(new Runnable() {
							@Override
							public void run() {
								String url = GlobalContants.UPDATE_SEX;
								// userName password devicetype deviceid
								url += "&userid=" + user.id;
								url += "&sex=" + (newSex + 1);
								url += "&encodeStr=" + Global.getMe().getEncodeStr();
								UtilHttp http = new UtilHttp(url, "UTF-8");
								String result = http.getResponseAsStringGET(new HashMap<String, String>());
								Message msg = new Message();
								msg.what = UPDATE_SEX;
								Result ps = new Result();
								ps.success = false;
								ps.msg = "修改失败";
								msg.obj = ps;
								if (result != null) {
									try {
										Gson gson = new Gson();
										ps = gson.fromJson(result, Result.class);
										//账号失效
										if (ps.returnCode == AbstractResult.RETURN_CODE_INVALID) {
											mHander.sendEmptyMessage(GlobalContants.INVALID);
											return;
										}
										ps.obj = (newSex + 1);
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
						});
					}
				}).setNegativeButton("取消", new DialogInterface.OnClickListener() {
					@Override
					public void onClick(DialogInterface dialog, int which) {
						dialog.dismiss();
					}
				}).show();
			}
		});

		//退出系统
		logout.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				new AlertDialog.Builder(mContext).setTitle("退出确认").setMessage("您确定要退出本系统吗?").setPositiveButton("确定", new DialogInterface.OnClickListener() {
					@Override
					public void onClick(DialogInterface dialog, int which) {
						dailog.setMessage($Str(R.string.data_loading));
						dailog.show();
						UtilThread.executeMore(new Runnable() {
							@Override
							public void run() {
								String url = GlobalContants.LOGIN_OUT;
								// userName password devicetype deviceid
								url += "&userid=" + Global.getMe().getGlobalUser().id;
								url += "&encodeStr=" + Global.getMe().getEncodeStr();
								UtilHttp http = new UtilHttp(url, "UTF-8");
								http.getResponseAsStringGET(new HashMap<String, String>());

								ConfigSharePref.getInstance(mContext).setByArgkey(ConfigSharePref.CONST_KEY_USER_ID, "");

								mHander.sendEmptyMessage(LOGIN_OUT);
							}
						});

					}
				}).setNegativeButton("取消", new DialogInterface.OnClickListener() {
					@Override
					public void onClick(DialogInterface dialog, int which) {
						dialog.dismiss();
					}
				}).show();
			}
		});
		
		areaLayout.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				final View view = LayoutInflater.from(mContext).inflate(R.layout.layout_dialog_area, null);
				final Spinner area1 = (Spinner) view.findViewById(R.id.area1);
				final Spinner area2 = (Spinner) view.findViewById(R.id.area2);
				area1.setOnItemSelectedListener(new OnItemSelectedListener() {
					@Override
					public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
						select(area2, county_adapter, county[position]);
					}

					@Override
					public void onNothingSelected(AdapterView<?> arg0) {
						
					}
				});
				
				new AlertDialog.Builder(mContext).setTitle("修改地区").setView(view).setPositiveButton("确定", new DialogInterface.OnClickListener() {
					@Override
					public void onClick(DialogInterface dialog, int which) {
						dailog.setMessage($Str(R.string.progress));
						dailog.show();
						UtilThread.executeMore(new Runnable() {
							@Override
							public void run() {
								String url = GlobalContants.UPDATE_MEMBER_AREA;
								// userName password devicetype deviceid
								url += "&userid=" + user.id;
								url += "&area1=" + area1.getSelectedItem().toString();
								url += "&area2=" + area2.getSelectedItem().toString();
								url += "&encodeStr=" + Global.getMe().getEncodeStr();
								UtilHttp http = new UtilHttp(url, "UTF-8");
								String result = http.getResponseAsStringGET(new HashMap<String, String>());
								Message msg = new Message();
								msg.what = UPDATE_AREA;
								Result ps = new Result();
								ps.success = false;
								ps.msg = "修改失败";
								msg.obj = ps;
								if (result != null) {
									try {
										Gson gson = new Gson();
										ps = gson.fromJson(result, Result.class);
										//账号失效
										if (ps.returnCode == AbstractResult.RETURN_CODE_INVALID) {
											mHander.sendEmptyMessage(GlobalContants.INVALID);
											return;
										}
										ps.obj = area1.getSelectedItem().toString();
										ps.obj1 = area2.getSelectedItem().toString();
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
						});
					}
				}).setNegativeButton("取消", new DialogInterface.OnClickListener() {
					@Override
					public void onClick(DialogInterface dialog, int which) {
						dialog.dismiss();
					}
				}).show();
			}
		});
		
		
		jobLayout.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				final View view = LayoutInflater.from(mContext).inflate(R.layout.layout_dialog_job, null);
				final Spinner job1 = (Spinner) view.findViewById(R.id.job1);
				final Spinner job2 = (Spinner) view.findViewById(R.id.job2);
				job1.setOnItemSelectedListener(new OnItemSelectedListener() {
					@Override
					public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
						select(job2, job_adapter, jobs[position]);
					}

					@Override
					public void onNothingSelected(AdapterView<?> arg0) {
						
					}
				});
				
				
				new AlertDialog.Builder(mContext).setTitle("修改行业信息").setView(view).setPositiveButton("确定", new DialogInterface.OnClickListener() {
					@Override
					public void onClick(DialogInterface dialog, int which) {
						dailog.setMessage($Str(R.string.progress));
						dailog.show();
						UtilThread.executeMore(new Runnable() {
							@Override
							public void run() {
								String url = GlobalContants.UPDATE_MEMBER_JOB;
								// userName password devicetype deviceid
								url += "&userid=" + user.id;
								url += "&job1=" + job1.getSelectedItem().toString();
								url += "&job2=" + job2.getSelectedItem().toString();
								url += "&encodeStr=" + Global.getMe().getEncodeStr();
								UtilHttp http = new UtilHttp(url, "UTF-8");
								String result = http.getResponseAsStringGET(new HashMap<String, String>());
								Message msg = new Message();
								msg.what = UPDATE_JOB;
								Result ps = new Result();
								ps.success = false;
								ps.msg = "修改失败";
								msg.obj = ps;
								if (result != null) {
									try {
										Gson gson = new Gson();
										ps = gson.fromJson(result, Result.class);
										//账号失效
										if (ps.returnCode == AbstractResult.RETURN_CODE_INVALID) {
											mHander.sendEmptyMessage(GlobalContants.INVALID);
											return;
										}
										ps.obj = job1.getSelectedItem().toString();
										ps.obj1 = job2.getSelectedItem().toString();
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
						});
					}
				}).setNegativeButton("取消", new DialogInterface.OnClickListener() {
					@Override
					public void onClick(DialogInterface dialog, int which) {
						dialog.dismiss();
					}
				}).show();
			}
		});
		
		signLayout.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				View view = LayoutInflater.from(mContext).inflate(R.layout.layout_dialog_text, null);
				view.findViewById(R.id.title).setVisibility(View.GONE);
				final EditText newName = (EditText) view.findViewById(R.id.newText);
				new AlertDialog.Builder(mContext).setTitle("修改个性签名").setView(view).setPositiveButton("确定", new DialogInterface.OnClickListener() {
					@Override
					public void onClick(DialogInterface dialog, int which) {
						final String name = newName.getText().toString();
						if (UtilString.isEmpty(name)) {
							Toast.makeText(mContext, "个性签名不能为空", Toast.LENGTH_LONG).show();
							return;
						}
						dailog.setMessage($Str(R.string.progress));
						dailog.show();
						UtilThread.executeMore(new Runnable() {
							@Override
							public void run() {
								String url = GlobalContants.UPDATE_MEMBER_SIGN;
								// userName password devicetype deviceid
								url += "&userid=" + user.id;
								url += "&sign=" + name;
								url += "&encodeStr=" + Global.getMe().getEncodeStr();
								UtilHttp http = new UtilHttp(url, "UTF-8");
								String result = http.getResponseAsStringGET(new HashMap<String, String>());
								Message msg = new Message();
								msg.what = UPDATE_SIGN;
								Result ps = new Result();
								ps.success = false;
								ps.msg = "修改失败";
								msg.obj = ps;
								if (result != null) {
									try {
										Gson gson = new Gson();
										ps = gson.fromJson(result, Result.class);
										//账号失效
										if (ps.returnCode == AbstractResult.RETURN_CODE_INVALID) {
											mHander.sendEmptyMessage(GlobalContants.INVALID);
											return;
										}
										ps.obj = name;
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
						});
					}
				}).setNegativeButton("取消", new DialogInterface.OnClickListener() {
					@Override
					public void onClick(DialogInterface dialog, int which) {
						dialog.dismiss();
					}
				}).show();
			}
		});
		
		posLayout.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				View view = LayoutInflater.from(mContext).inflate(R.layout.layout_dialog_text, null);
				view.findViewById(R.id.title).setVisibility(View.GONE);
				final EditText newName = (EditText) view.findViewById(R.id.newText);
				new AlertDialog.Builder(mContext).setTitle("修改职位").setView(view).setPositiveButton("确定", new DialogInterface.OnClickListener() {
					@Override
					public void onClick(DialogInterface dialog, int which) {
						final String name = newName.getText().toString();
						if (UtilString.isEmpty(name)) {
							Toast.makeText(mContext, "职位不能为空", Toast.LENGTH_LONG).show();
							return;
						}
						dailog.setMessage($Str(R.string.progress));
						dailog.show();
						UtilThread.executeMore(new Runnable() {
							@Override
							public void run() {
								String url = GlobalContants.UPDATE_MEMBER_POS;
								// userName password devicetype deviceid
								url += "&userid=" + user.id;
								url += "&pos=" + name;
								url += "&encodeStr=" + Global.getMe().getEncodeStr();
								UtilHttp http = new UtilHttp(url, "UTF-8");
								String result = http.getResponseAsStringGET(new HashMap<String, String>());
								Message msg = new Message();
								msg.what = UPDATE_POS;
								Result ps = new Result();
								ps.success = false;
								ps.msg = "修改失败";
								msg.obj = ps;
								if (result != null) {
									try {
										Gson gson = new Gson();
										ps = gson.fromJson(result, Result.class);
										//账号失效
										if (ps.returnCode == AbstractResult.RETURN_CODE_INVALID) {
											mHander.sendEmptyMessage(GlobalContants.INVALID);
											return;
										}
										ps.obj = name;
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
						});
					}
				}).setNegativeButton("取消", new DialogInterface.OnClickListener() {
					@Override
					public void onClick(DialogInterface dialog, int which) {
						dialog.dismiss();
					}
				}).show();
			}
		});
	}
	
	private void select(Spinner spin, ArrayAdapter<CharSequence> adapter, int arry)
	{
		adapter = ArrayAdapter.createFromResource(mContext, arry, android.R.layout.simple_spinner_item);
		adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		spin.setAdapter(adapter);
	}
	
	private Handler mHander = new Handler() {
		public void handleMessage(Message msg) {
			if (dailog != null && dailog.isShowing()) {
				dailog.dismiss();
			}
			Result r = null;
			switch (msg.what) {
			case LOGIN_OUT:
				mContext.returnLogin();
				break;
			case UPDATE_SEX:
				r = (Result) msg.obj;
				if (r.success) {
					Global.getMe().getGlobalUser().sex = (Integer) r.obj;
				}
				if (user.sex == 1) {
					sex.setText(R.string.male);
				} else {
					sex.setText(R.string.remale);
				}
				ConfigSharePref.getInstance(mContext).setByArgkey(ConfigSharePref.CONST_KEY_USER_SEX, user.sex + "");
				Toast.makeText(mContext, r.msg, Toast.LENGTH_LONG).show();
				break;
			case UPDATE_NAME:
				r = (Result) msg.obj;
				if (r.success) {
					Global.getMe().getGlobalUser().name = (String) r.obj;
				}
				userName.setText(user.name);
				ConfigSharePref.getInstance(mContext).setByArgkey(ConfigSharePref.CONST_KEY_USER_NAME, user.name);
				Toast.makeText(mContext, r.msg, Toast.LENGTH_LONG).show();
				break;
			case UPDATE_SIGN:
				r = (Result) msg.obj;
				if (r.success) {
					Global.getMe().getGlobalUser().sign = (String) r.obj;
				}
				sign.setText(user.sign);
				ConfigSharePref.getInstance(mContext).setByArgkey(ConfigSharePref.CONST_KEY_USER_SIGN, user.sign);
				Toast.makeText(mContext, r.msg, Toast.LENGTH_LONG).show();
				break;
			case UPDATE_POS:
				r = (Result) msg.obj;
				if (r.success) {
					Global.getMe().getGlobalUser().pos = (String) r.obj;
				}
				pos.setText(user.pos);
				ConfigSharePref.getInstance(mContext).setByArgkey(ConfigSharePref.CONST_KEY_USER_POS, user.pos);
				Toast.makeText(mContext, r.msg, Toast.LENGTH_LONG).show();
				break;
			case UPDATE_AREA:
				r = (Result) msg.obj;
				if (r.success) {
					Global.getMe().getGlobalUser().area1 = (String) r.obj;
					Global.getMe().getGlobalUser().area2 = (String) r.obj1;
				}
				area.setText(user.area1 + "-" + user.area2);
				ConfigSharePref.getInstance(mContext).setByArgkey(ConfigSharePref.CONST_KEY_USER_AREA1, user.area1);
				ConfigSharePref.getInstance(mContext).setByArgkey(ConfigSharePref.CONST_KEY_USER_AREA2, user.area2);
				Toast.makeText(mContext, r.msg, Toast.LENGTH_LONG).show();
				break;
			case UPDATE_JOB:
				r = (Result) msg.obj;
				if (r.success) {
					Global.getMe().getGlobalUser().job1 = (String) r.obj;
					Global.getMe().getGlobalUser().job2 = (String) r.obj1;
				}
				job.setText(user.job2);
				ConfigSharePref.getInstance(mContext).setByArgkey(ConfigSharePref.CONST_KEY_USER_JOB1, user.job1);
				ConfigSharePref.getInstance(mContext).setByArgkey(ConfigSharePref.CONST_KEY_USER_JOB2, user.job2);
				Toast.makeText(mContext, r.msg, Toast.LENGTH_LONG).show();
				break;
			case SET_HEAD_MSG:
				SoftReference<Bitmap> head = UtilBitmap.getIconCache().get(String.valueOf(user.id));
				headImg.setImageBitmap(head.get());
				break;
			case GlobalContants.INVALID:
				ActivityMain.instance.exit("大业堂提示", "你的账号已失败,\n点击[确定]退出重新登录");
			default:

				break;
			}
		};
	};
	
	
	//使用数组形式操作  
	class SpinnerSelectedListener implements OnItemSelectedListener {

		public void onItemSelected(AdapterView<?> arg0, View arg1, int arg2, long arg3) {
			newSex = arg2;
		}

		public void onNothingSelected(AdapterView<?> arg0) {
		}
	}

	private String $Str(int resId) {
		return mContext.getString(resId);
	}

	private View $(int resId) {
		return findViewById(resId);
	}

	@Override
	public void onClick(View v) {
		if (pwdAppView != null) {
			ctl.slideInBack(pwdAppView, 500, 0);
			ctl.slideOutBack(mainView, 500, 0);
			pwdAppView.reset();
			this.removeAllViews();
			this.addView(mainView);
			mContext.setOnBackVisbility(View.GONE);
			isPwdView = false;
			mContext.closeSofeKey(v);
		}
		setTitle();
	}

	public void setTitle() {
		if (isPwdView) {
			mContext.setOnBackVisbility(View.VISIBLE);
			mContext.setTitleContext(mContext.getString(R.string.eidt_pwd));
		} else {
			mContext.setOnBackVisbility(View.GONE);
			mContext.setTitleContext(mContext.getString(R.string.setting));
		}
	}

	public void refreshUser() {
		user = Global.getMe().getGlobalUser();
		userName.setText(user.name);
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
		
		if (user.sex == 1) {
			sex.setText(R.string.male);
		} else {
			sex.setText(R.string.remale);
		}
		
		if (!UtilString.isEmpty(user.thumb)) {
			if (user.thumb.startsWith("file:/")) {
				ImageLoader.getInstance().displayImage(user.thumb, headImg, options);
			} else {
				ImageLoader.getInstance().displayImage(GlobalContants.CONST_STR_BASE_URL + user.thumb, headImg, options);
			}
		}
	}
	
	public void refreshHead(){
		user = Global.getMe().getGlobalUser();
		if (!UtilString.isEmpty(user.thumb)) {
			ImageLoader.getInstance().displayImage(user.thumb, headImg, options);
		}
	}
}
