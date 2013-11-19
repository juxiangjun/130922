package com.eme.ims.utils;

import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaRecorder;
import android.util.Log;

public class AudioRecorder extends StoppableThread {
	
	private final static String LOG_TAG = "AudioRecorder";
	private static AudioRecord audioRecord = null;
	
	private static int channel = AudioFormat.CHANNEL_CONFIGURATION_MONO;
	private static int encoding = AudioFormat.ENCODING_PCM_16BIT;
	private static int sampleRateInHz = 8000;
	private int BUFFER_SIZE = 0;
	
	private byte[] buffer ;
	int bufferReadResult = 0;
	
	private FlvFile flvFile = null;
	
	
	public AudioRecorder() {
		
		BUFFER_SIZE = AudioRecord.getMinBufferSize(sampleRateInHz, channel, encoding);
		audioRecord = new AudioRecord(MediaRecorder.AudioSource.MIC, 
				sampleRateInHz, channel, encoding, BUFFER_SIZE);
		flvFile = new FlvFile();
		
		Log.i(LOG_TAG, " length of the buffer is : " + BUFFER_SIZE * 3);
		
	}

	@Override
	public void run(){
		
		audioRecord.startRecording();
		long startTime = System.currentTimeMillis();
		int i=0;
		
		while(i<2000) {
			
			buffer = new byte[BUFFER_SIZE];
			bufferReadResult = audioRecord.read(buffer, 0, BUFFER_SIZE);
			if (bufferReadResult < BUFFER_SIZE) {
				byte[] temp = new byte[bufferReadResult];
				System.arraycopy(buffer, 0, temp, 0, bufferReadResult);
				buffer = temp;
			}
			
			long now = System.currentTimeMillis();
			long diff = now - startTime;
			startTime = now;
			
			int previous = 0;
			if (i>0) {
				previous = BUFFER_SIZE + 11 + 1;
			}
			
			FlvTag body = new FlvTag(previous, BUFFER_SIZE + 11 +1, Long.valueOf(diff).intValue(), buffer);
			flvFile.addBody(body);
			
			i++;
			
		}
		
		try {
			flvFile.saveToFile("/mnt/sdcard/test.flv");
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		audioRecord.stop();
	}


	public int getBufferSize(){
		return BUFFER_SIZE;
	}

	public void stopRecord() {
		try {
			this.flvFile.saveToFile("/mnt/sdcard/test.flv");
		} catch (Exception e) {
			e.printStackTrace();
		}
		this.stop = true;
	}
	
}
