package com.dyt.lpclub.activity;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.InputStreamReader;
import java.lang.ref.SoftReference;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;
import java.util.concurrent.atomic.AtomicBoolean;

import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.methods.MultipartPostMethod;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.provider.MediaStore;
import android.view.ContextMenu;
import android.view.KeyEvent;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;
import cn.jpush.android.api.JPushInterface;

import com.dyt.lpclub.R;
import com.dyt.lpclub.activity.domain.Group;
import com.dyt.lpclub.activity.domain.Result;
import com.dyt.lpclub.activity.domain.User;
import com.dyt.lpclub.activity.domain.db.Dao;
import com.dyt.lpclub.activity.domain.db.GroupTable;
import com.dyt.lpclub.activity.domain.db.LpClubDB;
import com.dyt.lpclub.activity.domain.db.UserTable;
import com.dyt.lpclub.activity.domain.result.AbstractResult;
import com.dyt.lpclub.activity.domain.result.GetMemberGroupReuslt;
import com.dyt.lpclub.activity.domain.result.GroupMemberListResult;
import com.dyt.lpclub.activity.domain.result.QueryNewsListResult;
import com.dyt.lpclub.activity.view.AnnounceAppView;
import com.dyt.lpclub.activity.view.BadgeView;
import com.dyt.lpclub.activity.view.CommonAppView;
import com.dyt.lpclub.activity.view.GroupAppView;
import com.dyt.lpclub.activity.view.LoadFailedAppView;
import com.dyt.lpclub.activity.view.MsgAppView;
import com.dyt.lpclub.activity.view.SettingAppView;
import com.dyt.lpclub.global.ConfigSharePref;
import com.dyt.lpclub.global.Global;
import com.dyt.lpclub.global.GlobalContants;
import com.dyt.lpclub.global.GolbalUserCache;
import com.dyt.lpclub.util.PingYinUtil;
import com.dyt.lpclub.util.UtilBitmap;
import com.dyt.lpclub.util.UtilHttp;
import com.dyt.lpclub.util.UtilString;
import com.dyt.lpclub.util.UtilTelephone;
import com.dyt.lpclub.util.UtilThread;
import com.dyt.lpclub.util.ViewUtil;
import com.google.gson.Gson;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.AsyncHttpResponseHandler;
import com.loopj.android.http.RequestParams;
import com.nostra13.universalimageloader.core.ImageLoader;

/**
 * @ProjectName LpClub
 * @Author C.xt
 * @Version 1.0.0
 * @CreateDate： 2013-6-4 下午8:15:59
 * @JDK <JDK1.6> Description: 主Activity
 */
public class ActivityMain extends Activity implements OnClickListener {
	public static ActivityMain instance = null;
	//	private ImageView announceButtonImg, groupButtonImg, msgButtonImg, settingButtonImg;
	private LinearLayout announceButton, groupButton, msgButton, settingButton;
	private FrameLayout contentFrame;
	private TextView titleContext;
	private Button backBtn;
	private String imageName;
	private static final int 	UPLOAD_HEAD_SUCCESS = 200, UPLOAD_HEAD_FAIL = -200, 
								LOGIN_OUT = 201,NETWORK_BROKEN = 203,
								LOCAL_LOAD_SUCCESS = 300;
	private LinkedHashMap<Integer, CommonAppView> viewCache = new LinkedHashMap<Integer, CommonAppView>();

	public static final int MSG_VIEW = 1;
	public static final int GROUP_VIEW = 2;
	public static final int ANNOUNCE_VIEW = 3;
	public static final int SETTING_VIEW = 4;
	public static final int FAILED_VIEW = 5;

