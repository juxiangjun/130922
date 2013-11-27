package eme;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.InetAddress;
import java.sql.Connection;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.ResourceBundle;

import javax.servlet.ServletException;
import javax.sql.DataSource;

import com.alibaba.druid.pool.DruidDataSource;

import eme.xml.EmeRoot;
import eme.xml.Function;
import eme.xml.Service;
import net.sf.json.JSONException;
import net.sf.json.JSONObject;

public class EmeUtil2 {

	public static JSONObject getResponseJson(String key) {
		JSONObject jsonObject = JSONObject.fromObject(key);
		JSONObject rootobj = jsonObject.getJSONObject("root");
		JSONObject headobj = rootobj.getJSONObject("header");
		JSONObject bodyobj = rootobj.getJSONObject("body");
		String service = bodyobj.getString("service");
		String function = bodyobj.getString("function");
		String cid = headobj.getString("cid");
		JSONObject paramobj = bodyobj.getJSONObject("param");
		headobj.put("ack", "response");
		headobj.put("sender", getIP());
		//headobj.put("datetime", getDateTime());

		JSONObject resultjob = new JSONObject();
		JSONObject contentjob = new JSONObject();
		Object ob;
		Connection conn = null;
		boolean readonly = true;
		try {

			//Service ser = EmeXmlUtil.getService(service);
			//Function fun = EmeXmlUtil.getFunction(ser, function);
			 Service ser = null;
			 Function fun = null;

			readonly = fun.getReadonly();
			EmeDB db = new EmeDB();
			conn = db.getConnection();
			db.setConn(conn);
			conn.setReadOnly(fun.getReadonly());
			if (!readonly) {
				conn.setAutoCommit(false);
			}

			Class<?> clazz = Class.forName(ser.getValue());

			JisContext jc = new JisContext(cid, paramobj, db);

			 
			Method method = clazz.getMethod(fun.getValue(), JisContext.class);

			if (!fun.getReadonly()) {
				conn.setAutoCommit(false);
			}

			ob = method.invoke(clazz.newInstance(), jc);

			if (!readonly) {
				conn.commit();
			}

			conn.close();

			contentjob.element("status", "0");
			contentjob.element("content", ob);
			resultjob.element("result", contentjob);
			bodyobj.put("param", resultjob);

		 
		}  
		
		catch (InvocationTargetException e) {
	        
	          if(e.getCause() instanceof JSONException){
	       
			e.printStackTrace();
			contentjob.element("status", "1");
			contentjob.element("content", "JSON对象错误！");
			resultjob.element("result", contentjob);
			bodyobj.put("param", resultjob);
			headobj.put("datetime", getDateTime());
			return jsonObject;
		} 
	          if(e.getCause() instanceof SQLException ) {
			e.printStackTrace();
			contentjob.element("status", "2");
			contentjob.element("content", "访问数据库错误！");
			resultjob.element("result", contentjob);
			bodyobj.put("param", resultjob);
			headobj.put("datetime", getDateTime());
			return jsonObject;
		} 
	          else {
			e.printStackTrace();
			 
			  contentjob.element("status", "3");
			contentjob.element("content", "未知错误！"+e.getMessage());
			resultjob.element("result", contentjob);
			bodyobj.put("param", resultjob);
			headobj.put("datetime", getDateTime());
			return jsonObject;
		} 
	          
		}	          
	    catch(JSONException e){
	   	       
	  			e.printStackTrace();
	  			contentjob.element("status", "1");
	  			contentjob.element("content", "JSON对象错误！");
	  			resultjob.element("result", contentjob);
	  			bodyobj.put("param", resultjob);
	  			headobj.put("datetime", getDateTime());
	  			return jsonObject;
	  		} 
		  catch( SQLException e ) {
	  			e.printStackTrace();
	  			contentjob.element("status", "2");
	  			contentjob.element("content", "访问数据库错误！");
	  			resultjob.element("result", contentjob);
	  			bodyobj.put("param", resultjob);
	  			headobj.put("datetime", getDateTime());
	  			return jsonObject;
	  		} 
		  catch( Exception e ) {
	  			e.printStackTrace();
	  			 
	  			  contentjob.element("status", "3");
	  			contentjob.element("content", "未知错误！"+e.getMessage());
	  			resultjob.element("result", contentjob);
	  			bodyobj.put("param", resultjob);
	  			headobj.put("datetime", getDateTime());
	  			return jsonObject;
	  		} 
	 
		finally {
			try {
				if (conn != null) {
					if (!readonly) {
						conn.rollback();
					}
					conn.close();
				}
			} catch (SQLException e) {

			}

		}
		headobj.put("datetime", getDateTime());
		return jsonObject;

	}

	public static String getDateTime() {
		Date date = new Date();
		SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");
		String time = df.format(date);
		return time;
	}

	public static String getIP()  {
		String ip =null;
		try{
		InetAddress localhost = InetAddress.getLocalHost();
		  ip = localhost.getHostAddress();}
		catch(Exception e){}
		
		return ip;
	}

}
