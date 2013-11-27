package com.dyt.lpclub.activity.adapter;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Filter;
import android.widget.Filterable;
import android.widget.ImageView;
import android.widget.TextView;

import com.dyt.lpclub.R;
import com.dyt.lpclub.activity.domain.Group;
import com.dyt.lpclub.activity.domain.GroupViewHolder;
import com.dyt.lpclub.global.GlobalContants;
import com.dyt.lpclub.util.UtilString;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.display.RoundedBitmapDisplayer;

public class GroupChildAdapter extends BaseAdapter implements Filterable {

	private List<Group> 		groupList;
	private LayoutInflater 		mInflater;
	private List<Group> 		newgl;
	private DisplayImageOptions options;

	public GroupChildAdapter(Context mContext, List<Group> groupList) {
		this.groupList 	= 	groupList;
		this.mInflater 	= 	LayoutInflater.from(mContext);
		this.newgl		= 	new ArrayList<Group>(groupList);
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
		return newgl.size();
	}

	@Override
	public Object getItem(int position) {
		return newgl.get(position);
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

			convertView = mInflater.inflate(R.layout.layout_group_item, null);
			holder.imageHead = (ImageView) convertView.findViewById(R.id.imageHead);
			holder.groupName = (TextView) convertView.findViewById(R.id.groupName);
			holder.desc = (TextView) convertView.findViewById(R.id.desc);
			holder.desc1 = (TextView) convertView.findViewById(R.id.desc1);
			holder.desc1.setVisibility(View.VISIBLE);
			convertView.setTag(holder);

		} else {
			holder = (GroupViewHolder) convertView.getTag();
		}
		Group group = (Group) getItem(position);
		if (position % 2 == 0) {
			convertView.setBackgroundColor(Color.parseColor("#E3E3E3"));
		} else {
			convertView.setBackgroundColor(Color.parseColor("#f1f1f1"));
		}
		holder.groupName.setText(group.getName());
		holder.desc.setText("共" + String.valueOf(group.getMemberCount()) + "人");
		holder.desc1.setText(group.getRemark());

		holder.imageHead.setImageResource(R.drawable.default_group);
		if (!UtilString.isEmpty(group.getPic())) {
			ImageLoader.getInstance().displayImage(GlobalContants.CONST_STR_BASE_URL + group.getPic(), holder.imageHead, options);
		}

		return convertView;

	}

	private ArrayFilter filter;

	private class ArrayFilter extends Filter {

		@Override
		protected FilterResults performFiltering(CharSequence prefix) {
			FilterResults results = new FilterResults();
			if (UtilString.isEmpty(prefix)) {//没有过滤符就不过滤  
				ArrayList<Group> l = new ArrayList<Group>(groupList);
				results.values = l;
				results.count = l.size();
			} else {
				final ArrayList<Group> values = new ArrayList<Group>(groupList);
				final int count = values.size();
				final ArrayList<Group> newValues = new ArrayList<Group>(count);
				for (int i = 0; i < count; i++) {
					final Group group = values.get(i);//原始
					if (group.getName().contains(prefix)) {
						newValues.add(group);
					}
				}
				results.values = newValues;
				results.count = newValues.size();
			}

			return results;
		}

		@Override
		protected void publishResults(CharSequence constraint, FilterResults results) {
			newgl = (List<Group>) results.values;
			if (results.count > 0) {
				notifyDataSetChanged();
			} else {
				notifyDataSetInvalidated();
			}
		}
	}

	@Override
	public Filter getFilter() {
		if (filter == null) {
			filter = new ArrayFilter();
		}
		return filter;
	}

	public void setNewgl(List<Group> newgl) {
		this.newgl = new ArrayList<Group>(newgl);
	}

}
