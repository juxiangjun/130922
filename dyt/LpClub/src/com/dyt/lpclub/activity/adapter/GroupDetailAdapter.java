package com.dyt.lpclub.activity.adapter;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.dyt.lpclub.R;
import com.dyt.lpclub.activity.domain.GroupViewHolder;
import com.dyt.lpclub.activity.domain.User;
import com.dyt.lpclub.global.Global;
import com.dyt.lpclub.global.GlobalContants;
import com.dyt.lpclub.util.UtilString;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.display.RoundedBitmapDisplayer;

public class GroupDetailAdapter extends BaseAdapter {

	private List<User> 				userList;
	private LayoutInflater 			mInflater;
	private DisplayImageOptions 	options;
	
	public GroupDetailAdapter(Context mContext, List<User> userList) {
		this.userList 		= 	userList;
		this.mInflater 		= 	LayoutInflater.from(mContext);
		this.options 		= 	new DisplayImageOptions.Builder()
									.showStubImage(R.drawable.default_head)
									.showImageForEmptyUri(R.drawable.default_head)
									.showImageOnFail(R.drawable.default_head)
									.cacheInMemory(true)
									.cacheOnDisc(true)
									.displayer(new RoundedBitmapDisplayer(8))
									.build();
	}

	@Override
	public int getCount() {
		return userList.size();
	}

	@Override
	public Object getItem(int position) {
		return userList.get(position);
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {

		GroupViewHolder holder = null;
		if (convertView == null) {
			holder = new GroupViewHolder();
			convertView = mInflater.inflate(R.layout.layout_group_detail_item, null);
			holder.imageHead = (ImageView) convertView.findViewById(R.id.imageHead);
			holder.groupName = (TextView) convertView.findViewById(R.id.userName);
			convertView.setTag(holder);
		} else {
			holder = (GroupViewHolder) convertView.getTag();
		}
		User user = (User) getItem(position);

		holder.imageHead.setImageResource(R.drawable.default_head);
		if (user.id == Global.getMe().getGlobalUser().id) {
			user = Global.getMe().getGlobalUser();
		}
		if (!UtilString.isEmpty(user.thumb)) {
			ImageLoader.getInstance().displayImage(GlobalContants.CONST_STR_BASE_URL+user.thumb, holder.imageHead, options);
		}
		holder.groupName.setText(user.name);
		return convertView;
	}


	public void setNewgl(List<User> newgl) {
		this.userList = new ArrayList<User>(newgl);
	}
}
