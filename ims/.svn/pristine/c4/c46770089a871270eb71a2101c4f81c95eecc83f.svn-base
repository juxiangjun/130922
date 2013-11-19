package com.eme.ims.manager;

import android.content.Context;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;

public enum UIViewFactory {
	INSTANCE;
	
	public Button createTextButton(final Context ctx, final String text,  final OnClickListener listener) {
		Button button = null;
		class CustomizedButton extends Button {
	        public CustomizedButton() {
	            super(ctx);
	            setText(text);
	            setOnClickListener(listener);
	        }
	    }
		button = new CustomizedButton();
		return button;
	}
	
	public EditText createEditText(final Context ctx, final String hint) {
		EditText editText = null;
		
		class CustomizedEditText extends EditText {

			public CustomizedEditText() {
				super(ctx);
				this.setHint(hint);
			}
		}
		
		editText = new CustomizedEditText();
		
		return editText;
	}
}
