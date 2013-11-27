package com.dyt.lpclub.activity.imgbrowse;

import java.util.ArrayList;

import android.app.Activity;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.os.Parcelable;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import com.dyt.lpclub.R;
import com.dyt.lpclub.activity.imgbrowse.photoview.PhotoViewAttacher;
import com.dyt.lpclub.global.GlobalContants;
import com.dyt.lpclub.util.ViewUtil;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.assist.FailReason;
import com.nostra13.universalimageloader.core.assist.ImageScaleType;
import com.nostra13.universalimageloader.core.assist.SimpleImageLoadingListener;
import com.nostra13.universalimageloader.core.display.FadeInBitmapDisplayer;

public class ActivityImgBrowse extends Activity {
	private HackyViewPager viewPager;
	private TextView title;
	private ArrayList<String> imageUrls;
	private String nowUrl;
	private DisplayImageOptions options;
	private int total;
	private boolean showPic;
	private String userName;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		ViewUtil.fullscreen(this);
		setContentView(R.layout.main);

		imageUrls = getIntent().getStringArrayListExtra("imageUrls");
		nowUrl = getIntent().getExtras().getString("nowUrl");
		showPic = getIntent().getExtras().getBoolean("showPic", false);
		userName = getIntent().getExtras().getString("userName");

		if (null == imageUrls) {
			imageUrls = new ArrayList<String>();
		}
		viewPager = (HackyViewPager) findViewById(R.id.pager);
		findViewById(R.id.btn_back).setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				finish();
			}
		});
		title = (TextView) findViewById(R.id.layout_title);
		viewPager.setAdapter(new ImagePagerAdapter());
		total = imageUrls.size();
		if (showPic) {
			imageUrls.add(nowUrl);
			title.setText(userName);
		} else {
			int current = imageUrls.indexOf(nowUrl);
			viewPager.setCurrentItem(current);
			title.setText((current + 1) + "/" + total);
		}
		options = new DisplayImageOptions.Builder().showImageForEmptyUri(R.drawable.ic_empty).showImageOnFail(R.drawable.ic_error).cacheOnDisc(true)
				.imageScaleType(ImageScaleType.EXACTLY).bitmapConfig(Bitmap.Config.RGB_565).displayer(new FadeInBitmapDisplayer(300)).build();

		viewPager.setOnPageChangeListener(new OnPageChangeListener() {

			@Override
			public void onPageSelected(int arg0) {
				if (showPic) {
					title.setText(userName);
				} else {
					title.setText((arg0 + 1) + "/" + total);
				}
			}

			@Override
			public void onPageScrolled(int arg0, float arg1, int arg2) {

			}

			@Override
			public void onPageScrollStateChanged(int arg0) {

			}
		});

	}

	private class ImagePagerAdapter extends PagerAdapter {

		private LayoutInflater inflater;
		private PhotoViewAttacher attacher;
		private int currentPos = -1;

		public ImagePagerAdapter() {
			inflater = getLayoutInflater();
		}

		@Override
		public void destroyItem(ViewGroup container, int position, Object object) {
			((ViewPager) container).removeView((View) object);
		}

		@Override
		public void finishUpdate(View container) {
		}

		@Override
		public int getCount() {
			return imageUrls.size();
		}

		@Override
		public Object instantiateItem(ViewGroup view, int position) {
			View imageLayout = inflater.inflate(R.layout.item_gallery_image, view, false);
			ImageView imageView = (ImageView) imageLayout.findViewById(R.id.image);
			final ProgressBar spinner = (ProgressBar) imageLayout.findViewById(R.id.loading);
			final int pos = position;
			String url = imageUrls.get(position);
			if (showPic) {
				if (!url.startsWith("file:/")) {
					url = GlobalContants.CONST_STR_BASE_URL + url;
				}
			}
			ImageLoader.getInstance().displayImage(url, imageView, options, new SimpleImageLoadingListener() {
				@Override
				public void onLoadingStarted(String imageUri, View view) {
					spinner.setVisibility(View.VISIBLE);
				}

				@Override
				public void onLoadingFailed(String imageUri, View view, FailReason failReason) {
					String message = null;
					switch (failReason.getType()) {
					case IO_ERROR:
						message = "Input/Output error";
						break;
					case DECODING_ERROR:
						message = "Image can't be decoded";
						break;
					case NETWORK_DENIED:
						message = "Downloads are denied";
						break;
					case OUT_OF_MEMORY:
						message = "Out Of Memory error";
						break;
					case UNKNOWN:
						message = "Unknown error";
						break;
					}
					Toast.makeText(ActivityImgBrowse.this, message, Toast.LENGTH_SHORT).show();
					spinner.setVisibility(View.GONE);
				}

				@Override
				public void onLoadingComplete(String imageUri, View view, Bitmap loadedImage) {
					spinner.setVisibility(View.GONE);
					if (pos == currentPos)
						attacher.update();
				}
			});
			imageView.setTag(pos);
			((ViewPager) view).addView(imageLayout, 0);
			return imageLayout;
		}

		@Override
		public boolean isViewFromObject(View view, Object object) {
			return view.equals(object);
		}

		@Override
		public void restoreState(Parcelable state, ClassLoader loader) {
		}

		@Override
		public Parcelable saveState() {
			return null;
		}

		@Override
		public void startUpdate(View container) {
		}

		@Override
		public void setPrimaryItem(ViewGroup container, int position, Object object) {
			super.setPrimaryItem(container, position, object);
			if (position != currentPos) {
				currentPos = position;
				if (attacher != null)
					attacher.cleanup();
				View view = (View) object;
				ImageView imageView = (ImageView) view.findViewById(R.id.image);
				attacher = new PhotoViewAttacher(imageView);
			}
		}
	}

}
