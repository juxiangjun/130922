package com.dyt.lpclub.util;

import android.app.Activity;
import android.view.Window;

public class ViewUtil {
	/**
	 * 描述:设置该Activity为全屏
	 * 
	 * @author linqiang(866116)
	 * @Since 2012-5-24
	 * @param $this
	 */
	public static void fullscreen(Activity $this) {
		$this.requestWindowFeature(Window.FEATURE_NO_TITLE);
		// $this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
		// WindowManager.LayoutParams.FLAG_FULLSCREEN);
	}
}
