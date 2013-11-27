package com.dyt.lpclub.activity;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.InputStreamReader;
import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.methods.MultipartPostMethod;

import android.app.Activity;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.provider.MediaStore;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.style.ImageSpan;
import android.view.ContextMenu;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.view.ViewGroup.LayoutParams;
import android.view.WindowManager;
import android.widget.AbsListView;
import android.widget.AbsListView.OnScrollListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.SimpleAdapter;
import android.widget.TextView;
import android.widget.Toast;
import cn.jpush.android.api.JPushInterface;

import com.dyt.lpclub.R;
import com.dyt.lpclub.activity.adapter.ChatMsgViewAdapter;
import com.dyt.lpclub.activity.domain.BeanEvent;
import com.dyt.lpclub.activity.domain.FaceImgMETA;
import com.dyt.lpclub.activity.domain.Msg;
import com.dyt.lpclub.activity.domain.ReturnChatMsg;
import com.dyt.lpclub.activity.domain.db.Dao;
import com.dyt.lpclub.activity.domain.db.LpClubDB;
import com.dyt.lpclub.activity.domain.db.TalkContentTable;
import com.dyt.lpclub.activity.domain.result.AbstractResult;
import com.dyt.lpclub.activity.domain.result.ResultEvent;
import com.dyt.lpclub.activity.domain.result.SendTextMsgResult;
import com.dyt.lpclub.activity.view.MsgAppView;
import com.dyt.lpclub.global.ConfigSharePref;
import com.dyt.lpclub.global.Global;
import com.dyt.lpclub.global.GlobalContants;
import com.dyt.lpclub.util.UtilHttp;
import com.dyt.lpclub.util.UtilScreen;
import com.dyt.lpclub.util.UtilSoundMeter;
import com.dyt.lpclub.util.UtilString;
import com.dyt.lpclub.util.UtilSystem;
import com.dyt.lpclub.util.UtilThread;
import com.dyt.lpclub.util.ViewUtil;
import com.google.gson.Gson;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.assist.PauseOnScrollListener;

/**
 * @ProjectName LpClub
 * @Author C.xt
 * @Version 1.0.0
 * @CreateDate： 2013-6-4 下午8:24:53
 * @JDK <JDK1.6> Description: 聊天Activity
 */
public class ActivityTalk extends Activity implements OnClickListener, OnScrollListener {

	private Button mBtnSend, mBtnSendImage, mBtnSendFace,btn_makephoto,btn_album;
	private TextView mBtnRcd;
	private Button mBtnBack;
	private EditText mEditTextContent;
	private RelativeLayout mBottom;
	private ListView mListView;
	private ChatMsgViewAdapter mAdapter;
	//	private List<ChatMsgEntity> mDataArrays = new ArrayList<ChatMsgEntity>();
	private boolean isShosrt = false;
	private LinearLayout voice_rcd_hint_loading, voice_rcd_hint_rcding, voice_rcd_hint_tooshort,layout_popup;
	private ImageView sc_img1;
	private UtilSoundMeter mSensor;
	private View rcChat_popup;
	private LinearLayout del_re;
	private LinearLayout layout_voice_hint;
	private ImageView chatting_mode_btn, volume;
	private boolean btn_vocie = false;
	private int flag = 1;
	private String voiceName;
	private String imageName;
	private long startVoiceT, endVoiceT;
	private int group_id, parentid;
	private List<Msg> messages;
	//	private List<Msg> msg2Adapter;
//	private CopyOnWriteArrayList<Msg> msg2Adapter;
	private Context mContext;
	private MyReceiver mReceiver;

	private ProgressDialog dialog;

	private Dialog builder;

	private int[] faceImageIds;
	
	private boolean isFirstLoadData = true;

