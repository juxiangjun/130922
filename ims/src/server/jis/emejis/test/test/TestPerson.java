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

import eme.EmeContext;
import eme.EmeUtil;
import eme.method.EmeInvok;
import eme.util.ToolUtil;
import eme.xml.EmeRoot;

public class TestPerson {

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
		buf.append("{\"root\":{\"header\":{\"id\":\"001\",\"ack\":\"repuest\",\"sender\":\"192.168.1.1\",\"datetime\":\"20131022080209\",\"appver\":\"1.0\",\"cid\":\"b9ed3b20-77d3-4ccf-930f-e852c47b7ae5\",\"version\":\"v1.0\",\"device\":\"iphone\"},\"body\":{\"service\":\"S_PERSON\",\"function\":\"");

	}

	// @Test
	public void login() throws Exception {

		StringBuffer t = new StringBuffer(buf);
		t.append("LOGIN").append("\",\"param\":")
				.append("{\"loginid\":\"abc\",\"password\":\"abc\"}")
				.append("}}}");

		System.out.println(EmeUtil.getResponseJson(t.toString()));

	}

	// @Test
	public void saveperson() throws Exception {

		StringBuffer t = new StringBuffer(buf);
		t.append("SAVE_PERSON")
				.append("\",\"param\":")
				.append("{\"loginid\":\"abc223\",\"password\":\"111111\",\"name\":\"eme\",\"areaid\":\"2\",\"area2id\":\"211\",\"teamid\":\"b9ed3b20-77d3-4ccf-930f-e852c47b7ae5\",\"personid\":\"139836587364435\",\"sex\":\"0\",\"label\":\"test\",\"title\":\"工程师\",\"job\":\"化工\",}")
				.append("}}}");

		System.out.println(EmeUtil.getResponseJson(t.toString()));

	}

	// @Test
	public void updateperson() throws Exception {

		StringBuffer t = new StringBuffer(buf);
		t.append("SAVE_PERSON")
				.append("\",\"param\":")
				.append("{\"userid\":\"c37f0a21-22cd-4728-9f6b-840633348651\",\"loginid\":\"abc123\",\"password\":\"111111\",\"name\":\"eme-abc\",\"areaid\":\"2\",\"area2id\":\"211\",\"teamid\":\"b9ed3b20-77d3-4ccf-930f-e852c47b7ae5\",\"personid\":\"139836587364435\",\"sex\":\"0\",\"label\":\"test\",\"title\":\"工程师\",\"job\":\"化工\",}")
				.append("}}}");

		System.out.println(EmeUtil.getResponseJson(t.toString()));

	}

	// @Test
	public void getarea() throws Exception {

		StringBuffer t = new StringBuffer(buf);
		t.append("GET_AREA").append("\",\"param\":").append("{}").append("}}}");

		System.out.println(EmeUtil.getResponseJson(t.toString()));

	}

 // @Test
	public void getteam() throws Exception {

		StringBuffer t = new StringBuffer(buf);
		t.append("GET_TEAM").append("\",\"param\":").append("{}").append("}}}");

		System.out.println(EmeUtil.getResponseJson(t.toString()));

	}

	//  @Test
	public void getperson() throws Exception {

		StringBuffer t = new StringBuffer(buf);
		t.append("GET_PERSON")
				.append("\",\"param\":")
				.append("{\"userid\":\"b9ed3b20-77d3-4ccf-930f-e852c47b7ae5\"}")
				.append("}}}");

		System.out.println(EmeUtil.getResponseJson(t.toString()));

	}

  //@Test
	public void getimggrouplist() throws Exception {

		StringBuffer t = new StringBuffer(buf);
		t.append("GET_IMGGROUPLIST")
				.append("\",\"param\":")
				.append("{\"userid\":\"c9ed3b20-77d3-4ccf-930f-e852c47b7ae5\",\"toid\":\"b9ed3b20-77d3-4ccf-930f-e852c47b7ae5\",\"pagenum\":\"1\",\"pagecount\":\"10\"}")
				.append("}}}");

		System.out.println(EmeUtil.getResponseJson(t.toString()));

	}

  //@Test
	public void inpuimggroup() throws Exception {

		StringBuffer t = new StringBuffer(buf);
		t.append("INPUT_IMGGROUP")
				.append("\",\"param\":")
				.append("{\"groupid\":\"4298e952-8686-49a0-9924-d504f4d34b8f\"}")
				.append("}}}");

		System.out.println(EmeUtil.getResponseJson(t.toString()));

	}
	
	
	 //  @Test
		public void getimggroupcomment() throws Exception {

			StringBuffer t = new StringBuffer(buf);
			t.append("INPUT_IMGGROUP_COMMENT")
					.append("\",\"param\":")
					.append("{\"groupid\":\"b9ed3b20-77d3-4ccf-930f-e852c47b7ae5\",\"pagenum\":\"1\",\"pagecount\":\"10\"}")
					.append("}}}");

			System.out.println(EmeUtil.getResponseJson(t.toString()));

		}
		
		//  @Test
		public void sendgood() throws Exception {

			StringBuffer t = new StringBuffer(buf);
			t.append("SEND_GOOD")
					.append("\",\"param\":")
					.append("{\"groupid\":\"832bf7a2-ccb3-4568-89a6-bd0b04c6e9f8\",\"userid\":\"b9ed3b20-77d3-4ccf-930f-e852c47b7ae5\"}")
					.append("}}}");

			System.out.println(EmeUtil.getResponseJson(t.toString()));

		}
		
		
		// @Test
		public void sendComment() throws Exception {

			StringBuffer t = new StringBuffer(buf);
			t.append("SEND_COMMENT")
					.append("\",\"param\":")
					.append("{\"groupid\":\"832bf7a2-ccb3-4568-89a6-bd0b04c6e9f8\",\"userid\":\"b9ed3b20-77d3-4ccf-930f-e852c47b7ae5\",\"comment\":\"---123---test------\"}")
					.append("}}}");

			System.out.println(EmeUtil.getResponseJson(t.toString()));

		}
		 //@Test
				public void del_imggroup() throws Exception {

					StringBuffer t = new StringBuffer(buf);
					t.append("DEL_IMGGROUP")
							.append("\",\"param\":")
							.append("{\"groupid\":\"c9ed3b20-77d3-4ccf-930f-e852c47b7ae5\",\"userid\":\"b9ed3b20-77d3-4ccf-930f-e852c47b7ae5\"}")
							.append("}}}");

					System.out.println(EmeUtil.getResponseJson(t.toString()));

				}
		 
		  @Test
			public void set_img() throws Exception {

				StringBuffer t = new StringBuffer(buf);
				t.append("SET_IMG")
						.append("\",\"param\":")
						.append("{\"imgid\":\"b9ed3b20-77d3-4ccf-930f-e852c47b7ae5\",\"userid\":\"b9ed3b20-77d3-4ccf-930f-e852c47b7ae5\"}")
						.append("}}}");

				System.out.println(EmeUtil.getResponseJson(t.toString()));

			}
			 
				 

}
