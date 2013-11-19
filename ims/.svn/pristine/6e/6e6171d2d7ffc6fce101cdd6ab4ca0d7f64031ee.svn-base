package com.eme.ims.manager;

import java.io.File;
import java.io.IOException;

import android.content.Context;
import android.media.MediaPlayer;
import android.media.MediaRecorder;
import android.os.Environment;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;

import com.eme.ims.utils.PropertyConfig;

public class AudioManager {
	
	private static final String LOG_TAG = "MediaManager";
	
	private Context ctx;
	
	private MediaRecorder mRecorder;
	private MediaPlayer mPlayer;
	
	private boolean mStartRecording = true;
	private boolean mStartPlaying = true;
	
	private UIViewFactory uiViewFactory;
	
	private  String mFileName = null;
	
	private static AudioManager audioManager;
	
	public static AudioManager getInstance(Context ctx, PropertyConfig config) {
		if (audioManager == null) {
			audioManager = new AudioManager(ctx, config);
		}
		return audioManager;
	}
	/**
	 * private constructor.
	 * @param ctx
	 * @param mFileName
	 */
	private AudioManager(Context ctx, PropertyConfig config) {
		mFileName = Environment.getExternalStorageDirectory().getAbsolutePath()+"/"+config.getString("audio.fileName");
		this.ctx = ctx;
		uiViewFactory = UIViewFactory.INSTANCE;
		Log.d(LOG_TAG, "audio file name:" + mFileName);
	}
	
	/**
	 * 录音按钮
	 * @return
	 */
	public Button getRecorderButton() {
		return uiViewFactory.createTextButton(ctx, "Start recording", this.getOnRecordButtonClickListener());
	}
	
	/**
	 * 播放按钮
	 * @return
	 */
	public Button getPlayerButton() {
		return uiViewFactory.createTextButton(ctx, "Start playing", this.onPlayButtonClickListener());
	}
	
	/**
	 * 删除声音文件
	 * @return
	 */
	public Button getDeleteButton() {
		return uiViewFactory.createTextButton(ctx, "Delete Audio File", this.getOnDeleteButtonClickListener());
	}
	
	public MediaRecorder getMediaRecorder() {
		return this.mRecorder;
	}
	
	public MediaPlayer getMediaPlayer() {
		return this.mPlayer;
	}
	
	private boolean delete() {
		
		boolean result = false;
		
		try {
			File file = new File(mFileName);
			result = file.delete();
		} catch(Exception e) {
			Log.e(LOG_TAG, "failed to delete audio file.");
		}
		
		return result;
	}
	
	private void startRecording() {
    	Log.d(LOG_TAG, "start recording");
    	Log.d(LOG_TAG, mFileName);
        mRecorder = new MediaRecorder();
        mRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);
        mRecorder.setOutputFormat(MediaRecorder.OutputFormat.THREE_GPP);
        mRecorder.setOutputFile(mFileName);
        mRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB);
        
      

        try {
            mRecorder.prepare();
        } catch (IOException e) {
            Log.e(LOG_TAG, "recorder prepare() failed");
        }
        mRecorder.start();
    }

    private void stopRecording() {
        mRecorder.stop();
        mRecorder.release();
        mRecorder = null;
    }
    
    private OnClickListener getOnDeleteButtonClickListener() {
    	OnClickListener listener = new OnClickListener() {
	        public void onClick(View v) {
	        	delete();
	        }
	    };
	    return listener;
    }

    private OnClickListener getOnRecordButtonClickListener() {
	    OnClickListener listener = new OnClickListener() {
	        public void onClick(View v) {
	        	Button button = (Button) v;
	            onRecord(mStartRecording);
	            if (mStartRecording) {
	                button.setText("Stop recording");
	            } else {
	                button.setText("Start recording");
	            }
	            mStartRecording = !mStartRecording;
	        }
	    };
	    return listener;
    }
	
    private OnClickListener onPlayButtonClickListener() {
	    OnClickListener listener = new OnClickListener() {
	        public void onClick(View v) {
	        	Button btn = (Button) v;
	            onPlay(mStartPlaying);
	            if (mStartPlaying) {
	                btn.setText("Stop playing");
	            } else {
	                btn.setText("Start playing");
	            }
	            mStartPlaying = !mStartPlaying;
	        }
	    };
	    return listener;
    }
    
    public void playOnlineAudio(String url) {
    	mPlayer = new MediaPlayer();
    	Log.d(LOG_TAG, url);
        try {
            mPlayer.setDataSource(url);
            mPlayer.prepare();
            mPlayer.start();
        } catch (IOException e) {
            Log.e(LOG_TAG, "prepare() failed");
        }
    }

    private void startPlaying() {
        mPlayer = new MediaPlayer();
        Log.d(LOG_TAG, mFileName);
        try {
            //mPlayer.setDataSource(mFileName);
        	mPlayer.setDataSource("/mnt/sdcard/tmp.mp3");
            mPlayer.prepare();
            mPlayer.start();
        } catch (IOException e) {
            Log.e(LOG_TAG, "prepare() failed");
        }
    }
    
    private void stopPlaying() {
        mPlayer.release();
        mPlayer = null;
    }
	
	private void onRecord(boolean start) {
        if (start) {
            startRecording();
        } else {
            stopRecording();
        }
    }

    private void onPlay(boolean start) {
        if (start) {
            startPlaying();
        } else {
            stopPlaying();
        }
    }

}
