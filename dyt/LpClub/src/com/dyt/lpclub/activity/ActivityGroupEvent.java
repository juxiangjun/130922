package com.dyt.lpclub.activity;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.DisplayMetrics;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.AbsListView;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.dyt.lpclub.R;
import com.dyt.lpclub.activity.adapter.GroupDetailAdapter;
import com.dyt.lpclub.activity.domain.BeanEvent;
import com.dyt.lpclub.activity.domain.User;
import com.dyt.lpclub.activity.domain.result.AbstractResult;
import com.dyt.lpclub.activity.domain.result.GetGroupMemberListResult;
import com.dyt.lpclub.activity.domain.result.ResultEvent;
import com.dyt.lpclub.activity.view.HorizontalScrollViewWithListener;
import com.dyt.lpclub.global.CommonCallBack;
import com.dyt.lpclub.global.ConfigSharePref;
import com.dyt.lpclub.global.Global;
import com.dyt.lpclub.global.GlobalContants;
import com.dyt.lpclub.global.GolbalUserCache;
import com.dyt.lpclub.global.GolbalUserCache.GetUserCallBack;
import com.dyt.lpclub.util.UtilBitmap;
import com.dyt.lpclub.util.UtilHttp;
import com.dyt.lpclub.util.UtilThread;
import com.google.gson.Gson;

public class ActivityGroupEvent extends Activity{

	private ProgressDialog dailog;
	private GridView gridView;
	private LayoutInflater inflater;
	private List<User> dataList = new ArrayList<User>();
	
	private int groupId ;
	private GroupDetailAdapter adapter;
	private boolean mIsScrolling;
	private HorizontalScrollViewWithListener svGridView;
	private BeanEvent event;
	
