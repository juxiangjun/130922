package com.dyt.lpclub.activity.view;

import java.lang.ref.SoftReference;

import android.content.Context;
import android.graphics.Bitmap;
import android.os.Handler;
import android.os.Message;
import android.util.AttributeSet;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.dyt.lpclub.R;
import com.dyt.lpclub.activity.domain.User;
import com.dyt.lpclub.global.CommonCallBack;
import com.dyt.lpclub.global.GlobalContants;
import com.dyt.lpclub.util.UtilBitmap;
import com.dyt.lpclub.util.UtilString;

/**
 * 描述:
 * 
 * @author linqiang(866116)
 * @Since 2013-6-6
 */
public class UserDetailAppView extends CommonAppView {

	private TextView username, sex;
	private ImageView headImage;

	public UserDetailAppView(Context paramContext) {
		super(paramContext);
		init();
	}

	public UserDetailAppView(Context paramContext, AttributeSet paramAttributeSet) {
		super(paramContext, paramAttributeSet);
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
		addView(R.layout.layout_user_detail);
		username = (TextView) $(R.id.username);
		sex = (TextView) $(R.id.sex);
		headImage = (ImageView) $(R.id.imageHead);
		headImage.setImageResource(R.drawable.default_head);
	}

	public void refresh(final User user) {
		headImage.setImageResource(R.drawable.default_head);

		final Handler mHander = new Handler() {
			public void handleMessage(Message msg) {
				SoftReference<Bitmap> head = UtilBitmap.getIconCache().get(String.valueOf(user.id));
				headImage.setImageBitmap(head.get());
			};
		};

		CommonCallBack callBack = new CommonCallBack() {
			@Override
			public void invoke() {
				mHander.sendEmptyMessage(1);
			}
		};

		if (!UtilString.isEmpty(user.thumb)) {
			SoftReference<Bitmap> head = UtilBitmap.getIconCache().get(String.valueOf(user.id));
			if (head == null || head.get() == null) {
				UtilBitmap.loadIconInThread(String.valueOf(user.id), GlobalContants.BASE_DIR + user.thumb, GlobalContants.CONST_STR_BASE_URL + user.thumb, callBack);
			} else {
				headImage.setImageBitmap(head.get());
			}
		}

		username.setText(user.name);
		if (user.sex == 1) {
			sex.setText(R.string.male);
		} else {
			sex.setText(R.string.remale);
		}
	}

	private View $(int resId) {
		return findViewById(resId);
	}

}
