package test;

import static org.junit.Assert.*;

import java.io.FileInputStream;
import java.io.FileReader;
import java.io.InputStream;
import java.io.Reader;
import java.net.InetAddress;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.apache.ibatis.io.Resources;
import org.apache.ibatis.session.SqlSession;
import org.apache.ibatis.session.SqlSessionFactory;
import org.apache.ibatis.session.SqlSessionFactoryBuilder;
import org.exolab.castor.mapping.Mapping;
import org.exolab.castor.xml.Unmarshaller;
import org.junit.Before;
import org.junit.Test;
import org.xml.sax.InputSource;

import eme.EmeUtil;
import eme.method.EmeInvok;
import eme.util.ToolUtil;
import eme.xml.EmeRoot;

public class TestUtil {
	SqlSession session;
	@Before
	
	public void setUp() throws Exception {
	 

		String resource = "mybatis-config.xml";
		String propresource="config.properties";
		
		Properties prop= Resources.getResourceAsProperties(propresource); 
		Reader reader = Resources.getResourceAsReader(resource);
		
    	SqlSessionFactoryBuilder sqlSessionFactoryBuilder = new SqlSessionFactoryBuilder();
		
		SqlSessionFactory factory = sqlSessionFactoryBuilder.build(reader,prop);
		
	     session=factory.openSession();
		
		

	}

	//@Test
	public void gettiem() throws Exception {

		System.out.println("--------->>>>." + ToolUtil.getDateTime2());
	}
	
	@Test
	public void getpr() throws Exception {

	List<Map>	l= session.selectList("Trade.select_pr_imggroup");
	System.out.println(l.get(0).toString());
		 
	}
	
	
	

}
