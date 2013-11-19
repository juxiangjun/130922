package com.ryong21.example.recorder;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.eme.ims.rtmp.RecorderClient;

public class Recorder {
	
	protected static Logger log = LoggerFactory.getLogger(Recorder.class);
		
	public static void main(String[] args) {
		
		String playFileName = "2.mp3";
		String saveAsFileName = "22.flv";
		
		String host = "ims.appeme.com";
		int port = 1935;
		String app = "vod";

		RecorderClient client = new RecorderClient();		
		client.setHost(host);
		client.setPort(port);
		client.setApp(app);	

		client.start(playFileName, saveAsFileName);
	}
}
