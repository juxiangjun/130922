package com.dyt.lpclub.activity.view;

import com.dyt.lpclub.util.UtilTelephone;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.view.Display;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.ListView;
import android.widget.SectionIndexer;
import android.widget.TextView;

public class SideBar extends View {
	private char[] 			l ;
	private SectionIndexer 	sectionIndexter 	= 	null ;
	private ListView 		list ;
	private TextView 		mDialogText ;
	private int 			m_nItemHeight ;
	private int				m_TextSize ;
	private Context 		mContext ;
	private DisplayMetrics 	metrics 			= 	new DisplayMetrics() ;
	public SideBar(Context context) {
		super(context) ;
		this.mContext  =  context;
		init() ;
	}

	public SideBar(Context context, AttributeSet attrs) {
		super(context, attrs) ;
		this.mContext  =  context ;
		init() ;
	}

	private void init() {
		l = new char[] { 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z' };
		final WindowManager windowManager = (WindowManager) mContext.getSystemService(Context.WINDOW_SERVICE);
		final Display display = windowManager.getDefaultDisplay();
		display.getMetrics(metrics);
		
		boolean isPortrait = display.getWidth() < display.getHeight();
		final int width = isPortrait ? display.getWidth() : display.getHeight();
		final int height = isPortrait ? display.getHeight() : display.getWidth();
		metrics.widthPixels = width;
		metrics.heightPixels = height;
		
		m_nItemHeight 	= 	UtilTelephone.dip2px(mContext, 14) ;
		m_TextSize   	= 	UtilTelephone.sp2px(mContext, 10) ;
	}

	public SideBar(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle) ;
		this.mContext  =  context ;
		init() ;
	}

	public void setListView(ListView _list) {
		list = _list;
	}
	
	public void setAdapter(SectionIndexer sectionIndexter){
		this.sectionIndexter = sectionIndexter;
	}

	public void setTextView(TextView mDialogText) {
		this.mDialogText = mDialogText;
	}

	public boolean onTouchEvent(MotionEvent event) {
		super.onTouchEvent(event);
		int i = (int) event.getY();
		int idx = i / m_nItemHeight;
		if (idx >= l.length) {
			idx = l.length - 1;
		} else if (idx < 0) {
			idx = 0;
		}
		if (event.getAction() == MotionEvent.ACTION_DOWN || event.getAction() == MotionEvent.ACTION_MOVE) {
			mDialogText.setVisibility(View.VISIBLE);
			mDialogText.setText("" + l[idx]);
			if (sectionIndexter == null) {
				sectionIndexter = (SectionIndexer) list.getAdapter();
			}
			int position = sectionIndexter.getPositionForSection(l[idx]);
			if (position == -1) {
				return true;
			}
			list.setSelection(position);
		} else {
			mDialogText.setVisibility(View.INVISIBLE);
		}
		return true;
	}

	protected void onDraw(Canvas canvas) {
		Paint paint = new Paint();
		paint.setColor(0xff595c61);
		paint.setTextSize(m_TextSize);
		paint.setTextAlign(Paint.Align.CENTER);
		float widthCenter = getMeasuredWidth() / 2;
		for (int i = 0; i < l.length; i++) {
			canvas.drawText(String.valueOf(l[i]), widthCenter, m_nItemHeight + (i * m_nItemHeight), paint);
		}
		super.onDraw(canvas);
	}
}
