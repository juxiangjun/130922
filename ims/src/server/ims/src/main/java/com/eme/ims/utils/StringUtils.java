package com.eme.ims.utils;

public class StringUtils {

	public static boolean isBlank(String value) {
		return value == null || value.length()<1;
	}
}