	private RelativeLayout layoutNewEvent;

	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		ViewUtil.fullscreen(this);
		setContentView(R.layout.chat);
		dialog = new ProgressDialog(this);
		mContext = this;
		group_id = getIntent().getIntExtra("group_id", 1);
		parentid = getIntent().getIntExtra("parentId", 1);
		String groupName = getIntent().getStringExtra("groupName");

		
		TextView title = (TextView) findViewById(R.id.talk_usergroup_name);
		title.setText(groupName);
		/**
		 * 启动activity时不自动弹出软键盘
		 */
		getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);
		Global.isTalkOpen = true;
		initView();
		
		messages = new ArrayList<Msg>();
		Collections.synchronizedList(messages);
		mAdapter = new ChatMsgViewAdapter(mContext, messages, mHandler ,group_id);
		mListView.setAdapter(mAdapter);
		mListView.setVisibility(View.GONE);
		
		resetListView();

		if (mReceiver == null)
			mReceiver = new MyReceiver();
		IntentFilter filter = new IntentFilter();
		filter.addAction("cn.jpush.android.intent.REGISTRATION");
		filter.addAction("cn.jpush.android.intent.UNREGISTRATION");
		filter.addAction("cn.jpush.android.intent.MESSAGE_RECEIVED");
		filter.addAction("cn.jpush.android.intent.NOTIFICATION_RECEIVED");
		filter.addAction("cn.jpush.android.intent.NOTIFICATION_OPENED");
		filter.addAction("com.dyt.reload.messages");
		filter.addCategory("com.dyt.lpclub");
		registerReceiver(mReceiver, filter);

		ifNewEvent();
		
		layoutNewEvent = (RelativeLayout) findViewById(R.id.layout_new_event);
		layoutNewEvent.getBackground().setAlpha(140);
		
		findViewById(R.id.new_event_close).setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				if(layoutNewEvent.getVisibility() == View.VISIBLE){
					layoutNewEvent.setVisibility(View.GONE);
				}
			}
		});
		/*
		 * UtilThread.executeMore(new Runnable() {
		 * 
		 * @Override public void run() { DBTalkContet dbTalkContet = new
		 * DBTalkContet(ActivityTalk.this); dbTalkContet.beginTransaction(); try
		 * { for (int i = 0, len = messages.size(); i < len; i++) {
		 * dbTalkContet.execSQL(DBTalkContet.CONST_INSERT,
		 * messages.get(i).toString().split("@")); }
		 * dbTalkContet.endTransaction(); } catch (Exception e) {
		 * e.printStackTrace(); } finally { if (null != dbTalkContet) {
		 * dbTalkContet.close(); } } } });
		 */
	}
	
	private void ifNewEvent(){
		UtilThread.executeMore(new Runnable() {
			@Override
			public void run() {
				
				long timeOld = 0;
				String groupEventTime = ConfigSharePref.getInstance(ActivityTalk.this).getByArgkey(ConfigSharePref.CONST_KEY_LATESTEVENT_TIME + group_id);
				if(!UtilString.isEmpty(groupEventTime) ){
					timeOld = Long.parseLong(groupEventTime);
				}

				BeanEvent event;
				String url = GlobalContants.CONST_GROUP_EVENT_MSGS;
				url += "&groupid=" + group_id;
				url += "&encodeStr=" + Global.getMe().getEncodeStr();
				UtilHttp http = new UtilHttp(url, "UTF-8");
				String	result = http
							.getResponseAsStringGET(new HashMap<String, String>());
					if (result != null) {
						try {
							Gson gson = new Gson();
							ResultEvent rsEvent  = gson.fromJson(
									result, ResultEvent.class);
							event = rsEvent.obj;
							
							
						if (null == event.event_address
								&& null == event.event_content
								&& null == event.event_date
								&& null == event.event_title) {
								return ;
							}
						 	Date date = null;  
					        date = new java.text.SimpleDateFormat("yyyy-MM-dd" , Locale.PRC).parse(event.event_date);  
							long timeNew = date.getTime();
							
							if(timeNew > timeOld){
								ConfigSharePref.getInstance(ActivityTalk.this).setByArgkey(ConfigSharePref.CONST_KEY_LATESTEVENT_TIME +group_id, ""+timeNew);
								mHandler.sendEmptyMessage(GlobalContants.HAVE_NEW_EVENT);
							}
						} catch (Exception e) {
							e.printStackTrace();
						}
					} else {
					}
			}
		});
	}
	public void initView() {

		mListView = (ListView) findViewById(R.id.listview);
		PauseOnScrollListener listener = new PauseOnScrollListener(ImageLoader.getInstance(), true, true);
		mListView.setOnScrollListener(listener);
		mListView.setOnScrollListener(this);
		mBtnSend = (Button) findViewById(R.id.btn_send);
		mBtnSendImage = (Button) findViewById(R.id.btn_send_image);
		registerForContextMenu(mBtnSendImage);
		mBtnRcd = (TextView) findViewById(R.id.btn_rcd);
		mBtnSend.setOnClickListener(this);
		mBtnSendFace = (Button) findViewById(R.id.btn_send_face);
		mBtnSendFace.setOnClickListener(this);
		mBtnSendImage.setOnClickListener(this);
		mBtnBack = (Button) findViewById(R.id.btn_back);
		mBottom = (RelativeLayout) findViewById(R.id.btn_bottom);
		mBtnBack.setOnClickListener(this);
		chatting_mode_btn = (ImageView) this.findViewById(R.id.ivPopUp);
		volume = (ImageView) this.findViewById(R.id.volume);
		rcChat_popup = this.findViewById(R.id.rcChat_popup);
//		img1 = (ImageView) this.findViewById(R.id.img1);
		sc_img1 = (ImageView) this.findViewById(R.id.sc_img1);
		del_re = (LinearLayout) this.findViewById(R.id.del_re);
		layout_voice_hint = (LinearLayout) this.findViewById(R.id.layout_voice_hint);
		voice_rcd_hint_rcding = (LinearLayout) this.findViewById(R.id.voice_rcd_hint_rcding);
		voice_rcd_hint_loading = (LinearLayout) this.findViewById(R.id.voice_rcd_hint_loading);
		voice_rcd_hint_tooshort = (LinearLayout) this.findViewById(R.id.voice_rcd_hint_tooshort);
		layout_popup = (LinearLayout) this.findViewById(R.id.layout_popup);
		mSensor = new UtilSoundMeter();
		mEditTextContent = (EditText) findViewById(R.id.et_sendmessage);
		mEditTextContent.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				if (null != layout_popup && layout_popup.isShown()) {
					layout_popup.setVisibility(View.GONE);
				}
			}
		});
		btn_makephoto = (Button)findViewById(R.id.btn_makephoto);
		btn_album = (Button)findViewById(R.id.btn_album);

		btn_makephoto.setOnClickListener(this);
		btn_album.setOnClickListener(this);
		
		// 语音文字切换按钮
		chatting_mode_btn.setOnClickListener(new OnClickListener() {

			public void onClick(View v) {

				if (btn_vocie) {
					mBtnRcd.setVisibility(View.GONE);
					mBottom.setVisibility(View.VISIBLE);
					btn_vocie = false;
					chatting_mode_btn.setImageResource(R.drawable.chatting_setmode_msg_btn);

				} else {
					mBtnRcd.setVisibility(View.VISIBLE);
					mBottom.setVisibility(View.GONE);
					chatting_mode_btn.setImageResource(R.drawable.chatting_setmode_keyboard_btn);
					btn_vocie = true;
				}
			}
		});
		mBtnRcd.setOnTouchListener(new OnTouchListener() {

			public boolean onTouch(View v, MotionEvent event) {
				// 按下语音录制按钮时返回false执行父类OnTouch
				return false;
			}
		});
		findViewById(R.id.right_btn).setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				Intent intent = new Intent(ActivityTalk.this, ActivityGroupDetail.class);
				intent.putExtra("group_id", group_id);
				intent.putExtra("parentId", parentid);
				intent.putExtra("fromTalk", true);
				startActivity(intent);
			}
		});
	}

	private int limit = 10;
	private final int offset = 0;
	private final int perPage = 10;
	private int count = 0;
	
	public void resetListView() {
		dialog.setMessage(this.getString(R.string.data_loading));
		dialog.show();
		UtilThread.executeMore(new Runnable() {
			@Override
			public void run() {
					LpClubDB dbTalkContet = null;
					Dao dao = null;
					try {
						dbTalkContet = new LpClubDB(mContext);
						dao = new Dao();
						count = dao.getMsgByGroupId(messages,dbTalkContet, group_id , limit, offset);
						
						if(count > 0){
							limit += perPage;
						}
						
						loadHandler.sendEmptyMessage(GlobalContants.SUCCESS);
					} catch (Exception e) {
						e.printStackTrace();
					} finally {
						if (null != dbTalkContet)
							dbTalkContet.close();
					}
			}
		});
	}

	private Handler loadHandler = new Handler() {
		public void handleMessage(Message msg) {
			if (dialog != null && dialog.isShowing()) {
				dialog.dismiss();
			}
			mListView.setVisibility(View.VISIBLE);

			switch (msg.what) {
			case GlobalContants.SUCCESS:
				mAdapter.notifyDataSetChanged();
				
				if (isFirstLoadData) {
					mListView.setSelection(messages.size() - 1);
					isFirstLoadData =false;
				} else {
					mListView.setSelection(count);
				}
				break;
			case GlobalContants.FAIL:
				Toast.makeText(mContext, R.string.data_load_fail, Toast.LENGTH_SHORT).show();
				break;
			default:
				break;
			}
		};
	};

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.btn_send:
			send();
			break;
		case R.id.btn_send_image:
