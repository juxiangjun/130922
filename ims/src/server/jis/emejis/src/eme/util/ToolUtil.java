package eme.util;

import java.net.InetAddress;
import java.text.SimpleDateFormat;
import java.util.Date;

import net.sf.json.JSONObject;

public class ToolUtil {
	public static boolean hasParm(JSONObject paramobj, String key) {
		String value = null;
		if (paramobj.containsKey(key))
			value = paramobj.getString(key);
		if (value == null || "".equals(value))
			return false;
		else
			return true;

	}
	
	
	private static String ip;
	public static String getDateTime() {
		Date date = new Date();
		SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");
		String time = df.format(date);
		return time;
	}
	public static String getDateTime2() {
		Date date = new Date();
		SimpleDateFormat df = new SimpleDateFormat("yyyyMMddhhmmss");
		String time = df.format(date);
		return time;
	}
	public static String getIP()  {
		
		if( ip==null)
		{try{
		InetAddress localhost = InetAddress.getLocalHost();
		  ip = localhost.getHostAddress();}
		catch(Exception e){}		
		return ip;}
		else
			return ip;
	}

	public static String getCid(String key){
		 
		String cid= JSONObject.fromObject(key).getJSONObject("root").getJSONObject("header").getString("cid");
		 
		return cid;
		
	}
	public static String getServic(String key){
		 
		  
		String service = JSONObject.fromObject(key).getJSONObject("root").getJSONObject("body").getString("service");
		 
		return service;
		
	}
	
	
	
}
