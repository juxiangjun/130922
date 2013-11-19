package com.eme.ims.audio;

import java.util.Collections;
import java.util.LinkedList;
import java.util.List;
import com.eme.ims.utils.FlvTag;
import com.eme.ims.utils.FlvFile;

import br.com.belocodigo.rtmpdump.RTMP;
import android.util.Log;

public class RecorderManager implements Runnable, Consumer {
	
	private static final String LOG_TAG = "RecorderManager";
	private PcmRecorder recorder = null;
	
	/**数据处理类型*/
	public static final short TO_SERVER = 1;
	public static final short TO_FILE = 2;
	public static final short BOTH = 3;
	
	/**跟踪录音机状态*/
	private volatile boolean isRecording;
	private volatile boolean isRunning;
	private final Object mutex = new Object();
	private List<processedData> list;
	
	private short mode = TO_FILE;
	private FlvFile flvFile = null;
	private processedData data;
	
	private long basetime = 0;
	private int currentTime = 0;
	
	public RecorderManager() {
		super();
		list = Collections.synchronizedList(new LinkedList<processedData>());
		flvFile = new FlvFile();
		flvFile.init("/mnt/sdcard/test.flv");
	}
	
	@Override
	public void putData(long ts, byte[] buf, int size) {
		if (basetime == 0) {
			basetime = ts;
		}
		currentTime  = (int)(ts - basetime);
		processedData data = new processedData();
		data.ts = currentTime;
		data.size = size;
		System.arraycopy(buf, 0, data.processed, 0, size);
		list.add(data);
	}

	@Override
	public void run() {
		while (this.isRunning()) {
			synchronized (mutex) {
				while (!this.isRecording) {
					try {
						mutex.wait();
					} catch (InterruptedException e) {
						throw new IllegalStateException("Wait() interrupted!",
								e);
					}
				}
			}
			startPcmRecorder();
			while (this.isRecording()) {
				if (list.size() > 0) {
					publish();
					Log.d(LOG_TAG, "list size = "+list.size());
				} else {
					try {
						Thread.sleep(20);
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
				}
			}
			recorder.stop();
			while(list.size() > 0){
				publish();
				Log.d(LOG_TAG, "list size = "+list.size());
			}
			stop();
		}
	}
	
	private void startPcmRecorder(){
		recorder = new PcmRecorder(this);
		recorder.setRecording(true);
		Thread th = new Thread(recorder);
		th.start();
	}
	
	public void stop() {
		RTMP.stop();
	}
	
	private void publish() {
		processedData data = list.remove(0);
		int previousTagSize = data.size+1;
		int dataSize = data.size+ 1;
		FlvTag tag = new FlvTag(previousTagSize, dataSize , (int)data.ts, data.processed);
		
		switch (this.mode) {
			case TO_SERVER:
				this.publishToServer(tag);
				break;
			case TO_FILE:
				this.publishToFile(tag);
				break;
			case BOTH:
				this.publishToServer(tag);
				this.publishToFile(tag);
				break;
			default:
				this.publishToServer(tag);
		}
	}
	
	private void publishToFile(FlvTag tag) {
		try {
			flvFile.writeTag(tag);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	private void publishToServer(FlvTag tag) {
		byte[] data = tag.getBytes();
		RTMP.publish(data);
	}
	
	public boolean isRunning() {
		synchronized (mutex) {
			return isRunning;
		}
	}

	public void setRunning(boolean isRunning) {
		synchronized (mutex) {
			this.isRunning = isRunning;
			if (this.isRunning) {
				mutex.notify();
			}
		}
	}

	public void setRecording(boolean isRecording) {
		synchronized (mutex) {
			this.isRecording = isRecording;
			if (this.isRecording) {
				mutex.notify();
			}
		}
	}

	public boolean isRecording() {
		synchronized (mutex) {
			return isRecording;
		}
	}
	
	public short getMode() {
		return mode;
	}

	public void setMode(short mode) {
		this.mode = mode;
	}
	
	class processedData {
		private long ts;
		private int size;
		private byte[] processed = new byte[256];
	}
}
