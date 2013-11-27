package com.dyt.lpclub.activity.adapter;

import java.util.List;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;

import com.dyt.lpclub.R;
import com.dyt.lpclub.activity.domain.GroupPic;
import com.dyt.lpclub.global.GlobalContants;
import com.dyt.lpclub.util.UtilString;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.display.RoundedBitmapDisplayer;

public class ImageAdapter extends BaseAdapter {
	private Context             mContext;
	private List<GroupPic> 		groupPicList;
	private LayoutInflater 		mInflater;
	private DisplayImageOptions options;
	
	public ImageAdapter(Context context, List<GroupPic> groupPicList) {
		this.mContext 		= 	context;
		this.groupPicList 	= 	groupPicList;
		this.mInflater 		= 	LayoutInflater.from(mContext);
		this.options 		= 	new DisplayImageOptions.Builder()
								.showStubImage(R.drawable.wallpaper_loading)
								.showImageForEmptyUri(R.drawable.wallpaper_loading)
								.showImageOnFail(R.drawable.wallpaper_loading)
								.cacheInMemory(true)
								.cacheOnDisc(true)
								.displayer(new RoundedBitmapDisplayer(8))
								.build();
	}

	@Override
	public int getCount() {
		return groupPicList.size();
	}

	@Override
	public GroupPic getItem(int position) {
		return groupPicList.get(position);
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	@Override
	public View getView(final int position, View convertView, ViewGroup parent) {
		final ImageHolder holder;
		if (convertView == null) {
			holder 		 = 	new ImageHolder();
			convertView  = 	mInflater.inflate(R.layout.layout_image, null);
			holder.pic 	 = 	(ImageView) convertView.findViewById(R.id.image);
			convertView.setTag(holder);
		} else {
			holder = (ImageHolder) convertView.getTag();
		}
		holder.pic.setImageResource(R.drawable.wallpaper_loading);
		final GroupPic pic = this.getItem(position);
		if (!UtilString.isEmpty(pic.thumb)) {
			ImageLoader.getInstance().displayImage(GlobalContants.CONST_STR_BASE_URL + pic.thumb, holder.pic, options);
		}
		return convertView;
	}

	class ImageHolder {
		public ImageView pic;
	}
}
