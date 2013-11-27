package eme;

import java.io.IOException;
import java.io.Reader;
import java.util.Properties;

import org.apache.ibatis.io.Resources;
import org.apache.ibatis.session.SqlSessionFactory;
import org.apache.ibatis.session.SqlSessionFactoryBuilder;

public class EmeContext {
	private static SqlSessionFactory mybatisFactory =null;

	public static void initMybatis() throws IOException{

	String resource = "mybatis-config.xml";
	String propresource="config.properties";
	
	Properties prop= Resources.getResourceAsProperties(propresource); 
	Reader reader = Resources.getResourceAsReader(resource);
	
	SqlSessionFactoryBuilder sqlSessionFactoryBuilder = new SqlSessionFactoryBuilder();
	
	mybatisFactory = sqlSessionFactoryBuilder.build(reader,prop);
	
	}
	
	public static SqlSessionFactory getMybatisFactory() throws IOException  {
		if(mybatisFactory==null)
			initMybatis();
		
		return mybatisFactory;
	}
	

}
