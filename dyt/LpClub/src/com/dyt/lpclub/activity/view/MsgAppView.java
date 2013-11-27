package com.dyt.lpclub.activity.view;

import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.database.Cursor;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.AttributeSet;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.AdapterView.OnItemLongClickListener;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.Toast;
import cn.jpush.android.api.JPushInterface;

import com.dyt.lpclub.R;
import com.dyt.lpclub.activity.ActivityMain;
import com.dyt.lpclub.activity.ActivityTalk;
import com.dyt.lpclub.activity.adapter.MsgAdapter;
import com.dyt.lpclub.activity.domain.Group;
import com.dyt.lpclub.activity.domain.Msg;
import com.dyt.lpclub.activity.domain.NewMsg;
import com.dyt.lpclub.activity.domain.ReturnChatMsg;
import com.dyt.lpclub.activity.domain.db.Dao;
import com.dyt.lpclub.activity.domain.db.LpClubDB;
import com.dyt.lpclub.activity.domain.db.NewMsgTable;
import com.dyt.lpclub.activity.domain.db.TalkContentTable;
import com.dyt.lpclub.activity.domain.result.AbstractResult;
import com.dyt.lpclub.activity.domain.result.GetNewMsgResult;
import com.dyt.lpclub.global.ConfigSharePref;
import com.dyt.lpclub.global.Global;
import com.dyt.lpclub.global.GlobalContants;
import com.dyt.lpclub.util.UtilHttp;
import com.dyt.lpclub.util.UtilString;
import com.dyt.lpclub.util.UtilTelephone;
import com.dyt.lpclub.util.UtilThread;
import com.google.gson.Gson;

/**
 * 描述:消息界面
 * 
 * @author linqiang(866116)
 * @Since 2013-6-6
 */
public class MsgAppView extends CommonAppView implements OnItemClickListener, OnItemLongClickListener {

	private ActivityMain mContext;
	private MsgAdapter mAdapter;
	private ListView listView;
	private ProgressDialog dialog;
	private List<NewMsg> ps;
	private List<Msg> list;
	private ImageView serachBtn;
	private EditText serachText;
	private MainReceiver mReceiver;
	private boolean isLoading;
	private int count;
	private Map<Integer, NewMsg> maps;
	public static int currentGroup = -1;
	private String time = "";
	private List<String> newmsgList;
	public MsgAppView(Context paramContext) {
		super(paramContext);
		mContext = (ActivityMain) paramContext;
		init();
	}

