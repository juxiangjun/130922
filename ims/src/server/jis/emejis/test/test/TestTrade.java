package test;

import static org.junit.Assert.*;

import java.io.FileReader;
import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.util.Date;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.apache.ibatis.io.Resources;
import org.apache.ibatis.session.SqlSessionFactory;
import org.apache.ibatis.session.SqlSessionFactoryBuilder;
import org.exolab.castor.mapping.Mapping;
import org.exolab.castor.xml.Unmarshaller;
import org.junit.Before;
import org.junit.Test;
import org.xml.sax.InputSource;

import eme.EmeUtil;
 
import eme.method.EmeInvok;
import eme.xml.EmeRoot;

public class TestTrade {

	@Before
	public void setUp() throws Exception {
		Mapping mapping = new Mapping();
		mapping.loadMapping("config/define.xml");
		Unmarshaller unmar = new Unmarshaller(mapping);
		EmeRoot eme = (EmeRoot) unmar.unmarshal(new InputSource(new FileReader("config/map.xml")));
		//EmeXmlUtil.er = eme;
		 EmeInvok.init(eme);
		 	 
	}

 @Test
	// 得到分类
	public void testMethodCategory() {

	//	String key = "{\"root\":{\"header\":{\"id\":\"001\",\"ack\":\"request\",\"sender\":\"192.168.1.2\",\"datetime\":\"20131022080209\",\"appver\":\"1.0\",\"cid\":\"1\",\"version\":\"v1.0\",\"device\":\"iphone\"},\"body\":{\"service\":\"S_TRADE\",\"function\":\"APPEME_CATEGORY\",\"param\":{\"userid\":\"1\",\"code\":\"1\"}}}}";
		String key1 ="{\"root\":{\"header\":{\"id\":\"001\",\"ack\":\"repuest\",\"sender\":\"192.168.1.1\",\"datetime\":\"20131022080209\",\"appver\":\"1.0\",\"cid\":\"b9ed3b20-77d3-4ccf-930f-e852c47b7ae5\",\"version\":\"v1.0\",\"device\":\"iphone\"},\"body\":{\"service\":\"S_TRADE\",\"function\":\"APPEME_CATEGORY\",\"param\":{}}}}";
		System.out.println(EmeUtil.getResponseJson(key1,null));

		assertTrue(true);
	}

	  //@Test
	public void testMethodItem() {
		String key = "gfsgfdsgfdsgf";

		System.out.println(EmeUtil.getResponseJson(key,null));

		assertTrue(true);
	}

	  // @Test
	// insert 商品评论
	public void testInsertComment() {
		String key = "{\"root\":{\"header\":{\"id\":\"001\",\"ack\":\"request\",\"sender\":\"192.168.1.2\",\"datetime\":\"20131022080209\",\"appver\":\"1.0\",\"cid\":\"1\",\"version\":\"v1.0\",\"device\":\"iphone\"},\"body\":{\"service\":\"S_TRADE\",\"function\":\"APPEME_ITEM_ASSESS_SEND\",\"param\":{\"userid\":\"1\",\"itemcode\":\"4\",\"content\":\"评价的内容999\"}}}}";

		System.out.println(EmeUtil.getResponseJson(key,null));

	}

 //@Test
	// list商品评论
	public void testGetComment() {
		String key = "{\"root\":{\"header\":{\"id\":\"001\",\"ack\":\"request\",\"sender\":\"192.168.1.2\",\"datetime\":\"20131022080209\",\"appver\":\"1.0\",\"cid\":\"1\",\"version\":\"v1.0\",\"device\":\"iphone\"},\"body\":{\"service\":\"S_TRADE\",\"function\":\"APPEME_ITEM_ASSESS\",\"param\":{\"mbrid\":\"\",\"itemcode\":\"4\"}}}}";
		//String key = "{\"root\":{\"header\":{\"id\":\"001\",\"ack\":\"request\",\"sender\":\"192.168.1.2\",\"datetime\":\"20131022080209\",\"appver\":\"1.0\",\"cid\":\"1\",\"version\":\"v1.0\",\"device\":\"iphone\"},\"body\":{\"service\":\"S_TRADE\",\"function\":\"APPEME_ITEM_ASSESS\",\"param\":{\"mbrid\":\"\",\"itemcode\":\"4\",\"pagenum\":\"1\",\"pagecount\":\"10\"}}}}";

		System.out.println(EmeUtil.getResponseJson(key,null));

	}

