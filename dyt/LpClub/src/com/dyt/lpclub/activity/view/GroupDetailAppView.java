package com.dyt.lpclub.activity.view;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.Message;
import android.util.AttributeSet;
import android.view.View;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.Toast;

import com.dyt.lpclub.R;
import com.dyt.lpclub.activity.ActivityGroupEvent;
import com.dyt.lpclub.activity.ActivityMain;
import com.dyt.lpclub.activity.ActivityTalk;
import com.dyt.lpclub.activity.adapter.GroupDetailAdapter;
import com.dyt.lpclub.activity.domain.Group;
import com.dyt.lpclub.activity.domain.User;
import com.dyt.lpclub.activity.domain.result.AbstractResult;
import com.dyt.lpclub.activity.domain.result.GetGroupMemberListResult;
import com.dyt.lpclub.global.Global;
import com.dyt.lpclub.global.GlobalContants;
import com.dyt.lpclub.util.UtilHttp;
import com.dyt.lpclub.util.UtilThread;
import com.google.gson.Gson;

/**
 * 描述:
 * 
 * @author linqiang(866116)
 * @Since 2013-6-6
 */
public class GroupDetailAppView extends CommonAppView {

	private Context mContext;
	private GridView gridView;
	private List<User> list;
	private GroupDetailAdapter mAdater;

	private ProgressDialog dailog;
	private Group group;
	private Group parentGroup;

	private ImageView btnstartAct;
	public GroupDetailAppView(Context paramContext) {
		super(paramContext);
		mContext = paramContext;
		init();
	}

	public GroupDetailAppView(Context paramContext, AttributeSet paramAttributeSet) {
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
		addView(R.layout.layout_group_detail);
		list = new ArrayList<User>();
		dailog = new ProgressDialog(mContext);
		gridView = (GridView) findViewById(R.id.gridview);
		mAdater = new GroupDetailAdapter(mContext, list);
		gridView.setAdapter(mAdater);
		btnstartAct = (ImageView) findViewById(R.id.startAct);
		btnstartAct.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				Intent intent = new Intent(mContext, ActivityGroupEvent.class);
				intent.putExtra("group_id", group.getId());
				mContext.startActivity(intent);
			}
		});
	}

	public void refresh() {
		dailog.setMessage($Str(R.string.data_loading));
		dailog.show();
		initView();
		UtilThread.executeMore(new Runnable() {
			@Override
			public void run() {
				String url = GlobalContants.GET_GROUP_MEMBER_LIST;
				// userName password devicetype deviceid
				url += "&groupid=" + group.getId();
				url += "&encodeStr=" + Global.getMe().getEncodeStr();
				UtilHttp http = new UtilHttp(url, "UTF-8");
				String result = http.getResponseAsStringGET(new HashMap<String, String>());
				if (result != null) {
					try {
						Gson gson = new Gson();
						AbstractResult areturnReuslt = gson.fromJson(result, AbstractResult.class);
						//账号失效
						if (areturnReuslt.returnCode == AbstractResult.RETURN_CODE_INVALID) {
							mHander.sendEmptyMessage(GlobalContants.INVALID);
							return;
						}
						GetGroupMemberListResult listResult = gson.fromJson(result, GetGroupMemberListResult.class);
						List<User> ps = listResult.obj;
						list.clear();
						list.addAll(ps);
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

	private void initView() {
		$(R.id.startChat).setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				Intent intent = new Intent(mContext, ActivityTalk.class);
				intent.putExtra("group_id", group.getId());
				intent.putExtra("parentId", parentGroup.getId());
				intent.putExtra("groupName", group.getName());
				mContext.startActivity(intent);
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
				mAdater.setNewgl(list);
				mAdater.notifyDataSetChanged();
				break;
			case GlobalContants.FAIL:
				Toast.makeText(mContext, R.string.data_load_fail, Toast.LENGTH_SHORT).show();
				break;
			case GlobalContants.NEWTALK:

				break;
			case GlobalContants.INVALID:
				ActivityMain.instance.exit("大业堂提示", "你的账号已失效,\n点击[确定]退出重新登录");
				break;
			default:
				break;
			}
		};
	};

	private String $Str(int resId) {
		return mContext.getString(resId);
	}

	private View $(int resId) {
		return findViewById(resId);
	}

	public Group getGroup() {
		return group;
	}

	public void setGroup(Group group) {
		this.group = group;
	}

	public Group getParentGroup() {
		return parentGroup;
	}

	public void setParentGroup(Group parentGroup) {
		this.parentGroup = parentGroup;
	}

	public void setOnItemClickListener(OnItemClickListener listener) {
		gridView.setOnItemClickListener(listener);
	}

	public List<User> getList() {
		return list;
	}

	public void setList(List<User> list) {
		this.list = list;
	}

}
