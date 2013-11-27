package com.dyt.lpclub.activity.view;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.os.Handler;
import android.os.Message;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;
import cn.jpush.android.api.JPushInterface;

import com.dyt.lpclub.R;
import com.dyt.lpclub.activity.ActivityGroupDetail;
import com.dyt.lpclub.activity.ActivityMain;
import com.dyt.lpclub.activity.adapter.GroupAdapter;
import com.dyt.lpclub.activity.domain.Group;
import com.dyt.lpclub.activity.domain.result.AbstractResult;
import com.dyt.lpclub.activity.domain.result.GetMemberGroupReuslt;
import com.dyt.lpclub.activity.view.PullToRefreshListView.OnRefreshListener;
import com.dyt.lpclub.activity.view.util.AnimationController;
import com.dyt.lpclub.global.Global;
import com.dyt.lpclub.global.GlobalContants;
import com.dyt.lpclub.util.PingYinUtil;
import com.dyt.lpclub.util.UtilThread;
import com.google.gson.Gson;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.AsyncHttpResponseHandler;
import com.loopj.android.http.RequestParams;

/**
 * 描述:父级群组
 * 
 * @author linqiang(866116)
 * @Since 2013-6-6
 */
public class GroupAppView extends CommonAppView implements OnItemClickListener, OnClickListener {

	public final static int GROUP_VIEW = 1;
	private final static int SUB_GROUP_VIEW = 2;
	private final static int NETWORK_BROKEN = 263;
	//当前页面 只能为以上 的一种
	private int currentView;

	private ActivityMain mContext;
	private GroupAdapter mAdapter;
	private PullToRefreshListView listView;
	private List<Group> list;

	private View mainView;
	private GroupChildAppView childView;
	private AnimationController ctl;

	//	private ProgressDialog dailog;
	//保存不同界面的标题
	private String subGroupTitle;
	private ImageView serachBtn;
	private EditText serachText;

	private SideBar indexBar;
	private WindowManager mWindowManager;
	private TextView mDialogText;
	private ProgressDialog dailog;
	private Set<String> tagSet = new LinkedHashSet<String>();
	
	private Handler mHander = new Handler() {
		public void handleMessage(Message msg) {
			if (dailog != null && dailog.isShowing()) {
				dailog.dismiss();
			}
			switch (msg.what) {
			case GlobalContants.SUCCESS:
				if(list.isEmpty()){
					listView.setRefreshViewTextVisibility(View.VISIBLE);
				}else{
					listView.setRefreshViewTextVisibility(View.GONE);
				}
				listView.onRefreshComplete();
				mAdapter.setNewgl(list);
				mAdapter.notifyDataSetChanged();
				JPushInterface.setAliasAndTags(mContext.getApplicationContext(), null, tagSet);
				break;
			case GlobalContants.FAIL:
				listView.setRefreshViewTextVisibility(View.VISIBLE);
				listView.onRefreshComplete();
				Toast.makeText(mContext, R.string.data_load_fail, Toast.LENGTH_SHORT).show();
				break;
			case NETWORK_BROKEN:
				if(list.isEmpty()){
					listView.setRefreshViewTextVisibility(View.VISIBLE);
				}else{
					listView.setRefreshViewTextVisibility(View.GONE);
				}
				listView.onRefreshComplete();
				mAdapter.setNewgl(list);
				mAdapter.notifyDataSetChanged();
				Toast.makeText(mContext, "当前网络异常,请检查你的网络!", Toast.LENGTH_SHORT).show();
				break;
			case GlobalContants.INVALID:
				mContext.exit("大业堂提示", "你的账号已失效,\n点击[确定]退出重新登录");
				break;
			default:
				break;
			}
		}
	};

	public GroupAppView(Context paramContext) {
		super(paramContext);
		mContext = (ActivityMain) paramContext;
		init();
	}

	public GroupAppView(Context paramContext, AttributeSet paramAttributeSet) {
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
		ctl = new AnimationController();
		mainView = LayoutInflater.from(mContext).inflate(R.layout.layout_group, null);
		addView(mainView);
		mWindowManager = (WindowManager) mContext.getSystemService(Context.WINDOW_SERVICE);
		dailog = new ProgressDialog(mContext);
		initView();
	}