	// @Test
	// list商品规格
	public void testGetModel() {
		String key = "{\"root\":{\"header\":{\"id\":\"001\",\"ack\":\"request\",\"sender\":\"192.168.1.2\",\"datetime\":\"20131022080209\",\"appver\":\"1.0\",\"cid\":\"1\",\"version\":\"v1.0\",\"device\":\"iphone\"},\"body\":{\"service\":\"S_TRADE\",\"function\":\"APPEME_ITEM_MODEL\",\"param\":{\"userid\":\"1\",\"itemcode\":\"1\"}}}}";

		System.out.println(EmeUtil.getResponseJson(key,null));

	}

	// @Test
	// list商品图片
	public void testgetProductImg() {
		String key = "{\"root\":{\"header\":{\"id\":\"001\",\"ack\":\"request\",\"sender\":\"192.168.1.2\",\"datetime\":\"20131022080209\",\"appver\":\"1.0\",\"cid\":\"1\",\"version\":\"v1.0\",\"device\":\"iphone\"},\"body\":{\"service\":\"S_TRADE\",\"function\":\"APPEME_ITEM_IMG\",\"param\":{\"userid\":\"1\",\"itemcode\":\"4\"}}}}";

		System.out.println(EmeUtil.getResponseJson(key,null));

	}

	//   @Test
	 // insert 提交购物篮
	public void testinsertBasketItem() {
		String key = "{\"root\":{\"header\":{\"id\":\"001\",\"ack\":\"request\",\"sender\":\"192.168.1.2\",\"datetime\":\"20131022080209\",\"appver\":\"1.0\",\"cid\":\"1\",\"version\":\"v1.0\",\"device\":\"iphone\"},\"body\":{\"service\":\"S_TRADE\",\"function\":\"APPEME_ITEM_TMP_SEND\",\"param\":{\"userid\":\"1\",\"itemcode\":\"9\",\"buynum\":\"8\",\"price\":\"8\",\"comment\":\"8\"}}}}";

		System.out.println(EmeUtil.getResponseJson(key,null));

	}

   //@Test
	// get 得到购物篮
	public void testgetBasketItem() {
		String key = "{\"root\":{\"header\":{\"id\":\"001\",\"ack\":\"request\",\"sender\":\"192.168.1.2\",\"datetime\":\"20131022080209\",\"appver\":\"1.0\",\"cid\":\"1\",\"version\":\"v1.0\",\"device\":\"iphone\"},\"body\":{\"service\":\"S_TRADE\",\"function\":\"APPEME_ITEM_TMP\","
				+ "\"param\":{\"userid\":\"b9ed3b20-77d3-4ccf-930f-e852c47b7ae5\"}}}}";

		System.out.println(EmeUtil.getResponseJson(key,null));

	}

	//  @Test
	// del 删除购物篮
	public void testdelBasketItem() {
		String key = "{\"root\":{\"header\":{\"id\":\"001\",\"ack\":\"request\",\"sender\":\"192.168.1.2\",\"datetime\":\"20131022080209\",\"appver\":\"1.0\",\"cid\":\"1\",\"version\":\"v1.0\",\"device\":\"iphone\"},\"body\":{\"service\":\"S_TRADE\",\"function\":\"APPEME_ITEM_TMP_DEL\","
				+ "\"param\":{\"userid\":\"1\",\"items\":[{\"itemcode\":\"3\"},{\"itemcode\":\"9\"}]}}}}";

		System.out.println(EmeUtil.getResponseJson(key,null));

	}

