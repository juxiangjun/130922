package eme;

import java.lang.reflect.InvocationTargetException;
 
import java.net.InetAddress;
import java.sql.Connection;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
  

import eme.method.EmeInvok;
 
import eme.util.ToolUtil;
import net.sf.json.JSONException;
import net.sf.json.JSONObject;

public class EmeUtil {
	
	public static JSONObject getResponseJson(String key) {
		
		return getResponseJson( key,null);
	}

	public static JSONObject getResponseJson(String key,Object info) {
		JSONObject jsonObject = JSONObject.fromObject(key);
		JSONObject rootobj = jsonObject.getJSONObject("root");
		JSONObject headobj = rootobj.getJSONObject("header");
		JSONObject bodyobj = rootobj.getJSONObject("body");
		String service = bodyobj.getString("service");
		String function = bodyobj.getString("function");
		String cid = headobj.getString("cid");
		JSONObject paramobj = bodyobj.getJSONObject("param");
		headobj.put("ack", "response");
		headobj.put("sender", ToolUtil.getIP()); 

		JSONObject resultjob = new JSONObject();
		JSONObject contentjob = new JSONObject();
		Object ob;
		  
		
		if(info!=null)
		      paramobj.element("info", info);
		 
		try {
         if(service.equals("S_TRADE")){
        	Connection conn = null;
			EmeDB db = new EmeDB();
			conn = db.getConnection();
			db.setConn(conn);
			JisContext jc = new JisContext(cid, paramobj, db); 			
			ob=EmeInvok.invok(service, function, jc);
         }
         else{        	 
        	 JisContext jc = new JisContext(cid, paramobj); 			
 			 ob=EmeInvok.emeinvok(service, function, jc);
        	 
         } 
			
			contentjob.element("status", "0");
			contentjob.element("content", ob);
			 
		}  
		
	 	          
	    catch(JSONException e){	   	       
	  			//e.printStackTrace();
	  			contentjob.element("status", "1");
	  			contentjob.element("content", "JSON对象错误！"); 
	  		} 
		  catch( SQLException e ) {
	  			//e.printStackTrace();
	  			contentjob.element("status", "1");
	  			contentjob.element("content", "访问数据库错误！");
	  		
	  		} 
		  catch( EmeBusinessException e ) {
	  		 
	  			contentjob.element("status", "a");
	  			contentjob.element("content", e.getMessage());
	  		
	  		} 
		  catch( Exception e ) {
	  			e.printStackTrace();	  			 
	  			contentjob.element("status", "1");
	  			contentjob.element("content", "未知错误！"+e.getMessage());
	  			 
	  		} 
		
		resultjob.element("result", contentjob);	 
		bodyobj.put("param", resultjob);
		headobj.put("datetime", ToolUtil.getDateTime());
		return jsonObject;

	}
	
	
	
	
	
	
  
}
