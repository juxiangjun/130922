package eme;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.ResourceBundle;

import com.alibaba.druid.pool.DruidDataSource;

public class EmeDB {
	 private Connection conn = null;

	public Connection getConn() {
		return conn;
	}

	public void setConn(Connection conn) {
		this.conn = conn;
	}
 
	private static final ResourceBundle bundle = java.util.ResourceBundle
			.getBundle("config");

	public static final String get(String key) {
		return bundle.getString(key);
	}

	private static DruidDataSource dds = null;

	public DruidDataSource getDruidDataSource() {
		if (dds == null) {
			dds = new DruidDataSource();
			dds.setUsername(get("user"));
			dds.setUrl(get("jdbcUrl"));
			dds.setPassword(get("passwd"));
			dds.setDriverClassName(get("driver"));
			dds.setInitialSize(Integer.parseInt(get("initialSize")));
			dds.setMaxActive(Integer.parseInt(get("maxPoolSize")));
			dds.setMaxWait(Long.parseLong(get("maxIdleTime")));
			dds.setTestWhileIdle(false);
			dds.setTestOnReturn(false);
			dds.setTestOnBorrow(false);
		}
		return dds;
	}

	public Connection getConnection() throws java.sql.SQLException {
		DruidDataSource ds = getDruidDataSource();
		return ds.getConnection();

	}

	public int exeUpdate(String sql, Object... params)
			throws java.sql.SQLException {

		PreparedStatement pst = conn.prepareStatement(sql);
		for (int i = 0; i < params.length; i++) {
			pst.setObject(i + 1, params[i]);
		}
		int ii= pst.executeUpdate();
		pst.close();
		 return ii;
	}
	public int exeUpdate(String sql)
			throws java.sql.SQLException {

		PreparedStatement pst = conn.prepareStatement(sql);
		 
		int ii= pst.executeUpdate();
		pst.close();
		 return ii;
	}

	public List<Map<String, Object>> exeQueryObject(String sql,
			Object... params) throws java.sql.SQLException {

		PreparedStatement pst = conn.prepareStatement(sql);
		for (int i = 0; i < params.length; i++) {
			pst.setObject(i + 1, params[i]);
		}
		ResultSet res = pst.executeQuery();
		List<Map<String, Object>> ll=ObjectList(res);
		res.close();
		pst.close();
		return ll;
 

	}

	public List<Map<String, Object>> exeQueryObject(String sql)
			throws java.sql.SQLException {
		PreparedStatement pst = conn.prepareStatement(sql);
		ResultSet res = pst.executeQuery();
		List<Map<String, Object>> ll=ObjectList(res);
		res.close();
		pst.close();
		return ll;
	 

	}

	public List<Map<String, String>> exeQueryString(String sql,Object... params) throws java.sql.SQLException {

		PreparedStatement pst = conn.prepareStatement(sql);
		for (int i = 0; i < params.length; i++) {
			pst.setObject(i + 1, params[i]);
		}
		ResultSet res = pst.executeQuery();
		List<Map<String, String>> ll= StringList(res);
		res.close();
		pst.close();
		return ll;

	}

	public List<Map<String, String>> exeQueryString(String sql)
			throws java.sql.SQLException {
		PreparedStatement pst = conn.prepareStatement(sql);
		ResultSet res = pst.executeQuery();
		List<Map<String, String>> ll = StringList(res);
		res.close();
		pst.close();
		return ll;
	}

	public List<Map<String, Object>> ObjectList(ResultSet rs)
			throws java.sql.SQLException {

		if (rs == null)
			return Collections.EMPTY_LIST;
		ResultSetMetaData md = rs.getMetaData(); // 得到结果集(rs)的结构信息，比如字段数、字段名等
		int columnCount = md.getColumnCount(); // 返回此 ResultSet 对象中的列数
		List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();
		Map<String, Object> rowData = new HashMap<String, Object>();
		while (rs.next()) {
			rowData = new HashMap<String, Object>(columnCount);
			for (int i = 1; i <= columnCount; i++) {
				rowData.put(md.getColumnName(i), rs.getObject(i));
			}
			list.add(rowData);
			// System.out.println("list:" + list.toString());
		}
		return list;
	}

	public List<Map<String, String>> StringList(ResultSet rs)
			throws java.sql.SQLException {

		if (rs == null)
			return Collections.EMPTY_LIST;
	 
		ResultSetMetaData md = rs.getMetaData(); // 得到结果集(rs)的结构信息，比如字段数、字段名等
		int columnCount = md.getColumnCount(); // 返回此 ResultSet 对象中的列数
		List<Map<String, String>> list = new ArrayList<Map<String, String>>();
		Map<String, String> rowData = new HashMap<String, String>();
		while (rs.next()) {
			rowData = new HashMap<String, String>(columnCount);
			for (int i = 1; i <= columnCount; i++) {
				rowData.put(md.getColumnLabel(i), rs.getString(i));
			}
			list.add(rowData);
			// System.out.println("list:" + list.toString());
		}
		return list;
	}
	
	public String exeGetString(String   sql,
			Object... params) throws java.sql.SQLException {
		
		
		PreparedStatement pst = conn.prepareStatement(sql);
		for (int i = 0; i < params.length; i++) {
			pst.setObject(i + 1, params[i]);
		}
		ResultSet res = pst.executeQuery();
		
		if (res == null)
			return null;	 
		  res.next()  ;
			// System.out.println("list:" + list.toString());
		 
		return res.getString(1) ;
		
	}
	
	public Map<String,String> exeGetMap(String   sql,
			Object... params) throws java.sql.SQLException {
		
		
		PreparedStatement pst = conn.prepareStatement(sql);
		for (int i = 0; i < params.length; i++) {
			pst.setObject(i + 1, params[i]);
		}
		ResultSet res = pst.executeQuery();
		Map<String, String> rowData = new HashMap<String, String>();
		if (res == null)
			return null;	 
		  res.next()  ;
			// System.out.println("list:" + list.toString());
		  ResultSetMetaData md = res.getMetaData(); // 得到结果集(rs)的结构信息，比如字段数、字段名等
			int columnCount = md.getColumnCount(); // 返回此 ResultSet 对象中的列数
			
		  for (int i = 1; i <= columnCount; i++) {
				rowData.put(md.getColumnLabel(i), res.getString(i));
			}
		 
		return rowData ;
		
	}
	

}