  //@Test
	// inset 地址
	public void testinsertAddress() {
		String key = "{\"root\":{\"header\":{\"id\":\"001\",\"ack\":\"request\",\"sender\":\"192.168.1.2\",\"datetime\":\"20131022080209\",\"appver\":\"1.0\",\"cid\":\"1\",\"version\":\"v1.0\",\"device\":\"iphone\"},\"body\":{\"service\":\"S_TRADE\",\"function\":\"APPEME_ORDER_ADDR_SEND\",\"param\":"
	          +"{\"userid\":\"c37f0a21-22cd-4728-9f6b-840633348651\",\"code\":\"\",\"receiver\":\"张三\",\"refmobile\":\"19919991199\",\"area\":\"上海静安区\",\"address\":\"南京东路101号\",\"zipcode\":\"100200\",\"isdefault\":\"Y\"}}}}";

		System.out.println(EmeUtil.getResponseJson(key,null));

	}
  @Test
		// get 地址
	
		public void  testgetAddress() {
		//String key = "{\"root\":{\"header\":{\"id\":\"001\",\"ack\":\"request\",\"sender\":\"192.168.1.2\",\"datetime\":\"20131022080209\",\"appver\":\"1.0\",\"cid\":\"1\",\"version\":\"v1.0\",\"device\":\"iphone\"},\"body\":{\"service\":\"S_TRADE\",\"function\":\"APPEME_ORDER_ADDR\",\"param\":{\"userid\":\"c37f0a21-22cd-4728-9f6b-840633348651\",\"code\":\"\"}}}}";
			String key ="{\"root\":{\"body\":{\"service\":\"S_TRADE\",\"param\":{\"userid\":\"b9ed3b20-77d3-4ccf-930f-e852c47b7ae5\",\"code\":\"Y\"},\"function\":\"APPEME_ORDER_ADDR\"},\"header\":{\"id\":\"55f24c53-a1a9-4962-b861-f422200a4ed8\",\"sender\":\"10.0.2.15\",\"ack\":\"request\",\"device\":\"手机型号:sdk,SDK版本:10,系统版本:2.3.3\",\"datetime\":\"2013-11-1106:10:019\",\"cid\":\"b9ed3b20-77d3-4ccf-930f-e852c47b7ae5\",\"appver\":\"1.0\",\"version\":\"1\"}}}";
			System.out.println(EmeUtil.getResponseJson(key,null));

		}
		
		
		  // @Test
		// inset 订单
		public void testinsertorder() {
			String key = "{\"root\":{\"header\":{\"id\":\"001\",\"ack\":\"request\",\"sender\":\"192.168.1.2\",\"datetime\":\"20131022080209\",\"appver\":\"1.0\",\"cid\":\"1\",\"version\":\"v1.0\",\"device\":\"iphone\"},\"body\":{\"service\":\"S_TRADE\",\"function\":\"APPEME_ORDER_SEND\",\"param\":"
		          +"{\"userid\":\"1\",\"sendaddrcode\":\"1\",\"detail\":["
		          + "{\"itemcode\":\"4\",\"shopid\":\"1\",\"type\":\"1\",\"buynum\":\"12\",\"buyprice\":\"1229\",\"comment\":\"购买时填写的备注1\"},"
		          + "{\"itemcode\":\"5\",\"shopid\":\"1\",\"type\":\"0\",\"buynum\":\"10\",\"buyprice\":\"1223\",\"comment\":\"购买时填写的备注2\"},"
		          + "{\"itemcode\":\"3\",\"shopid\":\"2\",\"type\":\"0\",\"buynum\":\"120\",\"buyprice\":\"122\",\"comment\":\"购买时填写的备注3\"},"
		          + "{\"itemcode\":\"6\",\"shopid\":\"2\",\"type\":\"0\",\"buynum\":\"17\",\"buyprice\":\"12\",\"comment\":\"购买时填写的备注4\"}"
			         + "]}}}}";

			System.out.println(EmeUtil.getResponseJson(key,null));

		}
		
		 // @Test
		// get  订单
	