	private TextView tv_group_time,tv_group_notice,tv_group_place,tv_group_content,tv_group_members;
	private Button btn_back;
	private Button btn_group_join;
	private boolean isJoin;

	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.layout_team_event);
		groupId = getIntent().getExtras().getInt("group_id");
		
		initView();
		
		adapter = new GroupDetailAdapter(this ,dataList);
		gridView.setAdapter(adapter);
		loadDataFromWWW();

	}

	private void initView() {
		svGridView = (HorizontalScrollViewWithListener) findViewById(R.id.sv_gridview);
		gridView = (GridView) this.findViewById(R.id.gv_group_members);
		gridView.setOnScrollListener(new MyGridViewScrollListener());
		dailog = new ProgressDialog(this);
		dailog.setMessage(getString(R.string.login_loading));

		
		tv_group_time = (TextView) findViewById(R.id.tv_group_time);
		tv_group_notice = (TextView) findViewById(R.id.tv_group_notice);
		tv_group_place = (TextView) findViewById(R.id.tv_group_place);
		tv_group_content = (TextView) findViewById(R.id.tv_group_content);
		tv_group_members = (TextView) findViewById(R.id.tv_group_members);
		btn_back = (Button) findViewById(R.id.btn_back);
		btn_back.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				finish();
			}
		});
		btn_group_join = (Button) findViewById(R.id.btn_group_join);
		btn_group_join.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				if (isJoin) {
					quitEvent();
				} else {
					joinEvent();
				}
			}
		});
		inflater = (LayoutInflater) this
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
	}

	private Handler mHander = new Handler() {
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case GlobalContants.SUCCESS:
				double size = dataList.size();
				DisplayMetrics dm = new DisplayMetrics();
				getWindowManager().getDefaultDisplay().getMetrics(dm);
				
				float density = dm.density;
				int padding = 10;
				int row = 2;
				int itemWidth = (int) (80 * density);
				int columns = 4;
				if (size > 2 * 4) {
					columns = (int) Math.ceil(size / row) > 4 ? (int)Math.ceil(size / row) : 4;
				}
				int allWidth = (int) ((itemWidth+padding*density) * columns);
				LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(
						allWidth, LinearLayout.LayoutParams.FILL_PARENT);
				gridView.setLayoutParams(params);
				gridView.setColumnWidth(itemWidth);
				gridView.setHorizontalSpacing(padding);
				gridView.setStretchMode(GridView.NO_STRETCH);
				gridView.setNumColumns(columns);
				
				tv_group_members.setText(getResources().getString(R.string.tv_group_members, (int)size));

				if(isJoin){
					btn_group_join.setBackgroundResource(R.drawable.btn_event_quit);
				}
				if(null != event){
					tv_group_time.setText(event.event_date);
					tv_group_notice.setText(event.event_title);
					tv_group_place.setText(event.event_address);
					tv_group_content.setText(event.event_content);
				}
				adapter.notifyDataSetChanged();
				break;
			case GlobalContants.FAIL:
				Toast.makeText(ActivityGroupEvent.this, R.string.data_load_fail, Toast.LENGTH_SHORT).show();
				break;
			case GlobalContants.NOT_HAVE_EVENT:
				tv_group_time.setText("无群组活动");
				tv_group_notice.setText("无群组活动");
				tv_group_place.setText("无群组活动");
				tv_group_content.setText("无群组活动");
				btn_group_join.setVisibility(View.GONE);
				
				svGridView.setVisibility(View.GONE);
				break;
			case GlobalContants.ADDEVENTFAIL:
				Toast.makeText(ActivityGroupEvent.this,(CharSequence) msg.obj, Toast.LENGTH_SHORT).show();
				break;
			case GlobalContants.ADDEVENTSUCC:
				isJoin = true;
					btn_group_join.setBackgroundResource(R.drawable.btn_event_quit);
					tv_group_members.setText(getResources().getString(R.string.tv_group_members, (int)dataList.size()));
//				Toast.makeText(ActivityGroupEvent.this, "加入成功", Toast.LENGTH_SHORT).show();
				adapter.notifyDataSetChanged();
				break;
			case GlobalContants.QUITEVENTFAIL:
				Toast.makeText(ActivityGroupEvent.this,(CharSequence) msg.obj, Toast.LENGTH_SHORT).show();
				break;
			case GlobalContants.QUITEVENTSUCC:
				isJoin = false;
					btn_group_join.setBackgroundResource(R.drawable.btn_event_join);
					tv_group_members.setText(getResources().getString(R.string.tv_group_members, (int)dataList.size()));
//				Toast.makeText(ActivityGroupEvent.this, "退出成功", Toast.LENGTH_SHORT).show();
				adapter.notifyDataSetChanged();
				break;
			default:
				break;
			}
			if (dailog != null && dailog.isShowing()) {
				dailog.dismiss();
			}
		};
	};
	
	private class MyGridViewScrollListener implements AbsListView.OnScrollListener {

		private int scrollType = -1;

		@Override
		public void onScroll(AbsListView view, int firstVisibleItem, int visibleItemCount, int totalItemCount) {
			if (scrollType == AbsListView.OnScrollListener.SCROLL_STATE_IDLE || scrollType == -1)
				mIsScrolling = false;
			else
				mIsScrolling = true;
		}

		@Override
		public void onScrollStateChanged(AbsListView view, int scrollState) {
			scrollType = scrollState;
			if (scrollType == AbsListView.OnScrollListener.SCROLL_STATE_IDLE) {
				mIsScrolling = false;
				adapter.notifyDataSetChanged();
			}
		}

	}// end class ListViewScrollListener

	private void loadDataFromWWW() {
		dailog.show();
		UtilThread.executeMore(new Runnable() {
			@Override
			public void run() {
				
				String url = GlobalContants.CONST_GROUP_EVENT_MSGS;
				url += "&groupid=" + groupId;
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
								
								mHander.sendEmptyMessage(GlobalContants.NOT_HAVE_EVENT);
								return ;
							}
						} catch (Exception e) {
							e.printStackTrace();
							mHander.sendEmptyMessage(GlobalContants.FAIL);
						}
					} else {
						mHander.sendEmptyMessage(GlobalContants.FAIL);
					}
					
				Date date = null;  
				long timeNew = 0;
				try {
					date = new java.text.SimpleDateFormat("yyyy-MM-dd" , Locale.PRC).parse(event.event_date);
					timeNew  = date.getTime();
				} catch (ParseException e1) {
					e1.printStackTrace();
				}  
				ConfigSharePref.getInstance(ActivityGroupEvent.this).setByArgkey(ConfigSharePref.CONST_KEY_LATESTEVENT_TIME+groupId,""+timeNew);
				url = GlobalContants.CONST_GROUP_EVENT_USERS;
				url += "&eventid=" + event.id;
				url += "&encodeStr=" + Global.getMe().getEncodeStr();
				 http = new UtilHttp(url, "UTF-8");
				 result = http
						.getResponseAsStringGET(new HashMap<String, String>());
				if (result != null) {
					try {
						Gson gson = new Gson();
						GetGroupMemberListResult listResult = gson.fromJson(
								result, GetGroupMemberListResult.class);
						List<User> ps = listResult.obj;
						dataList.clear();
						dataList.addAll(ps);
						isJoin = dataList.contains(Global.getMe().getGlobalUser());
						mHander.sendEmptyMessage(GlobalContants.SUCCESS);
					} catch (Exception e) {
						e.printStackTrace();
						mHander.sendEmptyMessage(GlobalContants.FAIL);
						return;
					}
				} else {
					mHander.sendEmptyMessage(GlobalContants.FAIL);
					return;
				}
			}
		});	}

	final class GridViewAdapter extends BaseAdapter {

		
		private GetUserCallBack mIconLoaderCallBack;
		
		private CommonCallBack mHandlerRefreshCallBack;		

		public GetUserCallBack getmIconLoaderCallBack() {
			if( null == mIconLoaderCallBack){
				mIconLoaderCallBack  = new GetUserCallBack() {
					@Override
					public void invoke(User user) {
						UtilBitmap.loadIconInThread("" + user.id, GlobalContants.BASE_DIR + user.thumb, GlobalContants.CONST_STR_BASE_URL + user.thumb, getMHandlerRefreshCallBack());
					}
				};
			}
			return mIconLoaderCallBack;
		}
		
		public CommonCallBack getMHandlerRefreshCallBack(){
			if( null == mHandlerRefreshCallBack){
				mHandlerRefreshCallBack = new CommonCallBack() {
					@Override
					public void invoke() {
						mHander.post(new Runnable() {
							@Override
							public void run() {
								if (!mIsScrolling&& !svGridView.getIsScrolling()){
									notifyDataSetChanged();
								}
							}
						});
					}
				};
			}
			return mHandlerRefreshCallBack;
		}
		
		@Override
		public int getCount() {
			return dataList.size();
		}

		@Override
		public Object getItem(int position) {
			return dataList.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			
			
			Holder holder = null;
			if (convertView == null) {
				holder = new Holder();
				convertView = inflater.inflate(R.layout.item_event_gridview, null);
				holder.im_icon = (ImageView) convertView.findViewById(R.id.iv_icon);
				holder.tv_username = (TextView) convertView.findViewById(R.id.tv_username);
				convertView.setTag(holder);

			} else
				holder = (Holder) convertView.getTag();
			
			User user = dataList.get(position);
			holder.tv_username.setText(user.name);
			Bitmap icon = UtilBitmap.getIconFromCache("" + user.id);
			if (icon == null || icon.isRecycled()) {
				holder.im_icon.setImageResource(R.drawable.default_head);
				if (!mIsScrolling&& !svGridView.getIsScrolling()){
					user = GolbalUserCache.getUserFromCache("" + user.id, mIconLoaderCallBack);
				}
			} else {
				holder.im_icon.setImageBitmap(icon);

			}
			
			return convertView;
		}

		public class Holder {

			public ImageView im_icon;
			public TextView tv_username;
		}
	}

	private void quitEvent() {
		UtilThread.executeMore(new Runnable() {
			
			@Override
			public void run() {
				String url = GlobalContants.CONST_GROUP_EVENT_QUIT;
				url += "&eventid=" + event.id;
				url += "&userid=" + Global.getMe().getGlobalUser().id;;
				url += "&encodeStr=" + Global.getMe().getEncodeStr();
				UtilHttp http = new UtilHttp(url, "UTF-8");
				String	result = http
							.getResponseAsStringGET(new HashMap<String, String>());
					if (result != null) {
						try {
							Gson gson = new Gson();
							AbstractResult rsJoin  = gson.fromJson(
									result, AbstractResult.class);
							boolean succ = rsJoin.success;
							if(!succ){
								Message message = new Message();
								message.obj = rsJoin.msg;
								message.what = GlobalContants.QUITEVENTFAIL;
								mHander.sendMessage(message);
								return ;
							}
							dataList.remove(Global.getMe().getGlobalUser());
							mHander.sendEmptyMessage(GlobalContants.QUITEVENTSUCC);
						} catch (Exception e) {
							e.printStackTrace();
							mHander.sendEmptyMessage(GlobalContants.QUITEVENTFAIL);
						}
					} else {
						mHander.sendEmptyMessage(GlobalContants.QUITEVENTFAIL);
					}

			}
		});
	}
	
	private void joinEvent() {
		UtilThread.executeMore(new Runnable() {
			
			@Override
			public void run() {
				String url = GlobalContants.CONST_GROUP_EVENT_ADD;
				url += "&eventid=" + event.id;
				url += "&userid=" + Global.getMe().getGlobalUser().id;;
				url += "&encodeStr=" + Global.getMe().getEncodeStr();
				UtilHttp http = new UtilHttp(url, "UTF-8");
				String	result = http
							.getResponseAsStringGET(new HashMap<String, String>());
					if (result != null) {
						try {
							Gson gson = new Gson();
							AbstractResult rsJoin  = gson.fromJson(
									result, AbstractResult.class);
							boolean succ = rsJoin.success;
							if(!succ){
								Message message = new Message();
								message.obj = rsJoin.msg;
								message.what = GlobalContants.ADDEVENTFAIL;
								mHander.sendMessage(message);
								return ;
							}
							dataList.add(Global.getMe().getGlobalUser());
							mHander.sendEmptyMessage(GlobalContants.ADDEVENTSUCC);
						} catch (Exception e) {
							e.printStackTrace();
							mHander.sendEmptyMessage(GlobalContants.ADDEVENTFAIL);
						}
					} else {
						mHander.sendEmptyMessage(GlobalContants.ADDEVENTFAIL);
					}

			}
		});
	}
	
}