	public MsgAppView(Context paramContext, AttributeSet paramAttributeSet) {
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
		addView(R.layout.layout_msg);
		dialog = new ProgressDialog(mContext);
		listView = (ListView) findViewById(R.id.groupList);
		serachBtn = (ImageView) findViewById(R.id.serachBtn);
		serachText = (EditText) findViewById(R.id.serachText);
		serachBtn.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				mAdapter.getFilter().filter(serachText.getText());
			}
		});

		serachText.addTextChangedListener(new TextWatcher() {
			@Override
			public void onTextChanged(CharSequence s, int start, int before, int count) {
				mAdapter.getFilter().filter(s);
			}

			@Override
			public void beforeTextChanged(CharSequence s, int start, int count, int after) {

			}

			@Override
			public void afterTextChanged(Editable s) {

			}
		});
		ps = new ArrayList<NewMsg>();
		Collections.synchronizedList(ps);
		newmsgList = new ArrayList<String>();
		Collections.synchronizedList(newmsgList);
		maps = new HashMap<Integer, NewMsg>();
		list = new ArrayList<Msg>();
		isLoading = true;
		if (mReceiver == null)
			mReceiver = new MainReceiver();
		IntentFilter filter = new IntentFilter();
		filter.addAction("cn.jpush.android.intent.REGISTRATION");
		filter.addAction("cn.jpush.android.intent.UNREGISTRATION");
		filter.addAction("cn.jpush.android.intent.MESSAGE_RECEIVED");
		filter.addAction("cn.jpush.android.intent.NOTIFICATION_RECEIVED");
		filter.addAction("cn.jpush.android.intent.NOTIFICATION_OPENED");
		filter.addCategory("com.dyt.lpclub");
		mContext.registerReceiver(mReceiver, filter);

		listView.setOnItemLongClickListener(this);
		listView.setOnItemClickListener(this);
		
		dialog.setMessage($Str(R.string.data_loading));
		dialog.show();
		UtilThread.executeMore(new Runnable() {
			@Override
			public void run() {
				loadLocal();
			}
		});
	}

	private void getData() {
		UtilThread.executeMore(new Runnable() {
			@Override
			public void run() {
				LpClubDB dbTalkContet = null;
				if (!UtilTelephone.isNetworkAvailable(mContext)) {
					mHander.sendEmptyMessage(GlobalContants.NETWORK_FAIL);
				} else {
					String url = GlobalContants.GET_MSG_LIST;
					try {
						dbTalkContet = new LpClubDB(mContext);
						//取网络 
						SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss SSS");
						if (UtilString.isEmpty(time)) {
							time = format.format(new Date(System.currentTimeMillis() - 24 * 3600 * 7 * 1000));
						}
						url += "&userid=" + Global.getMe().getGlobalUser().id;
						url += "&querytime=" + URLEncoder.encode(time);
						url += "&encodeStr=" + Global.getMe().getEncodeStr();
						UtilHttp http = new UtilHttp(url, "UTF-8");
						String result = http.getResponseAsStringPost(new HashMap<String, String>());
						if (result != null) {
							Gson gson = new Gson();
							AbstractResult areturnReuslt = gson.fromJson(result, AbstractResult.class);
							//账号失效
							if (areturnReuslt.returnCode == AbstractResult.RETURN_CODE_INVALID) {
								mHander.sendEmptyMessage(GlobalContants.INVALID);
								return;
							}
							GetNewMsgResult newMsgResult = gson.fromJson(result, GetNewMsgResult.class);
							if (newMsgResult.obj == null || newMsgResult.obj.size() == 0) {
								mHander.sendEmptyMessage(GlobalContants.SUCCESS);
								return;
							} else {
								List<NewMsg> onlinePs = newMsgResult.obj;
								for (int i = 0; i < onlinePs.size(); i++) {
									NewMsg newMsg = onlinePs.get(i);
									newMsg.count = newMsg.msgs.size();
									count += newMsg.count;
									for (int j = 0; j < newMsg.msgs.size(); j++) {
										Msg msg = newMsg.msgs.get(j);
										msg.localId = "userid_" + Global.userid + "_" + msg.id;
										msg.newmsgid = newMsg.id;
										msg.newMsgPos = i;
										if(GlobalContants.CONST_INT_MES_TYPE_SOUND == msg.type){
											final String fileName = msg.content.substring(msg.content.lastIndexOf("/")+1);
											String downUrl = GlobalContants.CONST_STR_BASE_URL + msg.content;
											UtilHttp.downloadFile(downUrl, GlobalContants.CONST_VIDEO_CACHE_IMG,  fileName, null);
										}
										dbTalkContet.execSQL(TalkContentTable.CONST_INSERT, new String[] { "userid_" + Global.userid + "_" + msg.id,
												msg.content, msg.userid + "", msg.group_id + "", msg.type + "",msg.TIME + " " +msg.send_time_milli, msg.state, msg.thumb,
												msg.newMsgPos + "", msg.soundTime, "" + msg.soundLocal, msg.newmsgid + "", Global.userid + "" });
									}
									Msg msg = newMsg.msgs.get(newMsg.msgs.size() - 1);
									newMsg.TIME = msg.TIME + " " +msg.send_time_milli;
									newMsg.content = msg.content;
									newMsg.msgType = msg.type;
									newMsg.userId = msg.userid;
									//如果存在,就更新已有的数据
									if (newmsgList.contains(String.valueOf(newMsg.id))) {
										ps.remove(maps.get(newMsg.id));
									} else {
										//不存在就擦入数据库
										Cursor c1 = dbTalkContet.query(NewMsgTable.NEW_MSG_COUNT_SELECT,
												new String[] { String.valueOf(newMsg.id), String.valueOf(Global.userid) });
										if (!c1.moveToNext()) {
											dbTalkContet.beginTransaction();
											dbTalkContet.execSQL(NewMsgTable.NEW_MSG_COUNT_INSERT,
													new String[] { String.valueOf(newMsg.id), String.valueOf(Global.userid) });
											dbTalkContet.endTransaction();
										}
									}
									ps.add(newMsg);
									maps.put(newMsg.id, newMsg);
								}
							}
							mHander.sendEmptyMessage(GlobalContants.SUCCESS);
						} else {
							mHander.sendEmptyMessage(GlobalContants.FAIL);
						}
					} catch (Exception e) {
						mHander.sendEmptyMessage(GlobalContants.FAIL);
						e.printStackTrace();
					} finally {
						if (null != dbTalkContet) {
							dbTalkContet.close();
						}
					}
				}
			}
		});
	}

	
	private void loadLocal(){
		LpClubDB dbTalkContet = null;
		try {
			dbTalkContet = new LpClubDB(mContext);
			//取出本地的newmsg
			Cursor c = dbTalkContet.query(NewMsgTable.NEW_MSG_COUNT_SELECT_ALL, new String[] { String.valueOf(Global.getMe().getGlobalUser().id) });
			while (c.moveToNext()) {
				newmsgList.add(c.getString(c.getColumnIndex("new_msg_id")));
			}
			c.close();
			if (newmsgList.size() > 0) {
				Dao dao = new Dao();
				for (String newmsgid : newmsgList) {
					Msg msg = dao.getMsgByNewMsgId(dbTalkContet, newmsgid);
					Group group = Global.getMe().getGroupList().get(msg.group_id);
					if (group != null) {
						NewMsg newMsg = new NewMsg();
						Group parentGroup = Global.getMe().getGroupList().get(group.getParent());
						newMsg.id = Integer.parseInt(newmsgid);
						newMsg.name = group.getName();
						newMsg.state = true;
						newMsg.pic = group.getPic();
						newMsg.parent = parentGroup.getId();
						newMsg.mainGroupId = parentGroup.getId();
						newMsg.mainGroupName = parentGroup.getName();
						newMsg.mainGroupPic = parentGroup.getPic();
						newMsg.TIME = msg.TIME;
						if (time.compareTo(msg.TIME) < 0) {
							time = msg.TIME;
						}
						newMsg.content = msg.content;
						newMsg.msgType = msg.type;
						newMsg.userId = msg.userid;
						ps.add(newMsg);
						maps.put(newMsg.id, newMsg);
					}
				}
			}
			mHander.sendEmptyMessage(888);
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (null != dbTalkContet) {
				dbTalkContet.close();
			}
		}
	}
	
	@Override
	public void onItemClick(AdapterView<?> adapterView, View view, int position, long id) {
		NewMsg msg = ps.get(position);
		count -= msg.count;
		mContext.showTip(count);
		msg.count = 0;
		currentGroup = msg.id;
		mAdapter.notifyDataSetChanged();
		Intent intent = new Intent(mContext, ActivityTalk.class);
		intent.putExtra("group_id", ps.get(position).id);
		intent.putExtra("parentId", ps.get(position).parent);
		intent.putExtra("groupName", ps.get(position).name);
		mContext.startActivity(intent);
	}

	private String $Str(int resId) {
		return mContext.getString(resId);
	}

	private Handler mHander = new Handler() {

		public void handleMessage(Message msg) {
			if (dialog != null && dialog.isShowing()) {
				dialog.dismiss();
			}
			switch (msg.what) {
			case GlobalContants.SUCCESS:
				isLoading = false;
				SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss SSS");
				ConfigSharePref.getInstance(mContext).setByArgkey(ConfigSharePref.CONST_KEY_LONGOUT_TIME + Global.userid, format.format(new Date()));
				if (!list.isEmpty()) {
					count += list.size();
					for (Msg m : list) {
						createNewMsg(m);
					}
					list.clear();
				}
				mContext.showTip(count);
				mContext.hideLoadTip();
				Collections.sort(ps);
				mAdapter = new MsgAdapter(mContext, ps);
				listView.setAdapter(mAdapter);
				Intent intent = new Intent("com.dyt.reload.messages");
				mContext.sendBroadcast(intent);
				break;
			case GlobalContants.FAIL:
				Collections.sort(ps);
				mAdapter = new MsgAdapter(mContext, ps);
				listView.setAdapter(mAdapter);
				mContext.setLoadTip($Str(R.string.data_load_fail));
				Toast.makeText(mContext, R.string.data_load_fail, Toast.LENGTH_SHORT).show();
				break;
			case GlobalContants.NETWORK_FAIL:
				Collections.sort(ps);
				mAdapter = new MsgAdapter(mContext, ps);
				listView.setAdapter(mAdapter);
				mContext.setLoadTip("当前网络异常,请检查你的网络!");
				Toast.makeText(mContext, "当前网络异常,请检查你的网络!", Toast.LENGTH_SHORT).show();
				break;
			case GlobalContants.INVALID:
				mContext.exit("大业堂提示", "你的账号已失效,\n点击[确定]退出重新登录");
				break;
			case 555:
				int i = (Integer) msg.obj;
				if (count > i) {
					count -= i;
					mContext.showTip(count);
				}
				mAdapter.setNewPs(ps);
				mAdapter.notifyDataSetChanged();
				break;
			case 888:
				Collections.sort(ps);
				mAdapter = new MsgAdapter(mContext, ps);
				listView.setAdapter(mAdapter);
				getData();
				break;
			default:
				break;
			}
		};
	};

	@Override
	public boolean onItemLongClick(AdapterView<?> adapterView, View view, final int position, long id) {
		final CharSequence[] items = { "删除消息" };
		AlertDialog.Builder builder = new AlertDialog.Builder(mContext);
		builder.setTitle("大业堂");
		builder.setItems(items, new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface d, int item) {
				dialog.setMessage("数据删除中...");
				dialog.show();
				UtilThread.executeMore(new Runnable() {
					@Override
					public void run() {
						NewMsg newMsg = ps.get(position);
						LpClubDB db = new LpClubDB(mContext);
						Dao dao = new Dao();
						dao.deleteNewMsgFormId(db, newMsg.id);
						db.close();
						ps.remove(position);
						maps.remove(newMsg.id);
						Message msg = new Message();
						msg.obj = newMsg.count;
						msg.what = 555;
						mHander.sendMessage(msg);
					}
				});
			}
		});
		builder.create().show();
		return false;
	}

	public class MainReceiver extends BroadcastReceiver {

		public MainReceiver() {
		}

		@Override
		public void onReceive(final Context context, Intent intent) {
			Bundle bundle = intent.getExtras();
			if (JPushInterface.ACTION_MESSAGE_RECEIVED.equals(intent.getAction())) {
				String result = bundle.getString(JPushInterface.EXTRA_MESSAGE);
				Gson gs = new Gson();
				if (null != result) {
					ReturnChatMsg rcm = gs.fromJson(result, ReturnChatMsg.class);
					if (rcm != null && rcm.obj != null) {
						final Msg msg = new Msg();
						msg.id = rcm.obj.id;
						msg.localId = "userid_"+Global.userid+"_" + msg.id;
						msg.group_id = rcm.obj.group_id;
						msg.userid = rcm.obj.userid;
						msg.type = rcm.obj.type;
						msg.TIME = rcm.obj.TIME + " " + rcm.obj.send_time_milli;
						msg.content = rcm.obj.content;
						msg.thumb = rcm.obj.thumb;
						msg.state = rcm.obj.state;
						msg.newmsgid = msg.group_id;
						if (!Global.isTalkOpen){
							final String fileName = msg.content.substring(msg.content.lastIndexOf("/")+1);
							UtilThread.executeMore(new Runnable() {
								@Override
								public void run() {
									if(GlobalContants.CONST_INT_MES_TYPE_SOUND == msg.type){
										String url = GlobalContants.CONST_STR_BASE_URL + msg.content;
										UtilHttp.downloadFile(url, GlobalContants.CONST_VIDEO_CACHE_IMG,  fileName, null);
									}

									LpClubDB db = null;
									try{
										db = new LpClubDB(context);
										db.beginTransaction();
										db.execSQL(TalkContentTable.CONST_INSERT, new String[] { "userid_"+Global.userid+"_" + msg.id, msg.content, msg.userid + "", msg.group_id + "", msg.type + "", msg.TIME, msg.state,
												msg.thumb, msg.newMsgPos + "", msg.soundTime, "" + msg.soundLocal, msg.newmsgid + "", Global.userid + "" });
										db.endTransaction();
									}catch (Exception e) {
										e.printStackTrace();
									}finally{
										if(null != db){
											db.close();
										}
									}
								
								}
							});
						}
						createNewMsg(msg);
						if (isLoading) {
							list.add(msg);
						} else {
							mContext.showTip(count);
							Collections.sort(ps);
							mAdapter.setNewPs(ps);
							mAdapter.notifyDataSetChanged();
							//							mAdapter.getFilter().filter("1");
							//							mAdapter.getFilter().filter("");
						}
					}
				}
			}
		}
	}

	private void createNewMsg(Msg msg) {
		NewMsg newmsg = maps.get(msg.group_id);
		if (newmsg == null) {
			newmsg = new NewMsg();
			newmsg.id = msg.group_id;
			Group group = Global.getMe().getGroupList().get(msg.group_id);
			Group parentGroup = Global.getMe().getGroupList().get(group.getParent());
			newmsg.name = group.getName();
			newmsg.state = true;
			newmsg.pic = group.getPic();
			newmsg.parent = parentGroup.getId();
			newmsg.memberCount = group.getMemberCount();
			newmsg.mainGroupId = parentGroup.getId();
			newmsg.mainGroupName = parentGroup.getName();
			newmsg.mainGroupPic = parentGroup.getPic();
			newmsg.userId = msg.userid;
			newmsg.TIME = msg.TIME;
			newmsg.content = msg.content;
			newmsg.msgType = msg.type;
			if ((currentGroup != newmsg.id) && (msg.userid != Global.userid)) {
				count++;
				newmsg.count += 1;
			}
			maps.put(newmsg.id, newmsg);
			ps.add(newmsg);
			final int newmsgid = newmsg.id;
			UtilThread.executeMore(new Runnable() {
				@Override
				public void run() {
					LpClubDB db = new LpClubDB(mContext);
					Cursor c = db.query(NewMsgTable.NEW_MSG_COUNT_SELECT, new String[] { String.valueOf(newmsgid), String.valueOf(Global.userid) });
					if (!c.moveToNext()) {
						db.beginTransaction();
						db.execSQL(NewMsgTable.NEW_MSG_COUNT_INSERT, new String[] { String.valueOf(newmsgid), String.valueOf(Global.userid) });
						db.endTransaction();
					}
					db.close();
				}
			});
		} else {
			if ((currentGroup != newmsg.id) && (msg.userid != Global.userid)) {
				count++;
				newmsg.count += 1;
			}
			newmsg.userId = msg.userid;
			newmsg.TIME = msg.TIME;
			newmsg.content = msg.content;
			newmsg.msgType = msg.type;
		}
	}

	@Override
	public void finish() {
		super.finish();
		if (mReceiver != null)
			mContext.unregisterReceiver(mReceiver);
	}
}