		public void  testgetOrder() {
			String key = "{\"root\":{\"header\":{\"id\":\"001\",\"ack\":\"request\",\"sender\":\"192.168.1.2\",\"datetime\":\"20131022080209\",\"appver\":\"1.0\",\"cid\":\"1\",\"version\":\"v1.0\",\"device\":\"iphone\"},\"body\":{\"service\":\"S_TRADE\",\"function\":\"APPEME_ORDER_GET\",\"param\":{\"userid\":\"1\",\"orderid\":\"e7531090-5067-47c6-b4e1-6f9fb09f1c68\",\"type\":\"0\"}}}}";

			System.out.println(EmeUtil.getResponseJson(key,null));

		}
		 // @Test
				// get  订单
			
				public void  testgetItemByName() {
					String key = "{\"root\":{\"header\":{\"id\":\"001\",\"ack\":\"request\",\"sender\":\"192.168.1.2\",\"datetime\":\"20131022080209\",\"appver\":\"1.0\",\"cid\":\"1\",\"version\":\"v1.0\",\"device\":\"iphone\"},\"body\":{\"service\":\"S_TRADE\",\"function\":\"APPEME_ITEMS_NAME\",\"param\":"
							+ "{\"name\":\"青\",\"orderby\":\"11\",\"type\":\"0\",\"pagenum\":\"1\",\"pagecount\":\"10\"}}}}";

					System.out.println(EmeUtil.getResponseJson(key,null));

				}
		  
		  
		  
		  
		  
	 //@Test
			// get  订单
		
			public void  testgetItemByType() {
				 String key = "{\"root\":{\"header\":{\"id\":\"001\",\"ack\":\"request\",\"sender\":\"192.168.1.2\",\"datetime\":\"20131022080209\",\"appver\":\"1.0\",\"cid\":\"1\",\"version\":\"v1.0\",\"device\":\"手机型号iphone\"},\"body\":{\"service\":\"S_TRADE\",\"function\":\"APPEME_ITEMS_TYPE\",\"param\":{\"code\":\"1\",\"type\":\"1\",\"pagenum\":\"1\",\"pagecount\":\"10\"}}}}";
				//String key =   "{\"root\":{\"header\":{\"sender\":\"78:6C:1C:23:7C:31\",\"device\":\"iPod4thGen\",\"id\":\"94228494\",\"appver\":\"\",\"datetime\":\"2013-10-3011:48:11\",\"version\":\"1.0\",\"ack\":\"request\",\"cid\":\"1\"},\"body\":{\"service\":\"S_TRADE\",\"param\":{\"pagecount\":\"1\",\"pagenum\":\"1\",\"code\":\"1\",\"type\":\"0\",\"orderby\":\"11\"},\"function\":\"APPEME_ITEMS_TYPE\"}}}";

				System.out.println(EmeUtil.getResponseJson(key,null));

			}		
		 //@Test
			// get  订单
		
			public void  testgetItemByCode() {
				String key = "{\"root\":{\"header\":{\"id\":\"001\",\"ack\":\"request\",\"sender\":\"192.168.1.2\",\"datetime\":\"20131022080209\",\"appver\":\"1.0\",\"cid\":\"1\",\"version\":\"v1.0\",\"device\":\"iphone\"},\"body\":{\"service\":\"S_TRADE\",\"function\":\"APPEME_ITEMS_CODE\",\"param\":{\"code\":\"4\"}}}}";

				System.out.println(EmeUtil.getResponseJson(key,null));

			}
		 
			
		// @Test
			// get  确定 订单
		
			public void  testOrderConfirm() {
				String key = "{\"root\":{\"header\":{\"id\":\"001\",\"ack\":\"request\",\"sender\":\"192.168.1.2\",\"datetime\":\"20131022080209\",\"appver\":\"1.0\",\"cid\":\"1\",\"version\":\"v1.0\",\"device\":\"iphone\"},\"body\":{\"service\":\"S_TRADE\",\"function\":\"APPEME_ORDER_CONFIRM\",\"param\":{\"code\":\"c37f0a21-22cd-4728-9f6b-840633348651\"}}}}";

				System.out.println(EmeUtil.getResponseJson(key,null));

			}
		 
			
			
		 
}