	private void initView() {
		list = new ArrayList<Group>();
		mAdapter = new GroupAdapter(mContext, list);
		listView = (PullToRefreshListView) mainView.findViewById(R.id.groupList);
		listView.setFooterVisibility(View.GONE);
		listView.setAdapter(mAdapter);
		listView.setOnItemClickListener(GroupAppView.this);
		listView.setOnRefreshListener(onRefreshListener);
		mContext.setOnBackListener(GroupAppView.this);
		indexBar = (SideBar) findViewById(R.id.sideBar);
		indexBar.setListView(listView);
		indexBar.setAdapter(mAdapter);
		mDialogText = (TextView) LayoutInflater.from(mContext).inflate(R.layout.list_position, null);
		mDialogText.setVisibility(View.INVISIBLE);
		WindowManager.LayoutParams lp = new WindowManager.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT,
				WindowManager.LayoutParams.TYPE_APPLICATION, WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE | WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
				PixelFormat.TRANSLUCENT);
		mWindowManager.addView(mDialogText, lp);
		indexBar.setTextView(mDialogText);

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
		currentView = GROUP_VIEW;
		getData();
	}

	private OnRefreshListener onRefreshListener = new OnRefreshListener() {
		@Override
		public void onRefresh() {
			getData();
		}

		@Override
		public void onScrollStateIdle() {
		}
	};
	
	private void getData(){
		dailog.setMessage($Str(R.string.data_loading));
		dailog.show();
		UtilThread.executeMore(new Runnable() {
			@Override
			public void run() {
				String url = GlobalContants.GET_MEMBER_GROUP;
				final AsyncHttpClient client = new AsyncHttpClient();
				RequestParams params = new RequestParams();
				params.put("userid", ""+Global.userid);
				params.put("encodeStr", Global.getMe().getEncodeStr());
				client.post(url, params, new AsyncHttpResponseHandler() {
					
					@Override
					public void onFailure(Throwable arg0, String arg1) {
						super.onFailure(arg0, arg1);
						list = new ArrayList<Group>();
						for (int key : Global.getMe().getGroupList().keySet()) {
							Group group =  Global.getMe().getGroupList().get(key);
							if( group.getSubGroup() != null){
								list.add(group);
							}
						}
						mHander.sendEmptyMessage(NETWORK_BROKEN);
					}
					
					public void onSuccess(String result) {
						if (result != null) {
							try {
								Gson gson = new Gson();
								AbstractResult areturnReuslt = gson.fromJson(result, AbstractResult.class);
								//账号失效
								if (areturnReuslt.returnCode == AbstractResult.RETURN_CODE_INVALID) {
									mHander.sendEmptyMessage(GlobalContants.INVALID);
									return;
								}
								GetMemberGroupReuslt returnReuslt = gson.fromJson(result, GetMemberGroupReuslt.class);
								List<Group> ps = returnReuslt.obj;
								if (null == ps || ps.size() <= 0) {
									list = new ArrayList<Group>();
									mHander.sendEmptyMessage(GlobalContants.SUCCESS);
									return;
								}
								try {
									for (Group group : ps) {
										List<Group> list = group.getSubGroup();
										String spell = PingYinUtil.getPingYin(group.getName());
										group.spell = spell;
										group.setMemberCount(list.size());
										for (Group g : list) {
											tagSet.add("" + g.getId());
										}
									}
									list = ps;
									Global.getMe().setGroupList(ps);
									mHander.sendEmptyMessage(GlobalContants.SUCCESS);
								} catch (Exception e) {
									e.printStackTrace();
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
		});
	}
	
	@Override
	public void onItemClick(AdapterView<?> adapterView, View view, int position, long id) {
		if (adapterView.getId() == R.id.groupList) {
			currentView = SUB_GROUP_VIEW;
			Group group = mAdapter.getNewgl().get(position - 1);
			if (childView == null) {
				childView = new GroupChildAppView(mContext);
				childView.setOnItemClickListener(this);
			}
			subGroupTitle = $Str(R.string.group) + "(" + group.getName() + ")";
			mContext.setTitleContext(subGroupTitle);
			if (childView != null) {
				ctl.slideOut(mainView, 500, 0);
				ctl.slideIn(childView, 500, 0);
				this.removeAllViews();
				this.addView(childView);
				childView.setParent(group);
				childView.addList(group.getSubGroup());
				childView.refresh();
			}
			mContext.setOnBackVisbility(View.VISIBLE);
		} else if (adapterView.getId() == R.id.groupChildList) {
			Group group = childView.getList().get(position);
			Group parentGroup = childView.getGroup();
			Intent intent = new Intent(mContext, ActivityGroupDetail.class);
			intent.putExtra("group_id", group.getId());
			intent.putExtra("parentId", parentGroup.getId());
			mContext.startActivity(intent);
		}
	}

	private String $Str(int resId) {
		return mContext.getString(resId);
	}

	/**
	 * 返回事件
	 */
	@Override
	public void onClick(View v) {

		switch (currentView) {
		case SUB_GROUP_VIEW:
			if (mainView != null) {
				ctl.slideInBack(childView, 500, 0);
				ctl.slideOutBack(mainView, 500, 0);
				GroupAppView.this.removeAllViews();
				GroupAppView.this.addView(mainView);
				currentView = GROUP_VIEW;
				mContext.setOnBackVisbility(View.GONE);
			}
			break;
		default:
			break;
		}
		setTitle();
	}

	/**
	 * 方法描述:当前页面是哪种页面
	 * 
	 * @Author:solotiger
	 * @Date:2013-6-10
	 * @return:int
	 * @return
	 */
	public int getCurrentView() {
		return currentView;
	}

	/**
	 * 方法描述:设置标题
	 * 
	 * @Author:solotiger
	 * @Date:2013-6-10
	 * @return:void
	 */
	public void setTitle() {
		switch (currentView) {
		case SUB_GROUP_VIEW:
			mContext.setTitleContext(subGroupTitle);
			break;
		default:
			mContext.setTitleContext($Str(R.string.group));
			break;
		}
	}
	
	@Override
	protected void onDetachedFromWindow() {
		super.onDetachedFromWindow();
	}
	
	@Override
	public void finish() {
		super.finish();
		mWindowManager.removeView(mDialogText);
	}
}
