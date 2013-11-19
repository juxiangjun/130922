package br.com.belocodigo.rtmpdump;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ProgressBar;

import com.eme.ims.audio.RecorderManager;
import com.eme.ims.utils.FileUtils;
import com.eme.ims.utils.HexCodeUtils;

public class Rtmpdump extends Activity {
    
	private static final String LOG_TAG = "Rtmpdump";
	
	private HexCodeUtils byteCodeUtils;
	boolean run = false;
	private ProgressBar progress;
	private EditText etUrl;
	private EditText etDest;
	
	private String url;
	private String dest;
	private static byte[] audio;
	private static int audioLength =0;
	private static int index = 9;
	
	
	Button btnRecord;
	private boolean stopRecording = true;
	
	public static final int STOPPED = 0;
	public static final int RECORDING = 1;
	int status = STOPPED;
	
	public RecorderManager recorderManager = new RecorderManager();
	
	public Rtmpdump() {
		byteCodeUtils = HexCodeUtils.INSTANCE; 
	}
	
	@Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        recorderManager.setMode(RecorderManager.TO_FILE);
        recorderManager.setRunning(true);
		Thread cmThread = new Thread(recorderManager);
		cmThread.start();
        this.initializeComponents();
    }
	
	private void startRecord() {
		if(status == STOPPED){
			recorderManager.setRecording(true);
			status = RECORDING;
		}
	}
	
	private void stopRecord() {
		if(status == RECORDING){
			recorderManager.setRecording(false);
			status = STOPPED;
		}
	}
	
	private OnClickListener getRecordButtonClickListener() {
		
		return new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				
				if (recorderManager.getMode() == RecorderManager.TO_SERVER) {
					RTMP.stop();
					RTMP.readyToPublish();
					try {
						Thread.sleep(1000);
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
				}
				
				if (!stopRecording) {
					btnRecord.setText("Start Record");
					stopRecording = true;
					stopRecord();
				} else {
					btnRecord.setText("stop Record");
					stopRecording = false;
					startRecord();
				}
			}
		};
	}
	
    
    
    private void initializeComponents() {
    	
    	Button btStart = (Button) findViewById(R.id.start);
        Button btStop = (Button) findViewById(R.id.stop);
        
        etUrl = (EditText) findViewById(R.id.url);
        etDest = (EditText) findViewById(R.id.dest);
        
        progress = (ProgressBar) findViewById(R.id.progress);
        progress.setVisibility(View.INVISIBLE);
        
        Button btnPublish = (Button) this.findViewById(R.id.btnPublish);
        btnRecord = (Button) this.findViewById(R.id.btnRecord);
        btnRecord.setOnClickListener(this.getRecordButtonClickListener());
        
        btnPublish.setOnClickListener(this.getBtnPublishClickListener());
        btStart.setOnClickListener(this.getBtnStartPlayClickListener());
        btStop.setOnClickListener(this.getBtnStopPlayClickListener());
        
    }
    
    private OnClickListener getBtnStopPlayClickListener()  {
    	
    	return
    	new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				progress.setVisibility(View.INVISIBLE);
				RTMP.stop();
				run = false;
			}
		};
    }
    private OnClickListener getBtnStartPlayClickListener() {
    	return 
    			new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				Log.d(LOG_TAG, "btn click");
				url = etUrl.getText().toString().trim();
				dest = etDest.getText().toString().trim();
				if (! run && url != "" && dest != "") {
					progress.setVisibility(View.VISIBLE);
					new Thread(new Runnable() {
						@Override
						public void run() {
							RTMP.dump(url, dest);
							int isConnected = RTMP.isConnected();
							Log.d(LOG_TAG, "connection status:" + String.valueOf(isConnected));
						}
					}).start();
					
					run = true;
				}
			}
		};
    }
    
    private OnClickListener getBtnPublishClickListener() {
		return 
		new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				
				boolean isFirstPackage=true;
				
				String filePath = "/mnt/sdcard/";
		    	String fileName = "dump.flv";
		    	audio = FileUtils.getFileBytes(filePath, fileName);
		    	audioLength = audio.length;
		    	Log.d(LOG_TAG, "audio length:"+audioLength);
		    	
				while(index<audioLength) {
					
					byte[] previousHeaderSize = new byte[4];
					
					for (int i=0; i<4; i++) {
						previousHeaderSize[i] = audio[index];
						index++;
					}
					byte[] header = new byte[11];
					
					for (int i=0; i<11; i++) {
						header[i] = audio[index];
						index++;
					}
					
					byte[] bodyOfHeader = new byte[3];
					bodyOfHeader[0] = header[4];
					bodyOfHeader[1] = header[3];
					bodyOfHeader[2] = header[2];
					
 					int bodySize = byteCodeUtils.HexToDegital(bodyOfHeader);
 					Log.d(LOG_TAG, "Body Size:"+bodySize);
 					
					
					byte[] body = new byte[bodySize];
					for (int i=0; i<bodySize; i++) {
						body[i] = audio[index];
						index++;
					}
					
					if (isFirstPackage) {
						bodySize = bodySize + 15 + 9;
					} else {
						bodySize = bodySize + 15;
					}
					
					int n = 0;
					
					byte[] array = new byte[bodySize];
					
					if (isFirstPackage) {
						
						RTMP.readyToPublish();
						
						try {
							Thread.sleep(1000);
						} catch (InterruptedException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
						
						
						for (int i=0; i<9; i++) {
							array[n] = audio[i];
							n++;
						}
						
						for (int i=0; i<previousHeaderSize.length; i++) {
							array[n] = previousHeaderSize[i];
							n++;
						}
					}
 
					
					
					
					for (int i=0; i<header.length; i++) {
						array[n] = header[i];
						n++;
					}
					
					for (int i=0; i<body.length; i++) {
						array[n] = body[i];
						n++;
					}
					 
					RTMP.publish(array);
					
					try {
						Thread.sleep(10);
					} catch (InterruptedException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
					
					
					isFirstPackage = false;
					Log.d(LOG_TAG, "current byte location:"+index);
					//break;
				}
			}
		};
	}
	
}