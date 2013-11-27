package com.dyt.lpclub.activity;

import java.io.File;

import android.app.Application;
import cn.jpush.android.api.JPushInterface;

import com.dyt.lpclub.global.GlobalContants;
import com.nostra13.universalimageloader.cache.disc.impl.UnlimitedDiscCache;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.ImageLoaderConfiguration;

public class LpClubApplication extends Application {

	@Override
	public void onCreate() {
		super.onCreate();
		JPushInterface.setDebugMode(true); //设置开启日志,发布时请关闭日志
		JPushInterface.init(this); // 初始化 JPush
		ImageLoaderConfiguration config = 
				new ImageLoaderConfiguration
				.Builder(this.getApplicationContext())
				.discCache(new UnlimitedDiscCache(new File(GlobalContants.CONST_DIR_CACHE)))
				.build();
		ImageLoader.getInstance().init(config);
	}
}
