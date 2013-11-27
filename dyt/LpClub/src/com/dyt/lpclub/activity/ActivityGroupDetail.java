package com.dyt.lpclub.activity;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.provider.MediaStore;
import android.util.DisplayMetrics;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.GridView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.dyt.lpclub.R;
import com.dyt.lpclub.activity.adapter.GroupDetailAdapter;
import com.dyt.lpclub.activity.adapter.ImageAdapter;
import com.dyt.lpclub.activity.domain.Group;
import com.dyt.lpclub.activity.domain.GroupPic;
import com.dyt.lpclub.activity.domain.Result;
import com.dyt.lpclub.activity.domain.User;
import com.dyt.lpclub.activity.domain.result.AbstractResult;
import com.dyt.lpclub.activity.domain.result.GetGroupMemberListResult;
import com.dyt.lpclub.activity.domain.result.GetGroupPicResult;
import com.dyt.lpclub.activity.imgbrowse.ActivityImgBrowse;
import com.dyt.lpclub.global.Global;
import com.dyt.lpclub.global.GlobalContants;
import com.dyt.lpclub.util.UtilHttp;
import com.dyt.lpclub.util.UtilString;
import com.dyt.lpclub.util.UtilThread;
import com.dyt.lpclub.util.ViewUtil;
import com.google.gson.Gson;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.AsyncHttpResponseHandler;
import com.loopj.android.http.RequestParams;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.assist.PauseOnScrollListener;

public class ActivityGroupDetail extends Activity implements OnItemClickListener{

	private static final int 		UPLOAD_SUCCESS 	= 	200, 
									UPLOAD_FAIL 	= 	-200;

	private Context 				mContext;
	private GroupDetailAdapter 		mAdapter;
	private GridView 				gridView;
	private List<User> 				list;
	private ProgressDialog 			dailog;
	private Group 					group;
	private Group 					parentGroup;
	private TextView 				layout_title;
	private int 					groupid, 
									parentId, 
									start = 0, 
									limit = 8;
	private GridView 				gallery;
	private List<GroupPic> 			groupPicList;
	private ImageAdapter 			mImageAdapter;
	private String 					imageName;
	private ArrayList<String> 		picList;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		ViewUtil.fullscreen(this);
		setContentView(R.layout.layout_activity_group_detail);
		mContext 	= 	this;
		parentId 	= 	getIntent().getIntExtra("parentId", 0);
		groupid 	= 	getIntent().getIntExtra("group_id", 0);
		parentGroup = 	Global.getMe().getGroupList().get(parentId);
		group 		= 	Global.getMe().getGroupList().get(groupid);
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
		groupPicList 	= 	new ArrayList<GroupPic>();
		picList			=  	new ArrayList<String>();
		list 			= 	new ArrayList<User>();
		dailog 			= 	new ProgressDialog(mContext);
		mAdapter 		= 	new GroupDetailAdapter(mContext, list);
		gridView 		= 	(GridView) findViewById(R.id.gridview);
		layout_title 	= 	(TextView) $(R.id.layout_title);
		gallery 		= (GridView) $(R.id.gallery);
		mImageAdapter = new ImageAdapter(mContext, groupPicList);
		gallery.setAdapter(mImageAdapter);
		gridView.setAdapter(mAdapter);
		gallery.setOnItemClickListener(this);
		gridView.setOnItemClickListener(this);
		PauseOnScrollListener listener = new PauseOnScrollListener(ImageLoader.getInstance(), true, true);
		gridView.setOnScrollListener(listener);
		
