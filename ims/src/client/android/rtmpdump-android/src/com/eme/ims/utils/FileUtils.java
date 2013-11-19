package com.eme.ims.utils;

import java.io.File;
import java.io.FileInputStream;

public class FileUtils {

	
	@SuppressWarnings("resource")
	public static byte[] getFileBytes(String filePath, String fileName) {
		
		File file = new File(filePath+fileName);
		int fileLength = (int) file.length();
		byte[] result = new byte[fileLength];
		FileInputStream fis;
		try {
			fis = new FileInputStream(file);
			fis.read(result);
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return result;
	}
	
}
