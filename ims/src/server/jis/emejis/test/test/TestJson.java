package test;

import static org.junit.Assert.*;

import java.io.FileReader;
import java.sql.Connection;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.exolab.castor.mapping.Mapping;
import org.exolab.castor.xml.Unmarshaller;
import org.junit.Test;
import org.xml.sax.InputSource;

import eme.EmeDB;
 
import eme.JisContext;
import eme.xml.EmeRoot;
import eme.xml.Function;
import eme.xml.Service;

public class TestJson {

	//@Test
	public void test() {
		String eme ="{\"root\":{\"header\":{\"id\":\"001\",\"ack\":\"request\",\"sender\":\"192.168.1.2\",\"datetime\":\"20131022080209\",\"cmsid\":\"1\",\"version\":\"v1.0\",\"device\":\"iphone\"},\"body\":{\"service\":\"S_ABOUTUS\",\"function\":\"APPEME_ABOUTUS_XXXXX\",\"param\":{\"param1\":\"value1\",\"param2\":\"value2\"}}}}";
		 
		   JSONObject jsonObject = JSONObject.fromObject(eme);
		   JSONObject rootobj=jsonObject.getJSONObject("root");
		   System.out.println(rootobj);
		   
		   JSONObject headobj=rootobj.getJSONObject("header");
		   System.out.println(headobj);
		   
		   JSONObject bodyobj=rootobj.getJSONObject("body");
		   System.out.println(bodyobj);
		   
		   String service=bodyobj.getString("service");
		   System.out.println(service);
		   
		   String function=bodyobj.getString("function");
		   System.out.println(function);
		   
		   JSONObject paramobj=bodyobj.getJSONObject("param");
		   System.out.println(paramobj);
		   
		   String param1=paramobj.getString("param1");
		   System.out.println(param1);
		   
		   paramobj.put("222", "5555");
		   System.out.println(paramobj);
		   
		   System.out.println(jsonObject);
		   
	}

	
	//@Test
	public void test2() {
	
	String eme ="{\"body\":{\"service\":\"S_TRADE\",\"function\":\"APPEME_ORDER_SEND\",\"param\":{\"userid\":\"xxx\",\"orderid\":\"dddd01\",\"sendaddrcode\":\"送货地址的code\",\"detail\":[{\"itemcode\":\"商品代码1\",\"buynum\":\"12\",\"buyprice\":\"122\",\"comment\":\"购买时填写的备注\"},{\"itemcode\":\"商品代码2\",\"buynum\":\"12\",\"buyprice\":\"122\",\"comment\":\"购买时填写的备注\"}],\"total\":\"3498\"}}}";
	
	  JSONObject rootobj = JSONObject.fromObject(eme);
	 // JSONObject rootobj=jsonObject.getJSONObject("root");	  
	  JSONObject bodyobj=rootobj.getJSONObject("body");
	  JSONObject paramobj=bodyobj.getJSONObject("param");
	   System.out.println(paramobj);
	   
	   
	  JSONArray ja= paramobj.getJSONArray("detail");
	  System.out.println(ja);
	   for(int i=0;i<ja.size();i++ ){
		   
		   JSONObject ob= (JSONObject)ja.get(i);
		   
		   System.out.println(ob);
		   
	   } 
	}
	
	
//	@Test
	public void test3() {
		
		Date date=new Date();
		SimpleDateFormat df=new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");
		String time=df.format(date);
		System.out.println(time);
	}
	
	 
	
	
	//@Test
		public void test5() throws java.sql.SQLException{
		
		
		EmeDB db=new EmeDB();
		db.setConn(db.getConnection());
		JisContext jc = new JisContext("", null, db);
		
		List<Map<String,String>> ll=jc.getDb().exeQueryString("select id,name from cs_user");
		
		System.out.println("--"+ll.toString());
	}
	
	
}
