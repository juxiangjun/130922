package com.dyt.lpclub.activity.view;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.TextView;

import com.dyt.lpclub.R;
import com.dyt.lpclub.activity.ActivityMain;

/**
 * 描述:消息界面
 * 
 * @author linqiang(866116)
 * @Since 2013-6-6
 */
public class LoadFailedAppView extends CommonAppView {

	private ActivityMain mContext;

	public LoadFailedAppView(Context paramContext) {
		super(paramContext);
		mContext = (ActivityMain) paramContext;
		init();
	}

	public LoadFailedAppView(Context paramContext, AttributeSet paramAttributeSet) {
		super(paramContext, paramAttributeSet);
		mContext = (ActivityMain) paramContext;
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
		addView(R.layout.layout_announce);
		findViewById(R.id.announceList).setVisibility(View.GONE);
		TextView view = (TextView)findViewById(R.id.failedText);
		view.setText(mContext.getString(R.string.failed_msg1));
		view.setVisibility(View.VISIBLE);
		view.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				mContext.firstLoad();
			}
		});
	}
}
