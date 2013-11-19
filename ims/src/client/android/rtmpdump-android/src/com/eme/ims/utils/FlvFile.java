package com.eme.ims.utils;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class FlvFile {

	private byte[] flvHeader = {0x46, 0x4C, 0x56, 0x01, 0x04, 0x00, 0x00, 0x00, 0x09};
	private byte[] flvPreviousTag = {0x00, 0x00, 0x00, 0x00};
	private List<FlvTag> tags;
	private String fileName = "";
	private BufferedOutputStream bos;
	
	public FlvFile() {
		
	}
	
	public void init(String fileName) {
		this.fileName = fileName;
		
		File file = new File(fileName);
		
		if (file.exists()) {
			file.delete();
		}
		
		try {
			file.createNewFile();
			bos =  new BufferedOutputStream(new FileOutputStream(file));
			bos.write(flvHeader);
			bos.write(flvPreviousTag);
			bos.flush();
		} catch (IOException e) {
			e.printStackTrace();
		}
		
	}
	
	public void addBody(FlvTag tag) {
		
		if (this.tags == null) {
			tags = new ArrayList<FlvTag>();
		}
		
		tags.add(tag);
	}
	
	public void writeTag(FlvTag tag) throws Exception{
		
		bos.write(tag.getBodyTag());
		bos.write(tag.getBodyHeader());
		bos.write(tag.getData());
		bos.write(tag.getPreviousTagSize());
		bos.flush();
		
	}
	
	
	public void saveToFile(String fileName) throws Exception {
		
		this.fileName = fileName;
		for (FlvTag tag: tags) {
			this.writeTag(tag);
		}
		bos.close();
		
	}
	
	public byte[] getFlvHeader() {
		return flvHeader;
	}
	
	public void setFlvHeader(byte[] flvHeader) {
		this.flvHeader = flvHeader;
	}

	public List<FlvTag> getBodyList() {
		return tags;
	}

	public void setBodyList(List<FlvTag> bodyList) {
		this.tags = bodyList;
	}
}
