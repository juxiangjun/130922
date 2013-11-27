package com.dyt.lpclub.activity;

import android.app.Activity;
import android.os.Bundle;
import android.view.MotionEvent;
import android.view.View;
import android.widget.TextView;

import com.dyt.lpclub.R;

public class ActivityExit extends Activity {
	private String title, content;
	private TextView titleTV, contentTV;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.layout_exit_dialog);
		title = this.getIntent().getStringExtra("title");
		title = this.getIntent().getStringExtra("content");
		titleTV = (TextView) $(R.id.title);
		contentTV = (TextView) $(R.id.content);
		titleTV.setText(title);
		contentTV.setText(content);
	}

	@Override
	public boolean onTouchEvent(MotionEvent event) {
		finish();
		return true;
	}

	public void exitbutton1(View v) {
		this.finish();
	}

	public void exitbutton0(View v) {
		this.finish();
		ActivityMain.instance.returnLogin();
	}

	private View $(int resId) {
		return findViewById(resId);
	}

}