//			mBtnSendImage.performLongClick();
			UtilSystem.hideKeyboard(mEditTextContent);
			layout_popup.setVisibility(View.VISIBLE);
			break;
		case R.id.btn_back:
			finish();
			break;
		case R.id.btn_send_face:
			createExpressionDialog();
			break;
		case R.id.btn_makephoto:
			Intent intent1 = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
			imageName = System.currentTimeMillis() + ".jpg";
			// 下面这句指定调用相机拍照后的照片存储的路径
			intent1.putExtra(MediaStore.EXTRA_OUTPUT, Uri.fromFile(new File(GlobalContants.BASE_DIR, imageName)));
			startActivityForResult(intent1, 1);
			break;
		case R.id.btn_album:
			Intent intent2 = new Intent(Intent.ACTION_PICK, null);
			intent2.setDataAndType(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, "image/*");
			startActivityForResult(intent2, 2);
			break;
		}
	}

	/**
	 * 
	 * 
	 * @Author C.xt
	 * @Title: createExpressionDialog
	 * @Description: 创建一个表情选择对话框
	 * @throws
	 * @date 2013-6-29下午6:06:47
	 */
	private void createExpressionDialog() {
		builder = new Dialog(ActivityTalk.this);
		GridView gridView = createGridView();
		builder.addContentView(gridView, new LayoutParams(LayoutParams.FILL_PARENT, UtilScreen.dip2px(mContext, 230)));
		builder.setTitle("默认表情");
		builder.show();
		gridView.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, int arg2, long arg3) {
				Bitmap bitmap = null;
				bitmap = BitmapFactory.decodeResource(getResources(), faceImageIds[arg2 % faceImageIds.length]);
				ImageSpan imageSpan = new ImageSpan(ActivityTalk.this, bitmap);
				String str = null;
				if (arg2 < 9) {
					str = "[" + FaceImgMETA.getFaceImgMap().get("00" + (arg2 + 1)) + "]";
				} else if (arg2 < 99) {
					str = "[" + FaceImgMETA.getFaceImgMap().get("0" + (arg2 + 1)) + "]";
				}
				SpannableString spannableString = new SpannableString(str);
				spannableString.setSpan(imageSpan, 0, str.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
				mEditTextContent.append(spannableString);
				builder.dismiss();
			}
		});
	}

	/**
	 * 
	 * 
	 * @Author C.xt
	 * @Title: createGridView
	 * @Description: 生成一个表情对话框中的gridview
	 * @return GridView
	 * @throws
	 * @date 2013-6-29下午6:06:20
	 */
	private GridView createGridView() {
		final GridView view = new GridView(this);
		List<Map<String, Object>> listItems = new ArrayList<Map<String, Object>>();
		/**
		 * 生成个表情的id，封装
		 * 
		 */
		int size = FaceImgMETA.getFaceImgMap().size();
		faceImageIds = new int[size];
		for (int i = 0; i < size; i++) {
			try {
				if (i < 9) {
					String value = FaceImgMETA.getFaceImgMap().get("00" + (i + 1));
					Field field = R.drawable.class.getDeclaredField(FaceImgMETA.getFaceImgMap().get("00" + (i + 1)).replace(" ", ""));
					int resourceId = Integer.parseInt(field.get(null).toString());
					faceImageIds[i] = resourceId;
				} else if (i < 99) {
					Field field = R.drawable.class.getDeclaredField(FaceImgMETA.getFaceImgMap().get("0" + (i + 1)).replace(" ", ""));
					int resourceId = Integer.parseInt(field.get(null).toString());
					faceImageIds[i] = resourceId;
				}
			} catch (NumberFormatException e) {
				e.printStackTrace();
			} catch (SecurityException e) {
				e.printStackTrace();
			} catch (IllegalArgumentException e) {
				e.printStackTrace();
			} catch (NoSuchFieldException e) {
				e.printStackTrace();
			} catch (IllegalAccessException e) {
				e.printStackTrace();
			}
			Map<String, Object> listItem = new HashMap<String, Object>();
			listItem.put("image", faceImageIds[i]);
			listItems.add(listItem);
		}

		SimpleAdapter simpleAdapter = new SimpleAdapter(this, listItems, R.layout.layout_single_expression_cell, new String[] { "image" },
				new int[] { R.id.image });
		view.setAdapter(simpleAdapter);
		view.setNumColumns(5);
		view.setBackgroundColor(Color.rgb(214, 211, 214));
		view.setHorizontalSpacing(1);
		view.setVerticalSpacing(1);
		view.setLayoutParams(new LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.FILL_PARENT));
		view.setGravity(Gravity.CENTER);
		return view;
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
		Msg entity = new Msg();
		switch (requestCode) {
		case 1:
			if (resultCode == RESULT_OK) {
				entity.type = GlobalContants.CONST_INT_MES_TYPE_IMG;
				entity.userid = Global.getMe().getGlobalUser().id;
				entity.content = GlobalContants.BASE_DIR + imageName;
				messages.add(entity);
//				msg2Adapter.add(entity);
			}
			break;
		case 2:
			if (data != null) {
				entity.type = GlobalContants.CONST_INT_MES_TYPE_IMG;
				entity.userid = Global.getMe().getGlobalUser().id;
				entity.content = getAbsoluteImagePath(data.getData());
				messages.add(entity);
//				msg2Adapter.add(entity);
			}
			break;
		default:
			break;
		}
		if (!UtilString.isEmpty(entity.content)) {
			mAdapter.notifyDataSetChanged();
			mListView.setSelection(mListView.getCount() - 1);
			sendImageToService(entity);
		}
	}

	private void sendImageToService(final Msg entity) {
		UtilThread.executeMore(new Runnable() {
			@Override
			public void run() {
				String url = GlobalContants.SEND_IMAGE_MSG;
				int result = upload(url, group_id, entity, true);
				if (result == AbstractResult.RETURN_CODE_INVALID) {
					mHandler.sendEmptyMessage(GlobalContants.INVALID);
				} else if (result == AbstractResult.RETURN_CODE_FAIL) {
					mHandler.sendEmptyMessage(GlobalContants.FAIL);
				} else {
					mHandler.sendEmptyMessage(10000);
				}
			}
		});

	}

	protected String getAbsoluteImagePath(Uri uri) {
		String[] proj = { MediaStore.Images.Media.DATA };
		Cursor cursor = managedQuery(uri, proj, // Which columns to return
				null, // WHERE clause; which rows to return (all rows)
				null, // WHERE clause selection arguments (none)
				null); // Order-by clause (ascending by name)
		// can post image
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

	private Handler mHandler = new Handler() {
		public void handleMessage(Message msg) {
			if (dialog != null && dialog.isShowing()) {
				dialog.dismiss();
			}
			switch (msg.what) {
			case GlobalContants.SUCCESS:
				Msg entity = (Msg) msg.obj;
				messages.add(entity);
//				msg2Adapter.add(entity);
				mAdapter.notifyDataSetChanged();
				mEditTextContent.setText("");
				mListView.setSelection(mListView.getCount() - 1);
				break;
			case GlobalContants.FAIL:
				Toast.makeText(ActivityTalk.this, "发送失败,请检查网络!", Toast.LENGTH_SHORT).show();
				break;
			case GlobalContants.REFRESH:
//				mAdapter.notifyDataSetChanged();
//				mListView.setSelection(msg.arg1);
				mAdapter.notifyDataSetChanged();
				mListView.setSelection(messages.size());
				break;
			case GlobalContants.INVALID:
				finish();
				ActivityMain.instance.exit("大业堂提示", "你的账号已失效,\n点击[确定]退出重新登录");
				break;
			case GlobalContants.HAVE_NEW_EVENT:
				layoutNewEvent.setVisibility(View.VISIBLE);
				break;
			default:
				mAdapter.notifyDataSetChanged();
				mListView.setSelection(mListView.getCount() - 1);
				break;
			}
		};
	};

	private void sendMsgToServer(final String contString, final int group_id, final Msg entity) {

		UtilThread.executeMore(new Runnable() {
			@Override
			public void run() {
				String url = GlobalContants.SEND_TEXT_MSG;
				// userName password devicetype deviceid
				url += "&userid=" + Global.getMe().getGlobalUser().id;
				url += "&groupid=" + group_id;
				url += "&msg=" + contString;
				url += "&encodeStr=" + Global.getMe().getEncodeStr();
				UtilHttp http = new UtilHttp(url, "UTF-8");
				String result = http.getResponseAsStringGET(new HashMap<String, String>());
				if (result != null) {
					try {
						Gson gson = new Gson();
						SendTextMsgResult sendResult = gson.fromJson(result, SendTextMsgResult.class);
						if (sendResult.returnCode == SendTextMsgResult.RETURN_CODE_INVALID) {
							mHandler.sendEmptyMessage(GlobalContants.INVALID);
							return;
						}
						//						fsCommanResult rs = sendResult.obj;
						Message handleMessage = new Message();
						handleMessage.obj = entity;
						handleMessage.what = GlobalContants.SUCCESS;
						mHandler.sendMessage(handleMessage);
					} catch (Exception e) {
						e.printStackTrace();

						mHandler.sendEmptyMessage(GlobalContants.FAIL);
					}
				} else {
					mHandler.sendEmptyMessage(GlobalContants.FAIL);
				}
			}
		});

	}

	private void sendSoundToServer(final String voicename, final int group_id, final Msg entity) {

		UtilThread.executeMore(new Runnable() {
			@Override
			public void run() {
				String url = GlobalContants.SEND_SOUND_MSG;
				int result = upload(url, group_id, entity, false);
				if (result == AbstractResult.RETURN_CODE_INVALID) {
					mHandler.sendEmptyMessage(GlobalContants.INVALID);
				} else if (result == AbstractResult.RETURN_CODE_FAIL) {
					mHandler.sendEmptyMessage(GlobalContants.FAIL);
				} else {
					mHandler.sendEmptyMessage(10000);
				}
			}
		});

	}

	private void send() {
		String contString = mEditTextContent.getText().toString();
		if (contString.length() > 0) {
			Msg entity = new Msg();
			entity.type = GlobalContants.CONST_INT_MES_TYPE_TEXT;
			entity.userid = Global.getMe().getGlobalUser().id;
			entity.content = contString;
			sendMsgToServer(contString, group_id, entity);
		}
	}

	private boolean isCancelVoice = false;

	// 按下语音录制按钮时
	@Override
	public boolean onTouchEvent(MotionEvent event) {

		if (!Environment.getExternalStorageDirectory().exists()) {
			Toast.makeText(this, "No SDCard", Toast.LENGTH_LONG).show();
			return false;
		}

		if (btn_vocie) {
			int[] location = new int[2];
			mBtnRcd.getLocationInWindow(location); // 获取在当前窗口内的绝对坐标
			int btn_rc_Y = location[1];
			int btn_rc_X = location[0];
			int[] del_location = new int[2];
			del_re.getLocationInWindow(del_location);
			int del_Y = del_location[1];
			int del_x = del_location[0];

			//			mBtnRcd.setText("按住  说话");
			if (event.getAction() == MotionEvent.ACTION_DOWN && flag == 1) {
				if (!Environment.getExternalStorageDirectory().exists()) {
					Toast.makeText(this, "No SDCard", Toast.LENGTH_LONG).show();
					return false;
				}
				if (event.getY() > btn_rc_Y && event.getX() > btn_rc_X) {
					/**
					 * 判断手势按下的位置是否是语音录制按钮的范围内
					 */

					isCancelVoice = false;

					layout_voice_hint.setVisibility(View.VISIBLE);
					mBtnRcd.setBackgroundResource(R.drawable.voice_rcd_btn_pressed);
					rcChat_popup.setVisibility(View.VISIBLE);
					voice_rcd_hint_loading.setVisibility(View.VISIBLE);
					voice_rcd_hint_rcding.setVisibility(View.GONE);
					voice_rcd_hint_tooshort.setVisibility(View.GONE);
					mHandler.postDelayed(new Runnable() {
						public void run() {
							if (!isShosrt) {
								voice_rcd_hint_loading.setVisibility(View.GONE);
								voice_rcd_hint_rcding.setVisibility(View.VISIBLE);
							}
						}
					}, 300);
//					img1.setVisibility(View.VISIBLE);
					del_re.setVisibility(View.GONE);
					startVoiceT = System.currentTimeMillis();
					// SystemClock.currentThreadTimeMillis();
					voiceName = startVoiceT + ".amr";
					start(voiceName);
					flag = 2;
				}
			} else if (event.getAction() == MotionEvent.ACTION_UP && flag == 2) {
				/**
				 * 松开手势时执行录制完成
				 */

				mBtnRcd.setBackgroundResource(R.drawable.voice_rcd_btn_nor);
				if (event.getY() >= del_Y && event.getY() <= del_Y + del_re.getHeight() && event.getX() >= del_x && event.getX() <= del_x + del_re.getWidth()) {
					rcChat_popup.setVisibility(View.GONE);
//					img1.setVisibility(View.VISIBLE);
					del_re.setVisibility(View.GONE);
					stop();
					flag = 1;
					File file = new File(GlobalContants.CONST_VIDEO_CACHE_IMG + "/" + voiceName);
					if (file.exists()) {
						file.delete();
					}
				} else {

					voice_rcd_hint_rcding.setVisibility(View.GONE);
					stop();
					endVoiceT = System.currentTimeMillis();
					// SystemClock.currentThreadTimeMillis();
					flag = 1;
					int time = (int) ((endVoiceT - startVoiceT) / 1000);
					if (time < 1 || isCancelVoice) {
						isShosrt = true;
						voice_rcd_hint_loading.setVisibility(View.GONE);
						voice_rcd_hint_rcding.setVisibility(View.GONE);
						if (!isCancelVoice) {
							voice_rcd_hint_tooshort.setVisibility(View.VISIBLE);
						}
						mHandler.postDelayed(new Runnable() {
							public void run() {
								voice_rcd_hint_tooshort.setVisibility(View.GONE);
								rcChat_popup.setVisibility(View.GONE);
								isShosrt = false;
							}
						}, 500);
						return false;
					}
					Msg entity = new Msg();

					entity.type = GlobalContants.CONST_INT_MES_TYPE_SOUND;
					entity.userid = Global.getMe().getGlobalUser().id;
//					entity.soundTime = time + "'";
					entity.content = GlobalContants.CONST_VIDEO_CACHE_IMG + voiceName;


					sendSoundToServer(voiceName, group_id, entity);
					entity.soundLocal = true;
					messages.add(entity);
//					msg2Adapter.add(entity);
					mAdapter.notifyDataSetChanged();
					mListView.setSelection(mListView.getCount() - 1);
					rcChat_popup.setVisibility(View.GONE);

				}
			}
			if (event.getY() < btn_rc_Y) {
				/**
				 * 手势按下的位置不在语音录制按钮的范围内
				 */
				isCancelVoice = true;
				//				Animation mLitteAnimation = AnimationUtils.loadAnimation(this, R.anim.cancel_rc);
				//				Animation mBigAnimation = AnimationUtils.loadAnimation(this, R.anim.cancel_rc2);
//				img1.setVisibility(View.GONE);
				del_re.setVisibility(View.VISIBLE);
				del_re.setBackgroundResource(R.drawable.soundcancel);
				layout_voice_hint.setVisibility(View.GONE);
				if (event.getY() >= del_Y && event.getY() <= del_Y + del_re.getHeight() && event.getX() >= del_x && event.getX() <= del_x + del_re.getWidth()) {
					del_re.setBackgroundResource(R.drawable.soundcancel);
					sc_img1.setBackgroundResource(R.drawable.soundcancel);
				}
			} else {

//				img1.setVisibility(View.VISIBLE);
				del_re.setVisibility(View.GONE);
				del_re.setBackgroundResource(0);
			}
		}
		return super.onTouchEvent(event);
	}

	private static final int POLL_INTERVAL = 300;

	private Runnable mSleepTask = new Runnable() {
		public void run() {
			stop();
		}
	};
	private Runnable mPollTask = new Runnable() {
		public void run() {
			double amp = mSensor.getAmplitude();
			updateDisplay(amp);
			mHandler.postDelayed(mPollTask, POLL_INTERVAL);

		}
	};
	private int firstItem;

	private void start(String name) {
		mSensor.start(name);
		mHandler.postDelayed(mPollTask, POLL_INTERVAL);
	}

	private void stop() {
		mHandler.removeCallbacks(mSleepTask);
		mHandler.removeCallbacks(mPollTask);
		mSensor.stop();
		volume.setImageResource(R.drawable.amp1);
	}

	private void updateDisplay(double signalEMA) {

		switch ((int) signalEMA) {
		case 0:
		case 1:
			volume.setImageResource(R.drawable.amp1);
			break;
		case 2:
		case 3:

			break;
		case 4:
		case 5:
			volume.setImageResource(R.drawable.amp4);
			break;
		case 6:
		case 7:
			volume.setImageResource(R.drawable.amp7);
			break;
		case 8:
		case 9:
		case 10:
		case 11:
			volume.setImageResource(R.drawable.amp9);
			break;
		default:
			volume.setImageResource(R.drawable.amp7);
			break;
		}
	}

	public void head_xiaohei(View v) {
		/**
		 * 标题栏 返回按钮
		 */
	}

	// 上传
	public int upload(String strUrl, int groupid,final Msg entity, boolean isImg) {
		// 将图片流以字符串形式存储下来
		MultipartPostMethod filePost = new MultipartPostMethod(strUrl);
		filePost.setRequestHeader("Charset", "UTF-8");
		filePost.addParameter("userid", String.valueOf(Global.getMe().getGlobalUser().id));
		filePost.addParameter("groupid", String.valueOf(groupid));
		filePost.addParameter("encodeStr", Global.getMe().getEncodeStr());
		if (isImg) {
			try {
				File file = new File(entity.content);
				filePost.addParameter("img", file);
//				String ext = this.getFileExt(entity.content);
//				String fileName = "images/msg/" + System.currentTimeMillis() + "." + ext;
				entity.thumb = "file://" + entity.content;
			} catch (Exception e) {
				e.printStackTrace();
			}
		} else {
			try {
				filePost.addParameter("sound", new File(entity.content));
			} catch (FileNotFoundException e) {
				e.printStackTrace();
			}
		}
		HttpClient clients = new HttpClient();
		try {
			int status = clients.executeMethod(filePost);
			BufferedReader rd = new BufferedReader(new InputStreamReader(filePost.getResponseBodyAsStream(), "UTF-8"));
			StringBuffer stringBuffer = new StringBuffer();
			String line;
			while ((line = rd.readLine()) != null) {
				stringBuffer.append(line);
			}
			rd.close();
			Gson gson = new Gson();
			AbstractResult sendResult = gson.fromJson(stringBuffer.toString(), AbstractResult.class);
			return sendResult.returnCode;
		} catch (Exception e) {
			e.printStackTrace();
			return AbstractResult.RETURN_CODE_FAIL;
		}
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		Global.isTalkOpen = false;
		MsgAppView.currentGroup = -1;
		try {
			if (mReceiver != null)
				unregisterReceiver(mReceiver);
		} catch (Exception e) {
			e.printStackTrace();
		}
		if (null != mAdapter) {
			mAdapter.initSoundPlay();
		}
	}
	
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
	 
	    if(keyCode == KeyEvent.KEYCODE_BACK) { //监控/拦截/屏蔽返回键
	 
	    	if(null != layout_popup && layout_popup.isShown()){
	    		layout_popup.setVisibility(View.GONE);
	    		return true;
	    	}else{
	    		return super.onKeyDown(keyCode, event);
	    	}
	    }
	 
	    return super.onKeyDown(keyCode, event);
	 
	}

	
	public class MyReceiver extends BroadcastReceiver {

		public MyReceiver() {
		}
		@Override
		public void onReceive(final Context context, Intent intent) {
			Bundle bundle = intent.getExtras();
			if (JPushInterface.ACTION_MESSAGE_RECEIVED.equals(intent.getAction())) {
				String result = bundle.getString(JPushInterface.EXTRA_MESSAGE);
				Gson gs = new Gson();
				if (null != result) {
					final ReturnChatMsg rcm = gs.fromJson(result, ReturnChatMsg.class);
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
						UtilThread.executeMore(new Runnable() {
							@Override
							public void run() {
								if(GlobalContants.CONST_INT_MES_TYPE_SOUND == msg.type){
									final String fileName = msg.content.substring(msg.content.lastIndexOf("/")+1);
										String url = GlobalContants.CONST_STR_BASE_URL + msg.content;
										UtilHttp.downloadFile(url, GlobalContants.CONST_VIDEO_CACHE_IMG,  fileName, null);
								}

								LpClubDB db = null;
								try{
									db = new LpClubDB(context);
									db.beginTransaction();
									db.execSQL(TalkContentTable.CONST_INSERT, new String[] {"userid_"+Global.userid+"_" + msg.id, msg.content, msg.userid + "", msg.group_id + "",
											msg.type + "", msg.TIME, msg.state, msg.thumb, msg.newMsgPos + "", msg.soundTime, "" + msg.soundLocal,
											msg.newmsgid + "", "" + Global.userid });
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
						if (rcm.obj.userid != Global.userid) {
							messages.add(msg);
//						msg2Adapter.add(msg);
							mListView.setSelection(messages.size());
						}
					}
				}
			}else if("com.dyt.reload.messages".equals(intent.getAction())){
				resetListView();
			}
		}

	}
	
	@Override
	public void onScroll(AbsListView view, int firstVisibleItem, int visibleItemCount, int totalItemCount) {
		firstItem = firstVisibleItem;
	}

	@Override
	public void onScrollStateChanged(AbsListView view, int scrollState) {
		if (firstItem == 0 && (scrollState == SCROLL_STATE_IDLE)) {
			resetListView();
		}
	}

	private String getFileExt(String fileName) {
		return fileName.substring(fileName.lastIndexOf(".") + 1);
	}
	

}