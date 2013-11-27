package com.dyt.lpclub.activity.adapter;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.os.Handler;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Filter;
import android.widget.Filterable;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.dyt.lpclub.R;
import com.dyt.lpclub.activity.domain.NewMsg;
import com.dyt.lpclub.activity.domain.User;
import com.dyt.lpclub.activity.view.BadgeView;
import com.dyt.lpclub.global.GlobalContants;
import com.dyt.lpclub.global.GolbalUserCache;
import com.dyt.lpclub.global.GolbalUserCache.GetUserCallBack;
import com.dyt.lpclub.util.UtilString;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.display.RoundedBitmapDisplayer;

public class MsgAdapter extends BaseAdapter implements Filterable {

	private List<NewMsg> 		ps, newPs;
	private ArrayFilter 		filter;//过滤器  
	private LayoutInflater 		mInflater;
	private Context 			mContext;
	private Handler 			mHandler 	= 	new Handler();
	private String 				searchText;
	private DisplayImageOptions options;
	
	public MsgAdapter(Context mContext, List<NewMsg> ps) {
		this.mContext 	= 	mContext;
		this.mInflater 	= 	LayoutInflater.from(mContext);
		this.ps 		= 	ps;
		this.newPs 		= 	new ArrayList<NewMsg>(ps);
		this.options 	= 	new DisplayImageOptions.Builder()
								.showStubImage(R.drawable.default_group)
								.showImageForEmptyUri(R.drawable.default_group)
								.showImageOnFail(R.drawable.default_group)
								.cacheInMemory(true)
								.cacheOnDisc(true)
								.displayer(new RoundedBitmapDisplayer(8))
								.build();
	}

	@Override
	public int getCount() {
		return newPs.size();
	}

	@Override
	public Object getItem(int position) {
		return newPs.get(position);
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {

		final ViewHolder holder;
		if (convertView == null) {
			holder = new ViewHolder();
			convertView = mInflater.inflate(R.layout.layout_msg_item, null);
			holder.imageHeadlayout = (LinearLayout) convertView.findViewById(R.id.imageHeadLayout);
			holder.imageHead = (ImageView) convertView.findViewById(R.id.imageHead);
			holder.groupName = (TextView) convertView.findViewById(R.id.groupName);
			holder.userName = (TextView) convertView.findViewById(R.id.desc);
			holder.content = (TextView) convertView.findViewById(R.id.desc1);
			holder.dateTime = (TextView) convertView.findViewById(R.id.dateTime);
			holder.badgeView = new BadgeView(mContext, holder.imageHeadlayout);
			holder.badgeView.setBackgroundResource(R.drawable.badge_ifaux);
			convertView.setTag(holder);

		} else {
			holder = (ViewHolder) convertView.getTag();
		}
		holder.dateTime.setText("");
		NewMsg newMsg = (NewMsg) getItem(position);
		String title = newMsg.mainGroupName + ">" + newMsg.name;
		holder.imageHead.setImageResource(R.drawable.default_group);
		if (!UtilString.isEmpty(newMsg.mainGroupPic)) {
			ImageLoader.getInstance().displayImage(GlobalContants.CONST_STR_BASE_URL + newMsg.mainGroupPic, holder.imageHead, options);
		}

		if (newMsg.count > 0) {
			holder.badgeView.setText("" + newMsg.count);
			holder.badgeView.show();
		} else {
			holder.badgeView.hide();
		}

		holder.groupName.setText(title);
		User user = GolbalUserCache.getUserFromCache("" + newMsg.userId, new GetUserCallBack() {
			@Override
			public void invoke(final User user) {
				if (null != user) {
					mHandler.post(new Runnable() {

						@Override
						public void run() {
							holder.userName.setText(user.name + ":");
						}
					});
				}
			}
		});

		if (null != user) {
			holder.userName.setText(user.name + ":");
		}
		
		if(newMsg.TIME != null){
			holder.dateTime.setText(newMsg.TIME.substring(2, 10));
		}
		if (newMsg.msgType == GlobalContants.MSG_TYPE_IMG) {
			holder.content.setText(mContext.getString(R.string.image));
		} else if (newMsg.msgType == GlobalContants.MSG_TYPE_VOICE) {
			holder.content.setText(mContext.getString(R.string.vedio));
		} else {
			holder.content.setText(newMsg.content);
		}

		return convertView;

	}

	class ViewHolder {
		public TextView groupName;
		public TextView userName;
		public TextView content;
		public TextView dateTime;
		public ImageView imageHead;
		public BadgeView badgeView;
		public LinearLayout imageHeadlayout;
	}

	public String getSearchText() {
		return searchText;
	}

	public void setSearchText(String searchText) {
		this.searchText = searchText;
	}

	@Override
	public Filter getFilter() {
		if (filter == null) {
			filter = new ArrayFilter();
		}
		return filter;
	}

	private class ArrayFilter extends Filter {

		@Override
		protected FilterResults performFiltering(CharSequence prefix) {
			FilterResults results = new FilterResults();
			if (UtilString.isEmpty(prefix)) {//没有过滤符就不过滤  
				ArrayList<NewMsg> l = new ArrayList<NewMsg>(ps);
				results.values = l;
				results.count = l.size();
			} else {
				final ArrayList<NewMsg> values = new ArrayList<NewMsg>(ps);
				final int count = values.size();
				final ArrayList<NewMsg> newValues = new ArrayList<NewMsg>(count);
				for (int i = 0; i < count; i++) {
					final NewMsg newMsg = values.get(i);//原始
					String title = newMsg.mainGroupName + ">" + newMsg.name;
					if (title.contains(prefix)) {
						newValues.add(newMsg);
					}
				}
				results.values = newValues;
				results.count = newValues.size();
			}

			return results;
		}

		@Override
		protected void publishResults(CharSequence constraint, FilterResults results) {
			newPs = (List<NewMsg>) results.values;
			if (results.count > 0) {
				notifyDataSetChanged();
			} else {
				notifyDataSetInvalidated();
			}
		}
	}

	public List<NewMsg> getNewPs() {
		return newPs;
	}

	public void setNewPs(List<NewMsg> newPs) {
		this.newPs.clear();
		this.newPs.addAll(newPs);
	}
}
