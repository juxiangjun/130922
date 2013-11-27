package test;

import java.io.FileReader;

import org.exolab.castor.mapping.Mapping;
import org.exolab.castor.xml.Unmarshaller;
import org.junit.Before;
import org.junit.Test;
import org.xml.sax.InputSource;

import eme.EmeContext;
import eme.EmeUtil;
import eme.method.EmeInvok;
import eme.xml.EmeRoot;
 

public class TestLp {
 
	StringBuffer buf = new StringBuffer();
	
	@Before
	public void setUp() throws Exception {

		Mapping mapping = new Mapping();
		mapping.loadMapping("config/define.xml");
		Unmarshaller unmar = new Unmarshaller(mapping);
		EmeRoot eme = (EmeRoot) unmar.unmarshal(new InputSource(new FileReader(
				"config/map.xml")));
		EmeInvok.init(eme);
		EmeContext.initMybatis();
		buf.append("{\"root\":{\"header\":{\"id\":\"001\",\"ack\":\"repuest\",\"sender\":\"192.168.1.1\",\"datetime\":\"20131022080209\",\"appver\":\"1.0\",\"cid\":\"b9ed3b20-77d3-4ccf-930f-e852c47b7ae5\",\"version\":\"v1.0\",\"device\":\"iphone\"},\"body\":{\"service\":\"S_LP\",\"function\":\"");

	}
 
	
   //@Test
	public void getfriend() throws Exception {

		StringBuffer t = new StringBuffer(buf);
		t.append("GET_GOODFRIEND")
				.append("\",\"param\":")
				.append("{\"toid\":\"b9ed3b20-77d3-4ccf-930f-e852c47b7ae5\",\"userid\":\"b9ed3b20-77d3-4ccf-930f-e852c47b7ae5\"}")
				.append("}}}");

		System.out.println(EmeUtil.getResponseJson(t.toString()));

	}
	
 @Test
	public void getfriendlist() throws Exception {

		StringBuffer t = new StringBuffer(buf);
		t.append("GET_GOODFRIENDLIST")
				.append("\",\"param\":")
				.append("{\"userid\":\"c9ed3b20-77d3-4ccf-930f-e852c47b7ae5\",\"pagenum\":\"1\",\"pagecount\":\"10\"}")
				.append("}}}");

		System.out.println(EmeUtil.getResponseJson(t.toString()));

	}
 
 
 //@Test
	public void addtfriend() throws Exception {

		StringBuffer t = new StringBuffer(buf);
		t.append("ADD_GOODFRIEND")
				.append("\",\"param\":")
				.append("{\"userid\":\"c9ed3b20-77d3-4ccf-930f-e852c47b7ae5\",\"toid\":\"b9ed3b20-77d3-4ccf-930f-e852c47b7ae5\"}")
				.append("}}}");

		System.out.println(EmeUtil.getResponseJson(t.toString()));

	}

}
