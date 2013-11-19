package com.eme.ims;

import java.io.InputStream;

import android.app.Activity;
import android.media.MediaPlayer;
import android.media.MediaRecorder;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.Menu;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;

import com.eme.ims.codec.Message;
import com.eme.ims.codec.MsgProtocol;
import com.eme.ims.handler.IMessageAdapter;
import com.eme.ims.manager.AudioManager;
import com.eme.ims.manager.ChatManager;
import com.eme.ims.rtmp.PublishClient;
import com.eme.ims.utils.PropertyConfig;

public class ImsMainActivity extends Activity implements IMessageAdapter {
	
	
	private AudioManager audioManager;
	private ChatManager chatManager;
	private PublishClient publishClient;
	
	private MediaRecorder mRecorder;
	private MediaPlayer mPlayer;
	
	private Button mPlayButton;
	private Button mRecordButton;
	private Button mDeleteButton;
	private Button mConnectToRed5Button;
	private LinearLayout llMessage;
	
	private static final String LOG_TAG = "ImsMainActivity";
    
	private PropertyConfig config;
	private static Handler handler = new Handler();
	private Message message;
	
	
    @Override
    protected void onCreate (Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        InputStream tmp = null;
        try {
			tmp = this.getResources().openRawResource(R.raw.client);
			config = new PropertyConfig(tmp);
			
			if (config.getKeyCount()==0) {
				Log.e(LOG_TAG, "did'n find configuration files. this app exits.");
				System.exit(0);
			}
			
		} catch (Exception e) {
			e.printStackTrace();
		}
        message = new Message();
        message.setFrom(config.getString("from"));
        message.setTo(config.getString("to"));
        message.setDirection(MsgProtocol.MsgDirection.CLIENT_TO_SERVER);
       
        
        audioManager = AudioManager.getInstance(this, config);
        chatManager = ChatManager.getInstance(this, this, this.config, message);
        publishClient = PublishClient.getInstance(this);
        
        this.mRecorder = audioManager.getMediaRecorder();
        this.mPlayer = audioManager.getMediaPlayer();
        
        LinearLayout ll = new LinearLayout(this);
        ll.setOrientation(LinearLayout.VERTICAL);
        
        mRecordButton = this.audioManager.getRecorderButton();
        ll.addView(mRecordButton,
            new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT,
                0));
        
        mPlayButton = this.audioManager.getPlayerButton();
        ll.addView(mPlayButton,
            new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT,
                0));
        
        
        mDeleteButton = this.audioManager.getDeleteButton();
        ll.addView(mDeleteButton,
                new LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                    0));
        
        mConnectToRed5Button = publishClient.createRed5ConnectionButton();
        
        ll.addView(mConnectToRed5Button,
                new LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                    0));
        
        llMessage = this.chatManager.getChatLinearLayout();
        ll.addView(llMessage,
        		new LinearLayout.LayoutParams(
                        ViewGroup.LayoutParams.WRAP_CONTENT,
                        ViewGroup.LayoutParams.WRAP_CONTENT,
                        0));
        
        
        
        
        setContentView(ll);

    }
    
    
    
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }
    
    @Override
    public void onPause() {
        super.onPause();
        if (mRecorder != null) {
            mRecorder.release();
            mRecorder = null;
        }

        if (mPlayer != null) {
            mPlayer.release();
            mPlayer = null;
        }
        
        if (chatManager != null) {
        	//chatManager.disconnect();
        }
    }
    
	@Override
	public void onReceivedP2PMessage(final Message message) {
		Log.d(LOG_TAG, "Enter onReceivedP2PMessage method.");
		handler.post(new Runnable() {
            @Override
            public void run() {
            	if (message.getType() == MsgProtocol.MsgType.VOICE) {
            		audioManager.playOnlineAudio(message.getContents());
            	}
            	Log.d(LOG_TAG, message.getContents());
            }
        });
	}

	@Override
	public void onGetP2PMessageResponse(final Message message) {
		Log.d("ImsMainActivity", "Enter onGetP2PMessageResponse method.");
		handler.post(new Runnable() {
            @Override
            public void run() {
            	Log.d(LOG_TAG, message.getContents());
            }
        });
	}
}
