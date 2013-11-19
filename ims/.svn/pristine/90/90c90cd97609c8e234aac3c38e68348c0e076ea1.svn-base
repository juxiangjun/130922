package com.eme.ims.utils;

public class FlvTag {

	private byte[] previousTagSize;
	private byte[] bodyTag;
	private byte bodyHeader;
	private byte[] data;
	
	private HexCodeUtils hexCodeUtils;
	
	
	public FlvTag(int previous, int len, int time, byte[] buffer) {
		hexCodeUtils = HexCodeUtils.INSTANCE;
		this.previousTagSize = hexCodeUtils.getPreviousTag(previous+11);
  		this.bodyTag = hexCodeUtils.getBodyTag(len, time);
		this.bodyHeader = (byte) 0xB2;
		this.data = new byte[len-1];
		System.arraycopy(buffer, 0, data, 0, len-1);
	}
 	
	public byte[] getPreviousTagSize() {
		return previousTagSize;
	}
	
	public void setPreviousTagSize(byte[] previousTagSize) {
		this.previousTagSize = previousTagSize;
	}
	
	public byte[] getBodyTag() {
		return bodyTag;
	}
	
	public void setBodyTag(byte[] bodyTag) {
		this.bodyTag = bodyTag;
	}
	
	public byte getBodyHeader() {
		return bodyHeader;
	}
	
	public void setBodyHeader(byte bodyHeader) {
		this.bodyHeader = bodyHeader;
	}
	
	public byte[] getData() {
		return data;
	}
	
	public void setData(byte[] data) {
		this.data = data;
	}
	
	public byte[] getBytes() {
		byte[] result;
		int len = this.getData().length + 11 + 1 + 4;
		result = new byte[len];
		System.arraycopy(bodyTag, 0, result, 0, 11);
		result[11] = bodyHeader;
		
		System.arraycopy(data, 0, result, 12, data.length);
		System.arraycopy(this.previousTagSize, 0, result, data.length+12, 4);
		
		return result;
	}
	
}
