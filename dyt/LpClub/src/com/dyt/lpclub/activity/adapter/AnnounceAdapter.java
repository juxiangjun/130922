package com.dyt.lpclub.activity.adapter;

import java.util.List;

import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.net.Uri;
import android.provider.MediaStore;
import android.text.TextUtils.TruncateAt;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.dyt.lpclub.R;
import com.dyt.lpclub.activity.domain.Announce;
import com.dyt.lpclub.global.GlobalContants;
import com.dyt.lpclub.util.UtilString;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.assist.ImageScaleType;

/**
 * 描述:
 * 
 * @author linqiang(866116)
 * @Since 2013-6-7
 */
public class AnnounceAdapter extends BaseAdapter {

	private List<Announce> 			msgList;
	private LayoutInflater 			mInflater;
	private Context 				context;
	private DisplayImageOptions 	options;
	
	public AnnounceAdapter(Context mContext, List<Announce> groupList) {
		this.context 		= 	mContext;
		this.msgList 		= 	groupList;
		this.mInflater 		= 	LayoutInflater.from(mContext);
		this.options 		= 	new DisplayImageOptions.Builder()
									.showStubImage(R.drawable.wallpaper_loading)
									.showImageForEmptyUri(R.drawable.wallpaper_loading)
									.showImageOnFail(R.drawable.wallpaper_loading)
									.cacheOnDisc(true)
									.imageScaleType(ImageScaleType.EXACTLY)
									.build();
	}

	@Override
	public int getCount() {
		return msgList.size();
	}

	@Override
	public Object getItem(int position) {
		return msgList.get(position);
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	@Override
	public View getView(final int position, View convertView, ViewGroup parent) {

		final ViewHolder holder;
		if (convertView == null) {
			holder 				= 	new ViewHolder();
			convertView 		= 	mInflater.inflate(R.layout.layout_announce_item, null);
			holder.content 		= 	(TextView) convertView.findViewById(R.id.content);
			holder.newTitle 	= 	(TextView) convertView.findViewById(R.id.newTitle);
			holder.time 		= 	(TextView) convertView.findViewById(R.id.time);
			holder.readState 	= 	(TextView) convertView.findViewById(R.id.readState);
			holder.pic 			= 	(ImageView) convertView.findViewById(R.id.pic);
			holder.picLayout 	= 	(FrameLayout) convertView.findViewById(R.id.picLayout);
			holder.playImg 		= 	(ImageView) convertView.findViewById(R.id.playImg);
			
			holder.content.setEllipsize(TruncateAt.END);
			holder.content.setMaxLines(3);
			convertView.setTag(holder);
		} else {
			holder = (ViewHolder) convertView.getTag();
		}
		final Announce msg = (Announce) getItem(position);
		holder.content.setText(msg.content);
		holder.time.setText(msg.TIME);
//		holder.readState.setText("浏览次数:" + msg.state);
		holder.newTitle.setText(msg.title);
		holder.pic.setImageBitmap(null);
		holder.pic.setOnClickListener(null);
		holder.picLayout.setVisibility(View.GONE);
		holder.playImg.setVisibility(View.GONE);
		final String urlVideo = msg.video;

		if (!UtilString.isEmpty(msg.video_pic)) {
			holder.picLayout.setVisibility(View.VISIBLE);
			holder.playImg.setVisibility(View.VISIBLE);
			ImageLoader.getInstance().displayImage(GlobalContants.CONST_STR_BASE_URL + msg.video_pic, holder.pic, options);
			holder.pic.setOnClickListener(new OnClickListener() {
				@Override
				public void onClick(View v) {
					// 播放视频
					if (!UtilString.isEmpty(urlVideo)) {
						Intent intent = new Intent(Intent.ACTION_VIEW);
						String type = "video/mp4";
						Uri name = Uri.parse(GlobalContants.CONST_STR_BASE_URL + urlVideo);
						intent.setDataAndType(name, type);

						intent.putExtra(MediaStore.EXTRA_SCREEN_ORIENTATION, ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
						context.startActivity(intent);
					} else {
						Toast.makeText(context, "只是个图片。。。", Toast.LENGTH_SHORT).show();
					}
				}
			});
			return convertView;
		} else if (!UtilString.isEmpty(msg.pic)) {
			holder.picLayout.setVisibility(View.VISIBLE);
			ImageLoader.getInstance().displayImage(GlobalContants.CONST_STR_BASE_URL + msg.pic, holder.pic, options);
		}

		return convertView;

	}

	class ViewHolder {
		public TextView 	newTitle;
		public TextView 	content;
		public TextView 	time;
		public TextView 	readState;
		public ImageView 	pic;
		public ImageView 	playImg;
		public FrameLayout 	picLayout;
	}

}