	private int currentMark;
	private Context mContext;
	private ProgressDialog dailog;
	public static AtomicBoolean firstLoadSuccess;
	private TextView t;
	private long mExitTime;
	private BadgeView badge,aBadge;
	private InputMethodManager imm;
	private Set<String> tagSet = new LinkedHashSet<String>();
	private boolean returnLogin;
	private boolean hasNewAnnounce;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		ViewUtil.fullscreen(this);
		mContext = this;
		instance = this;
		setContentView(R.layout.activity_main);
		dailog = new ProgressDialog(mContext);
		init();
		imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
		//		showChoosedView(FAILED_VIEW);
		firstLoad();
		Global.isOpen = true;
		returnLogin = false;
	}

	public void firstLoad() {
		firstLoadSuccess = new AtomicBoolean(false);
		setLoadTip($Str(R.string.data_loading));
		dailog.setMessage($Str(R.string.first_load));
		try {
			dailog.show();
		} catch (Exception e) {
			e.printStackTrace();
		}
		UtilThread.executeMore(new Runnable() {
			@Override
			public void run() {
				final int userId = Global.userid;
				loadLocal(userId);
			}
		});
	}

	
	private void loadLocal(int userId){
		LpClubDB db = null;
		Dao dao = null;
		try {
			db = new LpClubDB(mContext);
			dao = new Dao();
			ArrayList<Group> ps = dao.getGroupByUserId(db, userId, true);
			for (int i = 0, len = ps.size(); i < len; i++) {
				List<Group> subGroup = dao.getSubGroupByParentId(db, ps.get(i).getId());
				for (Group g : subGroup) {
					tagSet.add("" + g.getId());
				}
				ps.get(i).setSubGroup(subGroup);
			}
			Global.getMe().setGroupList(ps);
			ArrayList<User> userlist = dao.getUserList(db, userId);
			for (User user : userlist) {
				GolbalUserCache.getUserCache().put(String.valueOf(user.id), new SoftReference<User>(user));
			}
			mHander.sendEmptyMessage(LOCAL_LOAD_SUCCESS);
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (null != db)
				db.close();
		}
	}
	
	private void loadNet(){
		final int userId = Global.userid;
		if (!UtilTelephone.isNetworkAvailable(mContext)) {
			mHander.sendEmptyMessage(NETWORK_BROKEN);
		} else {
			String url = GlobalContants.GET_MEMBER_GROUP;
			final AsyncHttpClient client = new AsyncHttpClient();
			//							UtilHttp http = new UtilHttp(url, "UTF-8");
			RequestParams params = new RequestParams();
			params.put("userid", String.valueOf(userId));
			params.put("encodeStr", Global.getMe().getEncodeStr());
			client.post(url, params, new AsyncHttpResponseHandler() {
				
				@Override
				public void onFailure(Throwable arg0, String arg1) {
					super.onFailure(arg0, arg1);
//					loadLocal(userId);
					mHander.sendEmptyMessage(NETWORK_BROKEN);
				}

				public void onSuccess(String result) {
					if (result != null) {
						try {
							
							//是否有新的公告
							String url3 = GlobalContants.QUERY_NEWS_LIST;
							url3 += "&start=" + 0;
							url3 += "&limit=" + 1;
							url3 += "&encodeStr=" + Global.getMe().getEncodeStr();
							UtilHttp http3 = new UtilHttp(url3, "UTF-8");
							String result3 = http3.getResponseAsStringGET(new HashMap<String, String>());
							if (result3 != null) {
								try {
									Gson gson3 = new Gson();
									QueryNewsListResult queryNewsResult = gson3.fromJson(result3, QueryNewsListResult.class);
									//账号失效
									if (queryNewsResult.returnCode == AbstractResult.RETURN_CODE_INVALID) {
										mHander.sendEmptyMessage(GlobalContants.INVALID);
										return;
									}
									String localTo = ConfigSharePref.getInstance(mContext).getByArgkey("announce_totalCount");
									if(UtilString.isEmpty(localTo) || Integer.parseInt(localTo) < queryNewsResult.obj.totalCount){
										hasNewAnnounce = true;
									}
								} catch (Exception e) {
									e.printStackTrace();
								}
							} 
							
							
							Gson gson = new Gson();
							AbstractResult areturnReuslt = gson.fromJson(result, AbstractResult.class);
							//账号失效
							if (areturnReuslt.returnCode == AbstractResult.RETURN_CODE_INVALID) {
								mHander.sendEmptyMessage(GlobalContants.INVALID);
								return;
							}
							GetMemberGroupReuslt returnReuslt = gson.fromJson(result, GetMemberGroupReuslt.class);
							List<Group> ps = returnReuslt.obj;
							final Set<User> set = new TreeSet<User>();
							if (null == ps || ps.size() <= 0) {
								mHander.sendEmptyMessage(GlobalContants.SUCCESS);
								return;
							}
							final LpClubDB db = new LpClubDB(mContext);
							try {
								db.execSQL("DELETE FROM [" + GroupTable.CONST_TALBENAME + "] WHERE USERID =" + userId);
								//先删除
								for (Group group : ps) {
									List<Group> list = group.getSubGroup();
									String spell = PingYinUtil.getPingYin(group.getName());
									group.spell = spell;
									//父组入库
									db.execSQL(
											GroupTable.CONST_INSERT,
											new String[] { "" + group.getId(), group.getName()+"", "" + group.getState(), userId + "",
													group.getRemark()+"", group.getPic()+"", group.getNews()+"", "" + group.getType(),
													"" + group.getResId(), "", list.size() + "", spell });
									for (final Group g : list) {
										tagSet.add("" + g.getId());
										String gurl = GlobalContants.GET_GROUP_MEMBER_LIST;
										gurl += "&groupid=" + g.getId();
										gurl += "&encodeStr=" +  Global.getMe().getEncodeStr();
										UtilHttp http = new UtilHttp(gurl, "UTF-8");
										String gresult = http.getResponseAsStringPost(new HashMap<String, String>());
										Gson gs = new Gson();
										AbstractResult areturnReuslt1 = gs.fromJson(gresult, AbstractResult.class);
										//账号失效
										if (areturnReuslt1.returnCode == AbstractResult.RETURN_CODE_INVALID) {
											mHander.sendEmptyMessage(GlobalContants.INVALID);
											return;
										}
										GroupMemberListResult returnResult = gs.fromJson(gresult, GroupMemberListResult.class);
										List<User> userList = returnResult.obj;
										if (userList != null)
											set.addAll(userList);
										String gspell = PingYinUtil.getPingYin(g.getName());
										g.spell = gspell;
										//子组入库
										db.execSQL(GroupTable.CONST_INSERT, new String[] { "" + g.getId(), g.getName()+"", "" + g.getState(),
												userId + "", g.getRemark()+"", g.getPic()+"", g.getNews()+"", "" + g.getType(), "" + g.getResId(),
												"" + group.getId(), g.getMemberCount() + "", gspell });
									}

								}
								//先删除
								db.execSQL("DELETE FROM [" + UserTable.CONST_TALBENAME + "] WHERE KEY_USER_ID = " + userId);
								for (User user : set) {
									GolbalUserCache.getUserCache().put(String.valueOf(user.id), new SoftReference<User>(user));
									db.execSQL(UserTable.CONST_INSERT,
											new String[] { "" + user.id, user.account, "" + 
															user.state, user.name, user.password,
															"" + user.devicetype, "" + user.deviceid, 
															"" + user.pic, user.sex + ""
															,user.pos, user.area1,user.area2,user.sign
															,user.job1,user.job2,userId + "",user.thumb});
								}
								Global.getMe().setUserList(Arrays.asList(set.toArray(new User[] {})));
								Collections.sort(ps);
								Global.getMe().setGroupList(ps);
								mHander.sendEmptyMessage(GlobalContants.SUCCESS);
							} catch (Exception e) {
								e.printStackTrace();
							} finally {
								if (null != db)
									db.close();
							}
							
						} catch (Exception e) {
							e.printStackTrace();
							mHander.sendEmptyMessage(GlobalContants.FAIL);
						}
					} else {
						mHander.sendEmptyMessage(GlobalContants.FAIL);
					}
				};
			});
		}
	}
	
	/**
	 * 描述:初始化
	 * 
	 * @author linqiang(866116)
	 * @Since 2013-6-5
	 */
	private void init() {
		currentMark = MSG_VIEW;
		this.contentFrame = (FrameLayout) $(R.id.contentFrame);
		this.titleContext = (TextView) $(R.id.layout_title);
		this.backBtn = (Button) $(R.id.btn_back);
		setOnBackVisbility(View.GONE);
		announceButton = (LinearLayout) $(R.id.announceButton);
		//		announceButtonImg = (ImageView) $(R.id.announceButtonImg);
		groupButton = (LinearLayout) $(R.id.groupButton);
		//		groupButtonImg = (ImageView) $(R.id.groupButtonImg);
		msgButton = (LinearLayout) $(R.id.msgButton);
		//		msgButtonImg = (ImageView) $(R.id.msgButtonImg);
		settingButton = (LinearLayout) $(R.id.settingButton);
		//		settingButtonImg = (ImageView) $(R.id.settingButtonImg);
		doRegister();
		badge = new BadgeView(this, msgButton);
		badge.setBackgroundResource(R.drawable.badge_ifaux);
		badge.setTextSize(12);
		aBadge = new BadgeView(this, announceButton);
		aBadge.setBackgroundResource(R.drawable.badge_ifaux);
		aBadge.setTextSize(6);
		Global.getMe().setmContext(this);
	}

	/**
	 * 描述:注册
	 * 
	 * @author linqiang(866116)
	 * @Since 2013-6-6
	 */
	private void doRegister() {
		registerView(ANNOUNCE_VIEW);
		registerView(GROUP_VIEW);
		registerView(MSG_VIEW);
		registerView(SETTING_VIEW);
		registerView(FAILED_VIEW);

		registerTrigger(announceButton);
		registerTrigger(msgButton);
		registerTrigger(settingButton);
		registerTrigger(groupButton);
	}

	private final void registerTrigger(View paramView) {
		paramView.setOnClickListener(this);
	}

	private final void registerView(int paramInt) {
		viewCache.put(paramInt, null);
	}

	/**
	 * 描述:修改样式
	 * 
	 * @author linqiang(866116)
	 * @Since 2013-6-6
	 * @param paramInt
	 * @param paramBoolean
	 */
	private void setTabSelected(int paramInt, boolean paramBoolean) {

		switch (paramInt) {
		case MSG_VIEW:
			if (paramBoolean) {
				msgButton.setBackgroundResource(R.drawable.footer_selected);
				//				msgButtonImg.setBackgroundResource(R.drawable.msg_footer_pressed);
			} else {
				//				msgButtonImg.setBackgroundResource(R.drawable.msg_footer_normal);
				msgButton.setBackgroundColor(Color.parseColor("#00000000"));
			}
			break;

		case GROUP_VIEW:
			if (paramBoolean) {
				groupButton.setBackgroundResource(R.drawable.footer_selected);
				//				groupButtonImg.setBackgroundResource(R.drawable.group_footer_pressed);
			} else {
				//				groupButtonImg.setBackgroundResource(R.drawable.group_footer_normal);
				groupButton.setBackgroundColor(Color.parseColor("#00000000"));
			}
			break;

		case ANNOUNCE_VIEW:
			if (paramBoolean) {
				announceButton.setBackgroundResource(R.drawable.footer_selected);
				//				announceButtonImg.setBackgroundResource(R.drawable.announce_footer_pressed);
			} else {
				//				announceButtonImg.setBackgroundResource(R.drawable.announce_footer_normal);
				announceButton.setBackgroundColor(Color.parseColor("#00000000"));
			}
			break;

		case SETTING_VIEW:
			if (paramBoolean) {
				settingButton.setBackgroundResource(R.drawable.footer_selected);
				//				settingButtonImg.setBackgroundResource(R.drawable.setting_footer_pressed);
			} else {
				//				settingButtonImg.setBackgroundResource(R.drawable.setting_footer_normal);
				settingButton.setBackgroundColor(Color.parseColor("#00000000"));
			}
			break;
		default:
			break;
		}
	}

	@Override
	public void onClick(View v) {
		setOnBackVisbility(View.GONE);
		switch (v.getId()) {
		case R.id.announceButton:
			showChoosedView(ANNOUNCE_VIEW);
			showATip(false);
			break;
		case R.id.groupButton:
			showChoosedView(GROUP_VIEW);
			break;
		case R.id.msgButton:
			showChoosedView(MSG_VIEW);
			break;
		case R.id.settingButton:
			showChoosedView(SETTING_VIEW);
			break;
		default:
			break;
		}

	}

	/**
	 * 描述:选中指定View
	 * 
	 * @author linqiang(866116)
	 * @Since 2013-6-6
	 * @param paramInt
	 */
	private void showChoosedView(int paramInt) {

		Integer localInteger = Integer.valueOf(paramInt);
		CommonAppView localView = (CommonAppView) viewCache.get(localInteger);

		if (localView == null) {
			localView = createContentView(paramInt);
			viewCache.put(localInteger, localView);
		}

		onBeforeShowView(paramInt);
		setTitleContext(paramInt);

		CommonAppView currentView = getCurrentTab();
		if ((currentView == null) || (currentView != localView)) {
			currentMark = paramInt;
			contentFrame.removeAllViews();
			contentFrame.addView(localView);
			if (GROUP_VIEW == paramInt) {
				GroupAppView appView = (GroupAppView) localView;
				this.setOnBackListener(appView);
				if (appView.getCurrentView() != GroupAppView.GROUP_VIEW) {
					setOnBackVisbility(View.VISIBLE);
					appView.setTitle();
				}
			} else if (SETTING_VIEW == paramInt) {
				SettingAppView appView = (SettingAppView) localView;
				this.setOnBackListener(appView);
				appView.setTitle();
				appView.refreshUser();
			} else if (ANNOUNCE_VIEW == paramInt) {
				AnnounceAppView appView = (AnnounceAppView) localView;
				this.setOnBackListener(appView);
				if (appView.getCurrentView() != AnnounceAppView.MAIN_VIEW) {
					setOnBackVisbility(View.VISIBLE);
				}
			}
		}
	}

	public CommonAppView getCurrentTab() {
		CommonAppView localView = null;
		if (contentFrame != null && contentFrame.getChildCount() > 0) {
			Object objLocalView = contentFrame.getChildAt(0);

			if (objLocalView instanceof CommonAppView)
				localView = (CommonAppView) objLocalView;
		}
		return localView;
	}

	private CommonAppView createContentView(int paramInt) {

		CommonAppView localObject = null;

		switch (paramInt) {
		case GROUP_VIEW:
			localObject = new GroupAppView(this);
			break;

		case MSG_VIEW:
			localObject = new MsgAppView(this);
			break;
		case ANNOUNCE_VIEW:
			localObject = new AnnounceAppView(this);
			break;

		case SETTING_VIEW:
			localObject = new SettingAppView(this);
			break;

		default:
			localObject = new LoadFailedAppView(mContext);
			break;
		}

		return localObject;

	}

	/**
	 * Tab切换变更标题
	 * 
	 * @param paramInt
	 */
	public void setTitleContext(int paramInt) {
		switch (paramInt) {
		case MSG_VIEW:
			this.titleContext.setText(R.string.msg);
			break;

		case GROUP_VIEW:
			this.titleContext.setText(R.string.group);
			break;

		case ANNOUNCE_VIEW:
			this.titleContext.setText(R.string.announce);
			break;

		case SETTING_VIEW:
			this.titleContext.setText(R.string.setting);
			break;

		default:
			break;
		}
	}

	public void setTitleContext(String title) {
		this.titleContext.setText(title);
	}

	private void onBeforeShowView(int paramInt) {
		setTabSelected(currentMark, false);
		setTabSelected(paramInt, true);
	}

	private View $(int resId) {
		return findViewById(resId);
	}

	private String $Str(int resId) {
		return getString(resId);
	}

	private Handler mHander = new Handler() {
		public void handleMessage(Message msg) {
			if (dailog != null && dailog.isShowing()) {
				dailog.dismiss();
			}
			switch (msg.what) {
			case GlobalContants.SUCCESS:
				firstLoadSuccess.set(true);
				JPushInterface.init(mContext); // 初始化 JPush
				JPushInterface.setAliasAndTags(getApplicationContext(), null, tagSet);
//				showChoosedView(MSG_VIEW);
				showATip(hasNewAnnounce);
				break;
			case NETWORK_BROKEN:
				firstLoadSuccess.set(true);
				JPushInterface.init(mContext); // 初始化 JPush
				JPushInterface.setAliasAndTags(getApplicationContext(), null, tagSet);
//				showChoosedView(MSG_VIEW);
				setLoadTip("当前网络异常,请检查你的网络!");
				Toast.makeText(mContext, "当前网络异常,请检查你的网络!", Toast.LENGTH_SHORT).show();
				break;
			case GlobalContants.FAIL:
				firstLoadSuccess.set(false);
				showChoosedView(FAILED_VIEW);
				setLoadTip($Str(R.string.data_load_fail));
				Toast.makeText(mContext, R.string.data_load_fail, Toast.LENGTH_SHORT).show();
				break;
			case UPLOAD_HEAD_FAIL:
				imageName = "";
				Toast.makeText(mContext, "修改头像失败!", Toast.LENGTH_SHORT).show();
				break;
			case UPLOAD_HEAD_SUCCESS:
				Result ps = (Result) msg.obj;
				msg.obj = ps;
				if (ps.success) {
					SettingAppView currentView = (SettingAppView) getCurrentTab();
					Global.getMe().getGlobalUser().pic = "file://" + GlobalContants.BASE_DIR + Global.getMe().getGlobalUser().pic;
					Global.getMe().getGlobalUser().thumb = "file://" + GlobalContants.BASE_DIR + Global.getMe().getGlobalUser().thumb;
					ConfigSharePref.getInstance(mContext).setByArgkey(ConfigSharePref.CONST_KEY_USER_PIC, Global.getMe().getGlobalUser().pic);
					ConfigSharePref.getInstance(mContext).setByArgkey(ConfigSharePref.CONST_KEY_USER_THUMB, Global.getMe().getGlobalUser().thumb);
					currentView.refreshHead();
					Toast.makeText(mContext, "修改头像成功!", Toast.LENGTH_SHORT).show();
				} else {
					Toast.makeText(mContext, "修改头像失败!", Toast.LENGTH_SHORT).show();
				}
				imageName = "";
				break;
			case LOGIN_OUT:

				break;
			case LOCAL_LOAD_SUCCESS:
				showChoosedView(MSG_VIEW);
				UtilThread.executeMore(new Runnable() {
					@Override
					public void run() {
						loadNet();
					}
				});
				break;
			case GlobalContants.INVALID:
				exit("大业堂提示", "你的账号已失效,\n点击[确定]退出重新登录");
				break;
			default:
				break;
			}
		};
	};

	public void setOnBackListener(OnClickListener listener) {
		this.backBtn.setOnClickListener(listener);
	}

	public void setOnBackVisbility(int visbility) {
		this.backBtn.setVisibility(visbility);
	}

	@Override
	public void onCreateContextMenu(ContextMenu menu, View v, ContextMenu.ContextMenuInfo menuInfo) {
		menu.add(0, 1, 1, "拍照");
		menu.add(0, 2, 2, "相册");
		super.onCreateContextMenu(menu, v, menuInfo);
	}

	@Override
	public boolean onContextItemSelected(MenuItem item) {
		Intent intent;
		if (item.getItemId() == 1) {
			intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
			imageName = System.currentTimeMillis() + ".jpg";
			// 下面这句指定调用相机拍照后的照片存储的路径
			intent.putExtra(MediaStore.EXTRA_OUTPUT, Uri.fromFile(new File(GlobalContants.BASE_DIR, imageName)));
			startActivityForResult(intent, 1);
		} else if (item.getItemId() == 2) {
			intent = new Intent(Intent.ACTION_PICK, null);
			intent.setDataAndType(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, "image/*");
			startActivityForResult(intent, 2);
		}
		return true;
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		switch (requestCode) {
		case 1:
			if (resultCode == RESULT_OK) {
				imageName = GlobalContants.BASE_DIR + imageName;
			}
			break;
		case 2:
			if (data != null) {
				imageName = getAbsoluteImagePath(data.getData());
			}
			break;
		default:
			break;
		}
		if (!UtilString.isEmpty(imageName) && resultCode == RESULT_OK) {
			dailog.setMessage("上传头像中...");
			dailog.show();
			UtilThread.executeMore(new Runnable() {
				@Override
				public void run() {
					String url = GlobalContants.UPDATE_MEMBER_PIC;
					upload(url, imageName);
				}
			});
		}
	}

	private String getAbsoluteImagePath(Uri uri) {
		String[] proj = { MediaStore.Images.Media.DATA };
		Cursor cursor = this.getContentResolver().query(uri, proj, null, null, null);
		try {
			int column_index = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
			cursor.moveToFirst();
			return cursor.getString(column_index);
		} finally {
			if (cursor != null) {
				cursor.close();
			}
		}
	}

	public void showSelectHeadDialog() {
		if (t == null) {
			t = new TextView(this);
			t.setVisibility(View.GONE);
			announceButton.addView(t);
			registerForContextMenu(t);
		}
		t.showContextMenu();
	}

	// 上传
	private void upload(String strUrl, String loaclPath) {
		// 将图片流以字符串形式存储下来
		MultipartPostMethod filePost = new MultipartPostMethod(strUrl);
		filePost.setRequestHeader("Charset", "UTF-8");
		filePost.addParameter("userid", String.valueOf(Global.getMe().getGlobalUser().id));
		filePost.addParameter("encodeStr", Global.getMe().getEncodeStr());
		try {
			filePost.addParameter("pic", new File(loaclPath));
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}
		HttpClient clients = new HttpClient();
		Message msg = new Message();
		msg.what = UPLOAD_HEAD_FAIL;
		try {
			clients.executeMethod(filePost);
			BufferedReader rd = new BufferedReader(new InputStreamReader(filePost.getResponseBodyAsStream(), "UTF-8"));
			StringBuffer stringBuffer = new StringBuffer();
			String line;
			while ((line = rd.readLine()) != null) {
				stringBuffer.append(line);
			}
			rd.close();
			Gson gson = new Gson();
			Result ps = gson.fromJson(stringBuffer.toString(), Result.class);
			//账号失效
			if (ps.returnCode == AbstractResult.RETURN_CODE_INVALID) {
				mHander.sendEmptyMessage(GlobalContants.INVALID);
				return;
			}
			if (ps.success) {
				String name = loaclPath.substring(loaclPath.lastIndexOf("/") + 1);
				String ext = name.substring(name.lastIndexOf(".") + 1);
				CompressFormat format = null;
				if ("png".equals(ext)) {
					format = Bitmap.CompressFormat.PNG;
				} else {
					format = Bitmap.CompressFormat.JPEG;
				}
				Global.getMe().getGlobalUser().pic = "images/user/" + name;
				Global.getMe().getGlobalUser().thumb = "images/user/" + name;
				UtilBitmap.saveBitmap2file(Bitmap.createScaledBitmap(BitmapFactory.decodeFile(loaclPath), 80, 80, true), GlobalContants.BASE_DIR
						+ Global.getMe().getGlobalUser().pic, format);
			}
			msg.what = UPLOAD_HEAD_SUCCESS;
			msg.obj = ps;
			mHander.sendMessage(msg);
		} catch (Exception e) {
			e.printStackTrace();
			mHander.sendMessage(msg);
		}
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK) {

			if (this.backBtn.getVisibility() == View.VISIBLE) {
				this.backBtn.performClick();
			} else {
				if ((System.currentTimeMillis() - mExitTime) > 2000) {
					Toast.makeText(this, "再按一次退出程序", Toast.LENGTH_SHORT).show();
					mExitTime = System.currentTimeMillis();
				} else {
					finish();
				}

			}
			return true;
		}
		return super.onKeyDown(keyCode, event);
	}

	public void showSoftInput(View view) {
		InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
		imm.showSoftInput(view, InputMethodManager.SHOW_FORCED);
	}

	public void showTip(int count) {
		if (count > 0) {
			badge.setText("" + count);
			badge.show();
		} else {
			badge.hide();
		}
	}
	
	
	public void showATip(boolean show) {
		if (show) {
			aBadge.show();
		} else {
			aBadge.hide();
		}
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();

		for (int i = 0; i < viewCache.size(); i++) {
			CommonAppView view = viewCache.get(i);
			if (view != null) {
				view.finish();
			}
		}
		Global.getMe().setEncodeStr("");
		UtilBitmap.clearAll();
		ImageLoader.getInstance().clearMemoryCache();
		Global.getMe().clearAll();
		Global.isOpen = false;
		Global.isLogin = false;
		if (returnLogin) {
			startActivity(new Intent(mContext, ActivityLogin.class));
		}
	}

	public void closeSofeKey(View view) {
		imm.hideSoftInputFromWindow(view.getWindowToken(), 0);
	}

	/**
	 * 
	 * 方法描述:退出
	 * 
	 * @Author:solotiger
	 * @Date:2013-6-30
	 * @return:void
	 * @param title
	 * @param content
	 */
	public void exit(String title, String content) {
		Intent i = new Intent(mContext, ActivityExit.class);
		i.putExtra("title", title);
		i.putExtra("content", content);
		startActivity(i);
	}

	/**
	 * 方法描述:返回
	 * 
	 * @Author:solotiger
	 * @Date:2013-6-30
	 * @return:void
	 */
	public void returnLogin() {
		finish();
		returnLogin = true;
	}

	public void hideLoadTip(){
		$(R.id.layout_new_event).setVisibility(View.GONE);
	}
	
	public void setLoadTip(String str){
		((TextView)$(R.id.new_event_text)).setText(str);
	}
}
