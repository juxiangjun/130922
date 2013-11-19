package br.com.belocodigo.rtmpdump;

public class RTMP {

    static {
    	System.loadLibrary("rtmp");
        System.loadLibrary("rtmpdump");
    }
	
	public static native void dump (String url, String dest);
	public static native int readyToPublish();
	public static native int publish(byte[] array);
	public static native void stop();
	public static native int isConnected();
	
}
