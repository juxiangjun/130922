package com.eme.ims.audio;

	
public class Encoder implements Runnable {

	private volatile int leftSize = 0;
	private final Object mutex = new Object();
	private SpeexEncoder speex = new SpeexEncoder();
	private long ts;
	private Consumer consumer;
	private byte[] processedData = new byte[1024];
	private short[] rawdata = new short[1024];
	private volatile boolean isRecording;
	private static AACEncoder aacEncoder = null;
	
	public Encoder(Consumer consumer) {
		super();
		this.consumer = consumer;
		speex.init();
		
		if (aacEncoder == null) {
			aacEncoder = new AACEncoder();
			aacEncoder.init(64000, 1, 8000, 16, "/mnt/sdcard/tmp.aac");
		}
		
	}

	public void run() {

		android.os.Process
				.setThreadPriority(android.os.Process.THREAD_PRIORITY_URGENT_AUDIO);

		int getSize = 0;
		while (this.isRecording()) {
			if (isIdle()) {
				try {
					Thread.sleep(20);
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
				continue;
			}
			synchronized (mutex) {
				//getSize = speex.encode(rawdata, 0, processedData, leftSize);
				getSize = aacEncoder.encode(rawdata, processedData);
				setIdle();
			}
			if (getSize > 0) {
				consumer.putData(ts, processedData, getSize);
			}
		}
	}

	public void putData(long ts, short[] data, int size) {
		synchronized (mutex) {
			this.ts = ts;
			System.arraycopy(data, 0, rawdata, 0, size);
			this.leftSize = size;
		}
	}

	public boolean isIdle() {
		synchronized (mutex) {
			return leftSize == 0 ? true : false;
		}
	}

	public void setIdle() {
		leftSize = 0;
	}

	public void setRecording(boolean isRecording) {
		synchronized (mutex) {
			this.isRecording = isRecording;
		}
	}

	public boolean isRecording() {
		synchronized (mutex) {
			return isRecording;
		}
	}
}