		$(R.id.btn_back).setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				finish();
			}
		});
		$(R.id.btn_camera).setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
				imageName = System.currentTimeMillis() + ".jpg";
				// 下面这句指定调用相机拍照后的照片存储的路径
				intent.putExtra(MediaStore.EXTRA_OUTPUT, Uri.fromFile(new File(GlobalContants.BASE_DIR, imageName)));
				startActivityForResult(intent, 1);
			}
		});
		$(R.id.startAct).setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				Intent intent = new Intent(mContext, ActivityGroupEvent.class);
				intent.putExtra("group_id", group.getId());
				mContext.startActivity(intent);
			}
		});
		
		if(this.getIntent().getBooleanExtra("fromTalk", false)){
			$(R.id.startChat).setVisibility(View.INVISIBLE);
		}else{
			$(R.id.startChat).setVisibility(View.VISIBLE);
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
		refresh();
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if (!UtilString.isEmpty(imageName) && resultCode == RESULT_OK) {
			imageName = GlobalContants.BASE_DIR + imageName;
			dailog.setMessage("上传中...");
			dailog.show();
			String url = GlobalContants.UPLOADGROUPPIC;
			final AsyncHttpClient client = new AsyncHttpClient();
			RequestParams params = new RequestParams();
			params.put("userid", String.valueOf(Global.userid));
			params.put("groupid", String.valueOf(groupid));
			params.put("encodeStr", Global.getMe().getEncodeStr());
			try {
				params.put("img", new File(imageName));
			} catch (FileNotFoundException e) {
			}
			client.post(url, params, new AsyncHttpResponseHandler() {
				public void onSuccess(String result) {
					Message msg = new Message();
					msg.what = UPLOAD_FAIL;
					try {
						Gson gson = new Gson();
						Result ps = gson.fromJson(result, Result.class);
						//账号失效
						if (ps.returnCode == AbstractResult.RETURN_CODE_INVALID) {
							mHander.sendEmptyMessage(GlobalContants.INVALID);
							return;
						}
						if (ps.success) {
							msg.what = UPLOAD_SUCCESS;
							msg.obj = ps;
							mHander.sendMessage(msg);
						} else {
							mHander.sendMessage(msg);
						}
					} catch (Exception e) {
						e.printStackTrace();
						mHander.sendMessage(msg);
					}
				}
			});
		}
	}

	private void refresh() {
		dailog.setMessage($Str(R.string.data_loading));
		dailog.show();
		initView();
		UtilThread.executeMore(new Runnable() {
			@Override
			public void run() {
				getPic();
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

	private void getPic() {
		String url = GlobalContants.GET_GROUP_PIC;
		// userName password devicetype deviceid
		url += "&groupid=" + group.getId();
		url += "&start=" + start;
		url += "&limit=" + limit;
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
				GetGroupPicResult listResult = gson.fromJson(result, GetGroupPicResult.class);
				groupPicList.clear();
				groupPicList.addAll(listResult.obj);
				picList.clear();
				for(GroupPic pic :	groupPicList){
					picList.add(GlobalContants.CONST_STR_BASE_URL + pic.pic);
				}
				mHander.sendEmptyMessage(555);
			} catch (Exception e) {
				e.printStackTrace();
				mHander.sendEmptyMessage(GlobalContants.FAIL);
			}
		} else {
			mHander.sendEmptyMessage(GlobalContants.FAIL);
		}
	}

	private void initView() {
		layout_title.setText(parentGroup.getName() + ">" + group.getName() + "(" + group.getMemberCount() + "人)");
	}

	private Handler mHander = new Handler() {
		public void handleMessage(Message msg) {
			if (dailog != null && dailog.isShowing()) {
				dailog.dismiss();
			}
			imageName = "";
			switch (msg.what) {
			case GlobalContants.SUCCESS:
				mAdapter.setNewgl(list);
				double size = list.size();
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
				
				int allWidth = (int) ((itemWidth + padding * density) * columns);
				LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(allWidth, LinearLayout.LayoutParams.FILL_PARENT);
				gridView.setLayoutParams(params);
				gridView.setColumnWidth(itemWidth);
				gridView.setHorizontalSpacing(padding);
				gridView.setStretchMode(GridView.NO_STRETCH);
				gridView.setNumColumns(columns);
				mAdapter.notifyDataSetChanged();
				break;
			case GlobalContants.FAIL:
				Toast.makeText(mContext, R.string.data_load_fail, Toast.LENGTH_SHORT).show();
				break;
			case GlobalContants.INVALID:
				finish();
				ActivityMain.instance.exit("大业堂提示", "你的账号已失效,\n点击[确定]退出重新登录");
				break;
			case UPLOAD_SUCCESS:
				dailog.setMessage($Str(R.string.data_loading));
				dailog.show();
				UtilThread.executeMore(new Runnable() {
					@Override
					public void run() {
						getPic();
					}
				});
				break;
			case UPLOAD_FAIL:
				Toast.makeText(mContext, "上传图片失败!", Toast.LENGTH_SHORT).show();
				break;
			case 555:
				mImageAdapter.notifyDataSetChanged();
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


	@Override
	public void onItemClick(AdapterView<?> arg0, View arg1, int pos, long arg3) {
		if(arg0.getId() == R.id.gallery){
			Intent intent = new Intent(this, ActivityImgBrowse.class);
			intent.putExtra("nowUrl", picList.get(pos));
			intent.putStringArrayListExtra("imageUrls", picList);
			startActivity(intent);
		}else{
			Intent intent = new Intent(mContext, ActivityUserDetail.class);
			intent.putExtra("userid", list.get(pos).id);
			startActivity(intent);
		}
		
	}

}
