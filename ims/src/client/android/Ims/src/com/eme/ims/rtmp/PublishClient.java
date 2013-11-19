package com.eme.ims.rtmp;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.red5.io.utils.ObjectMap;
import org.red5.server.messaging.IMessage;
import org.red5.server.net.rtmp.INetStreamEventHandler;
import org.red5.server.net.rtmp.RTMPClient;
import org.red5.server.net.rtmp.event.Notify;
import org.red5.server.net.rtmp.status.StatusCodes;
import org.red5.server.service.IPendingServiceCall;
import org.red5.server.service.IPendingServiceCallback;
import org.red5.server.stream.message.RTMPMessage;
import org.red5.server.stream.provider.FileProvider;

import com.eme.ims.manager.UIViewFactory;

import android.content.Context;
import android.media.MediaRecorder;
import android.os.Environment;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;

public class PublishClient  implements INetStreamEventHandler, IPendingServiceCallback{

	
	
	private final static String LOG_TAG = "PublishClient";
	
	private Context ctx;
	
	private List<IMessage> frameBuffer = new ArrayList<IMessage>();

	public static final int STOPPED = 0;

	public static final int CONNECTING = 1;

	public static final int STREAM_CREATING = 2;

	public static final int PUBLISHING = 3;

	public static final int PUBLISHED = 4;
	
	private boolean CONNECTED = false;

	private String host = "192.168.7.210";

	private int port = 1935;

	private String app = "oflaDemo";

	private int state;

	private String publishName;

	private int streamId;

	private String publishMode;
	
	private RTMPClient rtmpClient;
	
	private static PublishClient publishClient = null;
	
	private UIViewFactory factory= null;
	
	public synchronized static PublishClient getInstance(Context ctx) {
		
		if  (publishClient == null) {
			publishClient = new PublishClient(ctx);
		}
		
		return publishClient;
	}
	
	private PublishClient (Context ctx) {
		this.ctx = ctx;
		factory = UIViewFactory.INSTANCE;
	}
	
	
	public Button createRed5ConnectionButton() {
		return factory.createTextButton(ctx, "Connect", getBtnOnConnectRed5ClickListner());
	}
	
	private OnClickListener getBtnOnConnectRed5ClickListner() {
		return new View.OnClickListener() {
			
			@Override
			public void onClick(View view) {
				// TODO Auto-generated method stub
				Button btn = (Button) view;
				if (CONNECTED) {
					stop();
					btn.setText("Connect");
					CONNECTED = false;
				} else {
					try {
						start("stream1383297951682", "live", new String[] {"stream1383297951682", "stream1383296563206"});
						CONNECTED = true;
						btn.setText("Disconnect");
					} catch (Exception e) {
						e.printStackTrace();
					} 
				}	
			}
		};
	}
	
	public synchronized void start(String publishName, String publishMode, Object[] params)
			throws IOException, InterruptedException {
		state = CONNECTING;
		this.publishName = publishName;
		this.publishMode = publishMode;
		rtmpClient = new RTMPClient();
		
		Map<String, Object> defParams = rtmpClient.makeDefaultConnectionParams(host, port, app);
		rtmpClient.connect(host, port, defParams, this, params);
		
		String fileName = Environment.getExternalStorageDirectory().getAbsolutePath()+"/tmp.3gp";
		IMessage msg = null;
		int timestamp = 0;
		int lastTS = 0;
		
		/*
		MediaRecorder mRecorder = new MediaRecorder();
        mRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);
        mRecorder.setOutputFormat(MediaRecorder.OutputFormat.THREE_GPP);
        mRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB);
        mRecorder.setOutputFile(fileName);
        
        mRecorder.prepare();
        mRecorder.start();
        */
		Thread.sleep(2000);
		
		Log.d(LOG_TAG, "waiting for publish stream");
        
        FileProvider fp = new FileProvider(new File(fileName));
        
        while(true){
			msg = fp.pullMessage(null);			
			if(msg == null){
				this.stop();
				break;
			}
			timestamp = ((RTMPMessage)msg).getBody().getTimestamp();
			Thread.sleep((timestamp - lastTS));
			lastTS = timestamp;
			pushMessage( msg);
		}	
        stop();
        
	}

	public synchronized void stop() {
		if (state >= STREAM_CREATING) {
			rtmpClient.disconnect();
		}
		state = STOPPED;
	}

	synchronized public void pushMessage(IMessage message) throws IOException {
		if (state >= PUBLISHED && message instanceof RTMPMessage) {
			RTMPMessage rtmpMsg = (RTMPMessage) message;
			rtmpClient.publishStreamData(streamId, rtmpMsg);
		} else {
			frameBuffer.add(message);
		}
	}

	public synchronized void onStreamEvent(Notify notify) {
		Log.d(LOG_TAG+"onStreamEvent: {}", notify.toString());
		ObjectMap<?, ?> map = (ObjectMap<?, ?>) notify.getCall().getArguments()[0];
		String code = (String) map.get("code");
		Log.d(LOG_TAG+"<:{}", code);
		if (StatusCodes.NS_PUBLISH_START.equals(code)) {
			state = PUBLISHED;
			while (frameBuffer.size() > 0) {
				rtmpClient.publishStreamData(streamId, frameBuffer.remove(0));
			}
		}
	}

	public synchronized void resultReceived(IPendingServiceCall call) {
		Log.d(LOG_TAG+"resultReceived:> {}", call.getServiceMethodName());
		if ("connect".equals(call.getServiceMethodName())) {
			state = STREAM_CREATING;
			rtmpClient.createStream(this);
		} else if ("createStream".equals(call.getServiceMethodName())) {
			state = PUBLISHING;
			Object result = call.getResult();
			if (result instanceof Integer) {
				Integer streamIdInt = (Integer) result;
				streamId = streamIdInt.intValue();				
				rtmpClient.publish(streamIdInt.intValue(), publishName, publishMode, this);
			} else {
				rtmpClient.disconnect();
				state = STOPPED;
			}
		}
	}
	

	public String getApp() {
		return app;
	}

	public void setApp(String app) {
		this.app = app;
	}

	public String getHost() {
		return host;
	}

	public void setHost(String host) {
		this.host = host;
	}

	public int getPort() {
		return port;
	}

	public void setPort(int port) {
		this.port = port;
	}

	public int getState() {
		return state;
	}

	public void setState(int state) {
		this.state = state;
	}

	public String getPublishName() {
		return publishName;
	}

	public void setPublishName(String publishName) {
		this.publishName = publishName;
	}

	public int getStreamId() {
		return streamId;
	}

	public void setStreamId(int streamId) {
		this.streamId = streamId;
	}

	public String getPublishMode() {
		return publishMode;
	}

	public void setPublishMode(String publishMode) {
		this.publishMode = publishMode;
	}
	
	
	
	
}
