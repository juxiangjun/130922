package com.dyt.lpclub.activity.view;

import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.net.Uri;
import android.provider.MediaStore;
import android.util.AttributeSet;
import android.view.View;
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
 * 描述:设置界面
 * 
 * @author linqiang(866116)
 * @Since 2013-6-6
 */
public class AnnounceDetailAppView extends CommonAppView {

	private Context 				mContext;
	private DisplayImageOptions 	options;
	public AnnounceDetailAppView(Context paramContext) {
		super(paramContext);
		mContext = paramContext;
		init();
	}

	public AnnounceDetailAppView(Context paramContext, AttributeSet paramAttributeSet) {
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
		addView(R.layout.layout_announce_detail);
		this.options 		= 	new DisplayImageOptions.Builder()
							.showStubImage(R.drawable.wallpaper_loading)
							.showImageForEmptyUri(R.drawable.wallpaper_loading)
							.showImageOnFail(R.drawable.wallpaper_loading)
							.cacheOnDisc(true)
							.imageScaleType(ImageScaleType.EXACTLY)
							.build();
	}

	public void refreshAnnounce(Announce msg) {
		((TextView) this.findViewById(R.id.content)).setText(msg.content);
		((TextView) this.findViewById(R.id.newTitle)).setText(msg.title);
		((TextView) this.findViewById(R.id.time)).setText(msg.TIME);
//		((TextView) this.findViewById(R.id.readState)).setText("浏览次数:" + msg.state);
		ImageView pic = (ImageView) this.findViewById(R.id.pic);
		FrameLayout picLayout = (FrameLayout) this.findViewById(R.id.picLayout);
		ImageView playImg = (ImageView) this.findViewById(R.id.playImg);

		pic.setImageBitmap(null);
		pic.setOnClickListener(null);
		picLayout.setVisibility(View.GONE);
		playImg.setVisibility(View.GONE);
		final String urlVideo = msg.video;
		if (!UtilString.isEmpty(msg.video_pic)) {
			picLayout.setVisibility(View.VISIBLE);
			playImg.setVisibility(View.VISIBLE);
			ImageLoader.getInstance().displayImage(GlobalContants.CONST_STR_BASE_URL + msg.video_pic, pic, options);
			pic.setOnClickListener(new OnClickListener() {
				@Override
				public void onClick(View v) {
					// 播放视频
					if (!UtilString.isEmpty(urlVideo)) {
						Intent intent = new Intent(Intent.ACTION_VIEW);
						String type = "video/mp4";
						Uri name = Uri.parse(GlobalContants.CONST_STR_BASE_URL + urlVideo);
						intent.setDataAndType(name, type);

						intent.putExtra(MediaStore.EXTRA_SCREEN_ORIENTATION, ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
						mContext.startActivity(intent);
					} else {
						Toast.makeText(mContext, "只是个图片。。。", Toast.LENGTH_SHORT).show();
					}
				}
			});
		} else if (!UtilString.isEmpty(msg.pic)) {
			picLayout.setVisibility(View.VISIBLE);
			ImageLoader.getInstance().displayImage(GlobalContants.CONST_STR_BASE_URL + msg.pic, pic, options);
		}
	}

}
