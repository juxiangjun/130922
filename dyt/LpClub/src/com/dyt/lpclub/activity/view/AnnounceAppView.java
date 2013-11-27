package com.dyt.lpclub.activity.view;

import java.util.HashMap;
import java.util.LinkedList;

import android.app.ProgressDialog;
import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Toast;

import com.dyt.lpclub.R;
import com.dyt.lpclub.activity.ActivityMain;
import com.dyt.lpclub.activity.adapter.AnnounceAdapter;
import com.dyt.lpclub.activity.domain.Announce;
import com.dyt.lpclub.activity.domain.AnnounceResult;
import com.dyt.lpclub.activity.domain.result.AbstractResult;
import com.dyt.lpclub.activity.domain.result.QueryNewsListResult;
import com.dyt.lpclub.activity.view.PullToRefreshListView.OnRefreshListener;
import com.dyt.lpclub.activity.view.util.AnimationController;
import com.dyt.lpclub.global.ConfigSharePref;
import com.dyt.lpclub.global.Global;
import com.dyt.lpclub.global.GlobalContants;
import com.dyt.lpclub.util.UtilHttp;
import com.dyt.lpclub.util.UtilThread;
import com.google.gson.Gson;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.assist.PauseOnScrollListener;

/**
 * 描述:设置界面
 * 
 * @author linqiang(866116)
 * @Since 2013-6-6
 */
public class AnnounceAppView extends CommonAppView implements OnItemClickListener,OnClickListener{
	private final static int LIMIT = 5;
	
	public final static int MAIN_VIEW 			= 1;
	public final static int DETAIL_VIEW 		= 2;
	//当前页面 只能为以上 的一种
	private int 					currentView;
	private AnimationController 	ctl;
	private Context 				mContext;
	private LinkedList<Announce> 	list;
	private AnnounceAdapter 		mAdapter;
	private PullToRefreshListView 	listView;

	private ProgressDialog 			dialog;
	private int 					startMore 	= 	0;
	private int 					totalCount 	= 	0;
	private boolean 				getNew;
	private AnnounceResult 			announceResult;
	
	private AnnounceDetailAppView 	detialView;
	private View 					mainView;
	
	public AnnounceAppView(Context paramContext) {
		super(paramContext);
		mContext = paramContext;
		init();
	}

	public AnnounceAppView(Context paramContext, AttributeSet paramAttributeSet) {
		super(paramContext, paramAttributeSet);
		mContext = paramContext;
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
		mainView = LayoutInflater.from(mContext).inflate(R.layout.layout_announce, null);
		addView(mainView);
		
		ctl 		= 	new AnimationController();
		dialog 		= 	new ProgressDialog(mContext);
		list 		= 	new LinkedList<Announce>();
		mAdapter 	= 	new AnnounceAdapter(mContext, list);
		listView 	= 	(PullToRefreshListView) findViewById(R.id.announceList);
		getNew 		= 	true;
		currentView =   MAIN_VIEW;
		
		PauseOnScrollListener listener = new PauseOnScrollListener(ImageLoader.getInstance(), true, true);
		listView.setOnScrollListener(listener);
		listView.setOnItemClickListener(this);
		listView.setAdapter(mAdapter);
		listView.setOnRefreshListener(onRefreshListener);
		getData();
	}

	/**
	 * 
	 */
	private OnRefreshListener onRefreshListener = new OnRefreshListener() {

		@Override
		public void onRefresh() {
			getNew = true;
			getData();
		}

		@Override
		public void onScrollStateIdle() {
			if (listView.isLastItem(list.size())) {
				getNew = false;
				listView.setFooterVisibility(View.VISIBLE);
				getData();
			}
		}
	};

	private void getData() {
		dialog.setMessage($Str(R.string.data_loading));
		dialog.show();
		UtilThread.executeMore(new Runnable() {
			@Override
			public void run() {
				String url = GlobalContants.QUERY_NEWS_LIST;
				// userName password devicetype deviceid
				if (getNew) {
					url += "&start=" + 0;
				} else {
					url += "&start=" + startMore;
				}
				url += "&limit=" + LIMIT;
				url += "&encodeStr=" + Global.getMe().getEncodeStr();
				UtilHttp http = new UtilHttp(url, "UTF-8");
				String result = http.getResponseAsStringGET(new HashMap<String, String>());
				if (result != null) {
					try {
						Gson gson = new Gson();
						QueryNewsListResult queryNewsResult = gson.fromJson(result, QueryNewsListResult.class);
						//账号失效
						if (queryNewsResult.returnCode == AbstractResult.RETURN_CODE_INVALID) {
							mHander.sendEmptyMessage(GlobalContants.INVALID);
							return;
						}
						announceResult = queryNewsResult.obj;
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
			switch (msg.what) {
			case GlobalContants.SUCCESS:
				if (getNew) {
					if (totalCount < announceResult.totalCount) {
						for (int i = announceResult.news.size() - 1; i >= 0; i--) {
							list.addFirst(announceResult.news.get(i));
							startMore++;
						}
						totalCount = announceResult.totalCount;
					} else {
						Toast.makeText(mContext, "已无新公告", Toast.LENGTH_SHORT).show();
					}
				} else {
					if (startMore >= totalCount) {
						Toast.makeText(mContext, "已无旧公告", Toast.LENGTH_SHORT).show();
						startMore = totalCount;
					} else {
						startMore += LIMIT;
						list.addAll(announceResult.news);
					}
				}
				ConfigSharePref.getInstance(mContext).setByArgkey("announce_totalCount", ""+announceResult.totalCount);
				mAdapter.notifyDataSetChanged();
				listView.onRefreshComplete();
				if (getNew) {
					listView.setSelection(1);
				}
				break;
			case GlobalContants.FAIL:
				listView.onRefreshComplete();
				Toast.makeText(mContext, R.string.data_load_fail, Toast.LENGTH_SHORT).show();
				break;
			case GlobalContants.INVALID:
				ActivityMain.instance.exit("大业堂提示", "你的账号已失效,\n点击[确定]退出重新登录");
				break;
			default:
				break;
			}
			if (dialog != null && dialog.isShowing()) {
				dialog.dismiss();
			}
		};
	};

	private String $Str(int resId) {
		return mContext.getString(resId);
	}

	@Override
	public void onItemClick(AdapterView<?> arg0, View arg1, int position, long id) {
		if(detialView == null){
			detialView 	= new AnnounceDetailAppView(mContext);
		}
		if (detialView != null) {
			currentView = DETAIL_VIEW;
			ctl.slideOut(mainView, 500, 0);
			ctl.slideIn(detialView, 500, 0);
			
			if(detialView.getParent() == null)
				this.addView(detialView);
			detialView.refreshAnnounce(list.get(position - 1));
		}
		((ActivityMain)mContext).setOnBackVisbility(View.VISIBLE);
	}
	
	/**
	 * 返回事件
	 */
	@Override
	public void onClick(View v) {

		switch (currentView) {
		case DETAIL_VIEW:
			if (mainView != null) {
				ctl.slideInBack(detialView, 500, 0);
				ctl.slideOutBack(mainView, 500, 0);
				currentView = MAIN_VIEW;
				((ActivityMain)mContext).setOnBackVisbility(View.GONE);
			}
			break;
		default:
			break;
		}
	}

	public int getCurrentView() {
		return currentView;
	}

}
