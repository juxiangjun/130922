package com.eme.ims.cache;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import net.spy.memcached.MemcachedClient;

import org.apache.commons.lang3.time.DateUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.eme.ims.codec.Message;
import com.eme.ims.utils.PropertyConfig;


public class App {

	private static final String CONFIG_FILE="worker.ini";
	private final static Logger logger = LoggerFactory.getLogger(App.class);
	private static MemcachedClient client;

	private static String url;
	private static String user;
	private static String password;
	
	
	public static void main(String args[]) {
		
		PropertyConfig config = new PropertyConfig(CONFIG_FILE, 1);
		String host = config.getString("memcached.host");
		Integer port = config.getInteger("memcached.port");
		
		String dbHost = config.getString("db.host");
		Integer dbPort = config.getInteger("db.port");
		String dbName = config.getString("dbName");
		
		user = config.getString("dbUser");
		password = config.getString("db.password");
		
		url = "jdbc:mysql://"+dbHost+":"+dbPort.toString()+"/"+dbName;
		try {
			client = new MemcachedClient(new InetSocketAddress(host, port));
			
			String key = "MSG_"+ getKey();
			Object obj = client.get(key);
			
			if (obj != null) {
				@SuppressWarnings("unchecked")
				String sql = getSQL((List<Message>) obj);
				executeSQL(sql);
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
		
	}
	
	
	public static void executeSQL(String sql) {
		
		try {
			Class.forName("com.mysql.jdbc.Driver");
			Connection conn = DriverManager.getConnection(url, user, password);
			PreparedStatement pstmp = conn.prepareStatement(sql);
			pstmp.execute();
			pstmp.close();
			conn.close();
		} catch (ClassNotFoundException | SQLException e) {
			e.printStackTrace();
		}
		
	}
	
	
	public static String getSQL(List<Message> list) {
		String sql = "insert into lp_message values ";
		
		int i=0;
		for (Message msg : list) {
			String tmp = "(";
			tmp = tmp + "'"+msg.getUid()+"'";
			tmp = tmp + ",'"+msg.getFrom()+"'";
			tmp = tmp + ",'"+msg.getTo()+"'";
			tmp = tmp + ","+msg.getEventTime().toString()+"";
			tmp = tmp + ","+msg.getStatus()+"";
			tmp = tmp + ",'"+msg.getGroupId()+"'";
			tmp = tmp + ","+msg.getType()+"";
			tmp = tmp + ","+msg.getError()+"";
			tmp = tmp + ","+msg.getDirection()+"";
			tmp = tmp + ",null";
			tmp = tmp + ","+msg.getCommandId()+"";
			tmp = tmp + ",'"+msg.getContents()+"'";
			tmp = tmp + ")";
			
			if (i==0) {
				sql = sql + tmp;
			} else {
				sql = sql + "," + tmp;
			}
		}
		
		return sql + ";";
	}
	
	public static String getKey()  {
		Date date = new Date();
		date = DateUtils.addHours(date, -1);
		SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd-hh");
		return df.format(date);
	}
	
}
