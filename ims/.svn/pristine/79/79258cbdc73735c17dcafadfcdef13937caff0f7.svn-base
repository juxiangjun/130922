package com.eme.ims.audio;

public class AACEncoder {

	/**
     * Native JNI - initialize AAC encoder
     *
     */
    public native void init(int bitrate, int channels,
            int sampleRate, int bitsPerSample, String outputFile);

    /**
     * Native JNI - encode one or more frames
     *
     */
    public native int encode(short[] inputArray, byte[] outputByte);
    //public native int encode(short[] inputArray);

    /**
     * Native JNI - uninitialize AAC encoder and flush file
     *
     */
    public native void uninit();

    static {
        System.loadLibrary("aac-encoder");
    }
}
