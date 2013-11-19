package com.eme.ims.utils;

import java.math.BigInteger;

import android.util.Log;

public enum HexCodeUtils {

	INSTANCE;
	private String LOG_TAG = "ByteCodeUtils";
	
	public byte[] getBodyTag(int len, int time) {
		
		byte[] result = new byte[11];
		result[0] = 0x08;
		
		String hex = Integer.toHexString(len);
		
		if (hex.length() % 2 != 0) {
			hex = "0"+hex;
		}
		
		byte[] dataLength = this.getFixedLengthHex(this.hexFromString(hex), 3);
		
		int i=1;
		for (byte data: dataLength) {
			result[i] = data;
			i++;
		}
		
		hex = Integer.toHexString(time);
		if (hex.length() % 2 != 0) {
			hex = "0"+hex;
		}
		
		byte[] timestamp = this.getFixedLengthHex(this.hexFromString(hex), 3);
		
		for (byte data: timestamp) {
			result[i] = data;
			i++;
		}
		
		for (i=8; i<11; i++) {
			result[i] = 0x00;
		}
		
		return result;
	}
	
	public byte[] getFixedLengthHex(byte[] value, int size) {
		
		int len  = value.length;
		
		if (size <= len) {
			return value;
		}
		
		byte[] result = new byte[size];
		
		int differencial = size - len;
		
	
		for (int i=0; i<differencial; i++) {
			result[i] = 0x00;
		}
		
		
	
		for (byte data : value) {
			result[differencial] = data;
			differencial++;
		}
		
		return result;
	}
	
	public String[] splitStrings(String value, int size) {
        int len = value.length();
        int group = len / size;
        int remain = len % size;
        
        if (remain>0) {
            group = group + 1;
        }
        
        String[] result = new String[group];
        
        for (int i=0; i<group; i++) {
            if (remain>0 && i==0) {
                result[i] = value.substring(0, remain);
                value = value.substring(remain, len);
                continue;
            } 

            result[i] = value.substring(0, size);
            len = value.length(); 
            value = value.substring(size, len);
        }
        return result;
    }

	
	private byte[] hexFromString(final String encoded) {
	    if ((encoded.length() % 2) != 0) 
	        throw new IllegalArgumentException("Input string must contain an even number of characters");

	    final byte result[] = new byte[encoded.length()/2];
	    final char enc[] = encoded.toCharArray();
	    for (int i = 0; i < enc.length; i += 2) {
	        StringBuilder curr = new StringBuilder(2);
	        curr.append(enc[i]).append(enc[i + 1]);
	        result[i/2] = (byte) Integer.parseInt(curr.toString(), 16);
	    }
	    return result;
	}
	
	public byte[] getPreviousTag(int value) {
		byte[] result = {0x00, 0x00, 0x00, 0x00};
		
		if (value>0) {
			
			result = new byte[4];
			
			String hex = Integer.toHexString(value);
			if (hex.length() % 2 != 0) {
				hex = "0"+hex;
			}
			
			result= this.getFixedLengthHex(this.hexFromString(hex), 4);
		}
		return result;
	}
	
	public int HexToDegital(byte[] array) {
		int result = 0;
		char hexDigit[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
	            'A', 'B', 'C', 'D', 'E', 'F' };
	    StringBuffer buf = new StringBuffer();
	    for (int j = 0; j < array.length; j++) {
	        buf.append(hexDigit[(array[j] >> 4) & 0x0f]);
	        buf.append(hexDigit[array[j] & 0x0f]);
	    }
	    String hex = buf.toString();
		BigInteger val = new BigInteger(hex, 16);
		result = val.intValue();
		return result;
	}
}
