package com.dyt.lpclub.activity.view;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.HorizontalScrollView;

/**
 * @ProjectName							LpClub
 * @Author								C.xt				
 * @Version         					1.0.0
 * @CreateDate：							2013-6-30下午6:35:52
 * @JDK             					<JDK1.6>
 * Description:							
 */
public class HorizontalScrollViewWithListener extends HorizontalScrollView {

	private boolean isScrolling ;
	public HorizontalScrollViewWithListener(Context context,
			AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
	}

	public HorizontalScrollViewWithListener(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	public HorizontalScrollViewWithListener(Context context) {
		super(context);
		
	}

	public void setScorllListener(){
		
	}
	
	int scrollx;
	@Override
	public void computeScroll() {
		
		super.computeScroll();
		isScrolling = getScrollX() == scrollx;
		scrollx = getScrollX();

	}
	public boolean getIsScrolling(){
		return isScrolling;
	}
}

