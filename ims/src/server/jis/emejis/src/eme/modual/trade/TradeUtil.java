package eme.modual.trade;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import eme.EmeUtil;
import eme.JisContext;
import eme.util.Pair;
import eme.util.ToolUtil;
import net.sf.json.JSONArray;
import net.sf.json.JSONException;
import net.sf.json.JSONObject;

public class TradeUtil {
	String cid = null;
	String sql = null;

	JSONArray items = null;
	JSONObject item = null;

	public JSONArray getGategory(JisContext jc) throws SQLException,
			JSONException {
		JSONObject paramobj = jc.getJob();
		cid = jc.getCid();
		JSONObject cat = null;
		String code = null;
		JSONArray ja = new JSONArray();

		if (paramobj.containsKey("code"))
			code = paramobj.getString("code");
		if (code == null || "".equals(code))
			sql = "SELECT a.id aid,a.name aname ,b.id bid ,b.name bname ,a.imgpath aimgpath,b.imgpath bimgpath   FROM cs_type a inner JOIN cs_type b ON a.cid=b.cid and a.id=b.pid WHERE  a.cid='"
					+ cid + "'  ORDER BY a.id";
		else
			sql = "SELECT a.id as aid,a.name as aname ,b.id as  bid ,b.name as bname ,a.imgpath aimgpath,b.imgpath bimgpath  FROM cs_type a left JOIN cs_type b ON  a.cid=b.cid and a.id=b.pid WHERE  a.id='"
					+ code + "' and a.cid='" + cid + "'  ORDER BY a.id";

		List<Map<String, String>> list = jc.getDb().exeQueryString(sql);

		if (list.size() == 0)
			return ja;
		if (list.size() == 1) {
			Map<String, String> map = list.get(0);
			if (map.get("bid") == null) {
				item = new JSONObject();
				item.element("category", map.get("aname"));
				item.element("code", map.get("aid"));
				ja.add(item);
			} else {

				cat = new JSONObject();
				cat.element("category", map.get("aname"));
				cat.element("code", map.get("aid"));
				items = new JSONArray();
				JSONObject item = new JSONObject();
				item.element("category", map.get("bname"));
				item.element("code", map.get("bid"));
				items.add(item);
				cat.element("children", items);
				ja.add(cat);
			}
			return ja;
		}
		String tempid = "";
		for (Map<String, String> map : list) {
			if (tempid.equals(map.get("aid"))) {
				JSONObject item = new JSONObject();
				item.element("category", map.get("bname"));
				item.element("code", map.get("bid"));
				item.element("imageurl", map.get("bimgpath"));
				items.add(item);
			} else {
				tempid = map.get("aid");
				if (cat != null) {
					cat.element("children", items);
					ja.add(cat);
				}
				cat = new JSONObject();
				cat.element("category", map.get("aname"));
				cat.element("code", map.get("aid"));
				cat.element("imageurl", map.get("aimgpath"));
				items = new JSONArray();
				JSONObject item = new JSONObject();
				item.element("category", map.get("bname"));
				item.element("code", map.get("bid"));
				item.element("imageurl", map.get("bimgpath"));
				items.add(item);
			}

		}
		cat.element("children", items);
		ja.add(cat);

		return ja;

	}

	public JSONArray getItems(JisContext jc) throws SQLException, JSONException {

		return null;

	}

	public String insertComment(JisContext jc) throws SQLException,
			JSONException {

		JSONObject paramobj = jc.getJob();
		cid = jc.getCid();

		String itemcode = paramobj.getString("itemcode");
		String userid = paramobj.getString("userid");
		String content = paramobj.getString("content");
		StringBuffer sb = new StringBuffer();
		sb.append(
				"INSERT INTO cs_comment (id, pid, uid, comment, createtime, status) VALUES ('")
				.append(UUID.randomUUID().toString()).append("','")
				.append(itemcode).append("','").append(userid).append("','")
				.append(content).append("','").append(ToolUtil.getDateTime())
				.append("','0')");

		jc.getDb().exeUpdate(sb.toString());
		return "Success";

	}

	public JSONObject getComment(JisContext jc) throws SQLException,
			JSONException {
		JSONObject job = new JSONObject();
		String subsql = "";
		String mbrid = null;
		JSONObject paramobj = jc.getJob();
		int pagenum = paramobj.getInt("pagenum");
		int pagecount = paramobj.getInt("pagecount");
		cid = jc.getCid();
		JSONArray ja = new JSONArray();
		String itemcode = paramobj.getString("itemcode");
		if (paramobj.containsKey("mbrid"))
			mbrid = paramobj.getString("mbrid");
		if (mbrid == null || "".equals(mbrid))
			;
		else
			subsql = "and b.uid='" + mbrid + "'";

		sql = "SELECT a.id uid ,a.imgurl imgurl,a.name name, b.id bid,b.comment cc, b.createtime ct FROM cs_user a,cs_comment b WHERE a.id=b.uid and b.pid=? "
				+ subsql
				+ "  ORDER BY b.createtime DESC  LIMIT "
				+ (pagenum - 1) * pagecount + ", " + pagecount;

		String sqlc = "select count(*) cc from cs_comment b where b.pid=?  "
				+ subsql;
		List<Map<String, Object>> listc = jc.getDb().exeQueryObject(sqlc,
				itemcode);
		int total = ((Long) listc.get(0).get("cc")).intValue();

		job.element("pagenum", pagenum);
		job.element("pagecount", pagecount);
		job.element("totalcount", total);
		job.element("totalpage", total / pagecount + 1);

		List<Map<String, String>> list = jc.getDb().exeQueryString(sql,
				itemcode);

		for (Map<String, String> map : list) {
			JSONObject item = new JSONObject();
			item.element("id", map.get("bid"));
			item.element("mbrid", map.get("uid"));
			item.element("name", map.get("name"));
			item.element("content", map.get("cc"));
			item.element("imgurl", map.get("imgurl"));
			item.element("sendtime", map.get("ct"));

			ja.add(item);
		}
		job.element("item", ja);
		return job;
	}

	public String getModel(JisContext jc) throws SQLException, JSONException {

		JSONObject paramobj = jc.getJob();
		cid = jc.getCid();

		String itemcode = paramobj.getString("itemcode");

		sql = "SELECT  type FROM  cs_product WHERE id =?";

		List<Map<String, String>> list = jc.getDb().exeQueryString(sql,
				itemcode);

		Map<String, String> map = list.get(0);

		return map.get("type");

	}

	public JSONObject getProductImg(JisContext jc) throws SQLException,
			JSONException {
		JSONObject paramobj = jc.getJob();
		String itemcode = null;
		JSONObject job = new JSONObject();

		itemcode = paramobj.getString("itemcode");

		sql = "SELECT  a.path path ,b.comment cc FROM  cs_detail a ,cs_product b WHERE a.pid=b.id and a.pid = ? ";
		List<Map<String, String>> list = jc.getDb().exeQueryString(sql,
				itemcode);

		String comment = null;
		items = new JSONArray();
		for (Map<String, String> map : list) {
			JSONObject item = new JSONObject();
			item.element("url", map.get("path"));
			comment = map.get("cc");
			items.add(item);
		}

		job.element("content", comment);
		job.element("img", items);

		return job;

	}

	public String insertBasketItem(JisContext jc) throws SQLException,
			JSONException {

		JSONObject paramobj = jc.getJob();
		cid = jc.getCid();

		String itemcode = paramobj.getString("itemcode");
		String userid = paramobj.getString("userid");
		int buynum = paramobj.getInt("buynum");
		String comment = paramobj.getString("comment");
		// double price = paramobj.getDouble("price");

		sql = "select id from cs_basket_item where status='0' and pid=?";

		List<Map<String, String>> list = jc.getDb().exeQueryString(sql,
				itemcode);
		if (list.size() == 0) {

			// String sqlp = "select price from cs_product where id='" +
			// itemcode
			// + "'";
			// List<Map<String, Object>> list = jc.getDb().exeQueryObject(sqlp);
			//
			// Map<String, Object> map = list.get(0);
			// BigDecimal price = ((BigDecimal) map.get("price"));

			sql = "INSERT INTO cs_basket_item (id, pid, uid, status, num, createtime, comment) VALUES (?,?,?,?,?,?,?)";

			jc.getDb().exeUpdate(sql, UUID.randomUUID().toString(), itemcode,
					userid, "0", new Integer(buynum), ToolUtil.getDateTime(),
					comment);
			return "Success";
		} else {
			String uuid = list.get(0).get("id");

			sql = "update cs_basket_item set num=num+" + buynum + " where id=?";

			jc.getDb().exeUpdate(sql, uuid);
			return "Success";
		}
	}

	public JSONObject getBasketItem(JisContext jc) throws SQLException,
			JSONException {

		JSONObject paramobj = jc.getJob();
		String userid = paramobj.getString("userid");
		JSONArray ja = new JSONArray();
		JSONObject job		= new JSONObject();
        String type=null;
        
       if( ToolUtil.hasParm(paramobj, "type"))
    	   type="9";
       else
    	   type="0";

		sql = " SELECT b.name pname,b.id pid,b.imgpath,b.price,a.num,b.oldprice,b.type,b.groupbuy,f.id fid ,f.name fname ,ifnull(d.total,0) ,c.id cid,c.name cname,a.comment  FROM cs_basket_item a "
				+ " LEFT JOIN cs_product b ON a.pid=b.id "
				+ " LEFT JOIN cs_type c ON c.id = b.tid"
				+ " LEFT JOIN cs_saler f ON f.id = b.saleid"
				+ " LEFT JOIN (SELECT  sum(aa.num) total, aa.pid  FROM cs_order_item aa ,cs_order bb WHERE aa.pid=bb.id AND bb.status='1' GROUP BY aa.pid) d ON d.pid = b.id"
				+ " where a.status='"+type+"' and a.uid=?";
		System.out.println(sql);

		List<Map<String, String>> list = jc.getDb().exeQueryString(sql, userid);

		for (Map<String, String> map : list) {

			JSONObject item = new JSONObject();
			item.element("itemcode", map.get("pid"));
			item.element("name", map.get("pname"));
			item.element("buynum", map.get("num"));
			item.element("imgurl", map.get("imgpath"));
			item.element("shopid", map.get("fid"));
			item.element("shopname", map.get("fname"));
			item.element("price", map.get("price"));
			item.element("oldprice", map.get("oldprice"));
			item.element("categoryname", map.get("cname"));
			item.element("categorycode", map.get("cid"));
			item.element("itemtype", map.get("type"));
			item.element("saled", map.get("total"));
			item.element("type", map.get("groupbuy"));
			item.element("comment", map.get("comment"));

			ja.add(item);
		}
		
		
		sql="select count(*) from cs_basket_item where  status='9' and  uid=?";
		
		String count=jc.getDb().exeGetString(sql, userid);
		
		job.element("failnum", count);
		job.element("items", ja);
		

		return job
				;
	}

	public String delBasketItem(JisContext jc) throws SQLException,
			JSONException {

		JSONObject paramobj = jc.getJob();		
		String userid = paramobj.getString("userid");
		
        items=paramobj.getJSONArray("items");
        for(int i=0;i<items.size();i++){
        	item= (JSONObject)items.get(i);
        	String itemcode = item.getString("itemcode");
        	 //sql = "delete from cs_basket_item where pid=? and uid=?";
        	sql = "update cs_basket_item set status='8' where pid=? and uid=?";
       	 
    		jc.getDb().exeUpdate(sql, itemcode, userid);
        	
        }
       
		 
		
		return "Success";

	}

	public String insertAddress(JisContext jc) throws SQLException,
			JSONException {

		JSONObject paramobj = jc.getJob();
		String code = null;
		if (paramobj.containsKey("code"))
			code = paramobj.getString("code");

		String userid = paramobj.getString("userid");
		String receiver = paramobj.getString("receiver");
		String refmobile = paramobj.getString("refmobile");
		String zipcode = paramobj.getString("zipcode");
		String address = paramobj.getString("address");
		String isdefault = paramobj.getString("isdefault");
		 
		if (isdefault.equals("Y")) {
			sql = "UPDATE cs_address SET isdefault ='N' where uid = ? and isdefault ='Y'";
			jc.getDb().exeUpdate(sql, userid);
		}

		if (code == null || "".equals(code)) {
			code = UUID.randomUUID().toString();
			sql="select count(*) from cs_address where status='0' and uid=?" ;
			 String count=jc.getDb().exeGetString(sql, userid);
			 if(count.equals("0")){
				 isdefault="Y";
			 }
			sql = "INSERT INTO cs_address (uid, address, name, tel,  zipcode, isdefault,status,id) VALUES (?, ?, ?,  ?, ?, ?, ?,?)";
		
			
		} else
			sql = "UPDATE cs_address SET  uid = ?, address = ?, name = ?, tel = ?, zipcode = ?, isdefault = ?, status =?  WHERE id = ?";

		System.out.println(sql);
		
		jc.getDb().exeUpdate(sql, userid, address, receiver, refmobile,
				zipcode, isdefault,"0", code);

		return "Success";

	}

	public JSONArray getAddress(JisContext jc) throws SQLException,
			JSONException {
		JSONObject paramobj = jc.getJob();
		JSONArray ja = new JSONArray();
		String code = null;
		String userid = paramobj.getString("userid");
		String p = null;
		if (paramobj.containsKey("code"))
			code = paramobj.getString("code");
		if (code == null || "".equals(code)) {
			p = userid;
			sql = "SELECT id, uid, address, name, tel,   zipcode, isdefault FROM cs_address WHERE status='0' and  uid  =? "
					+ "  ORDER BY isdefault DESC";
		} 
		 else if (code.equals("Y")){
			 p = userid;
			 sql = "SELECT id, uid, address, name, tel,   zipcode, isdefault FROM cs_address WHERE status='0' and  uid  =? "
						+ " and isdefault='Y'";
			
		}
		else {
			p = code;
			sql = "SELECT id, uid, address, name, tel,   zipcode, isdefault FROM cs_address WHERE  status='0' and  id =? "
					+ "  ORDER BY isdefault DESC";
		}

		List<Map<String, String>> list = jc.getDb().exeQueryString(sql, p);

		for (Map<String, String> map : list) {
			JSONObject item = new JSONObject();
			item.element("code", map.get("id"));
			item.element("receiver", map.get("name"));
			item.element("refmobile", map.get("tel"));
			item.element("address", map.get("address"));
			item.element("zipcode", map.get("zipcode"));
			item.element("isdefault", map.get("isdefault"));
			ja.add(item);
		}

		return ja;
	}

	public String delAddress(JisContext jc) throws SQLException, JSONException {

		JSONObject paramobj = jc.getJob();

		String code = paramobj.getString("code");

		sql = "update  cs_address set status='1' WHERE id =?";

		jc.getDb().exeUpdate(sql, code);
		return "Success";

	}

	public String insertorder(JisContext jc) throws SQLException, JSONException {

		JSONObject paramobj = jc.getJob();
		// String orderid = paramobj.getString("orderid");
		String userid = paramobj.getString("userid");

		// double total = paramobj.getDouble("total");
		String sendaddrcode = paramobj.getString("sendaddrcode");
		items = paramobj.getJSONArray("detail");

		String sqlo = "INSERT INTO cs_order (id, buyid, createtime, total, status, addressid,saleid,groupbuy) VALUES (?, ?, ?, ?, ?, ?,?,?)";

		sql = "INSERT INTO cs_order_item (id, pid, oid, num, price,comment,buyid,saleid) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        
		String sqli="update cs_basket_item set status='1' where uid=? and pid=?";
		
		List<Pair> list = new ArrayList<Pair>();

		for (int i = 0; i < items.size(); i++) {
			item = items.getJSONObject(i);
			String type = item.getString("type");
			String shopid = item.getString("shopid");
			String itemcode = item.getString("itemcode");
			int buynum = item.getInt("buynum");
			double buyprice = item.getDouble("buyprice");
			String comment = item.getString("comment");
			String oid = UUID.randomUUID().toString();
			if (type.equals("1")) {//团购商品直接生成订单
				jc.getDb().exeUpdate(sqlo, oid, userid, ToolUtil.getDateTime(),
						buyprice * buynum, "0", sendaddrcode, shopid, 1);

			} else {
				String vv = Pair.getV(list, shopid);
				if (vv == null) {//不同商铺生成订单
					list.add(new Pair(shopid, oid));
					jc.getDb().exeUpdate(sqlo, oid, userid,
							ToolUtil.getDateTime(), buyprice * buynum, "0",
							sendaddrcode, shopid, 0);

				} else {
					oid = vv;
					String sqlu = "update cs_order set total =total+ "
							+ buyprice * buynum + " where id=?";
					jc.getDb().exeUpdate(sqlu, oid);
				}

			}

			jc.getDb().exeUpdate(sql, UUID.randomUUID().toString(), itemcode,
					oid, new Integer(buynum), new Double(buyprice), comment,
					userid, shopid);
			jc.getDb().exeUpdate(sqli,userid,itemcode);

		}

		return "Success";

	}

	public JSONObject getOrder(JisContext jc) throws SQLException,
			JSONException {
		JSONObject paramobj = jc.getJob();
		String orderid = null;
		JSONObject job = new JSONObject();
		String type = paramobj.getString("type");
		String userid = paramobj.getString("userid");
		job.element("userid", userid);
		job.element("type", type);
		if (ToolUtil.hasParm(paramobj, "orderid"))

		{
			orderid = paramobj.getString("orderid");

			sql = " SELECT a.createtime,a.status,a.saleid,c.name cname,b.id bid, b.tel,b.name adname,b.address,a.total  FROM cs_order a "
					+ " LEFT JOIN cs_address b ON b.id = a.addressid "
					+ " LEFT JOIN cs_saler c ON c.id = a.saleid  "
					+ " WHERE a.id=? ";
			List<Map<String, String>> list = jc.getDb().exeQueryString(sql,
					orderid);
			Map<String, String> map = list.get(0);
			job.element("orderid", orderid);
			job.element("ordertime", map.get("createtime"));
			job.element("sendaddrcode", map.get("bid"));
			job.element("sendaddress", map.get("address"));
			job.element("sendtel", map.get("tel"));
			job.element("status", map.get("status"));
			job.element("shopname", map.get("cname"));
			job.element("total", map.get("total"));
			job.element("sendname", map.get("adname"));

			sql = " SELECT b.id bid, b.type , b.name bname, b.imgpath, a.num, a.price,a.comment FROM  cs_order_item a,cs_product b  "
					+ " WHERE a.pid=b.id   AND a.oid=? ";

			List<Map<String, String>> listd = jc.getDb().exeQueryString(sql,
					orderid);
			job.element("kindcount", String.valueOf(listd.size()));
			items = new JSONArray();

			for (Map<String, String> mapitem : listd) {
				JSONObject item = new JSONObject();
				item.element("itemcode", mapitem.get("bid"));
				item.element("itemname", mapitem.get("bname"));
				item.element("itemtype", mapitem.get("type"));
				item.element("itemimgurl", mapitem.get("imgpath"));
				item.element("buynum", mapitem.get("num"));

				item.element("buyprice", mapitem.get("price"));
				item.element("comment", mapitem.get("comment"));

				items.add(item);

			}

			job.element("detail", items);

			return job;
		}

		else {
			StringBuffer sb = new StringBuffer();

			if ("1".equals(type)) {// 卖家订单
				/*
				 * sql=
				 * "SELECT groupbuy, count(*) cc FROM cs_order a WHERE a.buyid=? GROUP a.groupbuy"
				 * ;
				 * 
				 * List<Map<String, String>> list =
				 * jc.getDb().exeQueryString(sql, userid); Map<String, String>
				 * map =null,map2=null; String c1=null,c2=null;
				 * if(list.size()==0){ c1="0";c2="0"; } if(list.size()==1){
				 * map=list.get(0); if(map.get("groupbuy").equals("1"))
				 * {c2=map.get("cc");c1="0";} else{c1=map.get("cc");c2="0";} }
				 * map=list.get(0); map2=list.get(1);
				 * 
				 * if(map.get("groupbuy").equals("1"))
				 * {c2=map.get("cc");c1=map2.get("cc");}
				 * else{c1=map2.get("cc");c2=map.get("cc");}
				 * 
				 * 
				 * job.element("ordercount", c1); job.element("groupbuycount",
				 * c2);
				 */
				sql = "SELECT a.id orderid, a.saleid ,a.buyid ,a.status,a.createtime,a.total,c.imgpath,c.name pname ,d.name salername,b.cc ,c.groupbuy  FROM cs_order a "
						+ " INNER JOIN (SELECT oid ,max(pid) pid ,count(*) cc FROM cs_order_item WHERE saleid =? GROUP BY oid  ) b ON a.id=b.oid "
						+ " INNER JOIN cs_product c ON c.id=b.pid "
						+ " INNER JOIN cs_saler d ON d.id=c.saleid "
						+ " WHERE a.saleid=? order by a.createtime desc ";
			} else {// 买家订单

				sql = "SELECT a.id orderid, a.saleid ,a.buyid ,a.status,a.createtime,a.total,c.imgpath,c.name pname ,d.name salername,b.cc ,c.groupbuy  FROM cs_order a "
						+ " INNER JOIN (SELECT oid ,max(pid) pid ,count(*) cc FROM cs_order_item WHERE buyid =? GROUP BY oid  ) b ON a.id=b.oid "
						+ " INNER JOIN cs_product c ON c.id=b.pid "
						+ " INNER JOIN cs_saler d ON d.id=c.saleid "
						+ " WHERE a.buyid=? order by a.createtime desc ";

			}

			List<Map<String, String>> list = jc.getDb().exeQueryString(sql,
					userid, userid);
			items = new JSONArray();
			for (Map<String, String> mapitem : list) {
				JSONObject item = new JSONObject();
				item.element("orderid", mapitem.get("orderid"));
				item.element("status", mapitem.get("status"));
				item.element("shopname", mapitem.get("salername"));
				item.element("itemname", mapitem.get("pname"));
				item.element("kindcount", mapitem.get("cc"));
				item.element("groupbuy", mapitem.get("groupbuy"));
				item.element("createtime", mapitem.get("createtime"));
				item.element("total", mapitem.get("total"));
				item.element("itemimgurl", mapitem.get("imgpath"));

				items.add(item);

			}

			job.element("detail", items);

		}

		job.element("detail", items);

		return job;

	}

	public JSONObject getItemsByName(JisContext jc) throws SQLException,
			JSONException {

		JSONObject paramobj = jc.getJob();
		String name = paramobj.getString("name");
		String orderby = paramobj.getString("orderby");
		int pagenum = paramobj.getInt("pagenum");
		int pagecount = paramobj.getInt("pagecount");
		String type = paramobj.getString("type");
		JSONObject job = new JSONObject();
		JSONArray ja = new JSONArray();
		String order = getorder(orderby);
		// StringBuffer sb=new StringBuffer();

		sql = " SELECT aa.id ,aa.name aname,aa.unit ,aa.type ,aa.groupbuy,aa.oldprice,aa.price ,aa.saleid,aa.imgpath,aa.comment,cc.name cname,cc.id ccid ,IFNULL(bb.num,0) num "
				+ " FROM cs_product aa LEFT  JOIN cs_type cc ON cc.id = aa.tid  LEFT JOIN "
				+ " (SELECT sum(a.num) num,a.pid FROM cs_order_item a ,cs_order b WHERE a.oid=b.id AND b.status='0' GROUP BY a.pid ) "
				+ " bb ON aa.id=bb.pid  WHERE aa.cid=? and aa.groupbuy= ? and aa.name LIKE ?  ORDER BY "
				+ order
				+ "  LIMIT "
				+ (pagenum - 1)
				* pagecount
				+ ", "
				+ pagecount;

		String sqlc = "select count(*) cc from cs_product where  cid=? and groupbuy= ?  and name LIKE ? ";

		List<Map<String, Object>> listc = jc.getDb().exeQueryObject(sqlc,
				jc.getCid(), type, "%" + name + "%");
		int total = ((Long) listc.get(0).get("cc")).intValue();

		System.out.println(sql);
		System.out.println("---" + total);

		job.element("pagenum", pagenum);
		job.element("pagecount", pagecount);
		job.element("totalcount", total);
		job.element("totalpage", total / pagecount + 1);

		List<Map<String, String>> list = jc.getDb().exeQueryString(sql,
				jc.getCid(), type, "%" + name + "%");

		for (Map<String, String> map : list) {
			JSONObject item = new JSONObject();
			item.element("code", map.get("id"));
			item.element("name", map.get("aname"));
			item.element("extendinfo", map.get("comment"));
			item.element("categoryname", map.get("cname"));
			item.element("categorycode", map.get("ccid"));
			item.element("imageurl", map.get("imgpath"));
			item.element("price", map.get("price"));
			item.element("oldprice", map.get("oldprice"));
			item.element("shopid", map.get("saleid"));
			item.element("type", map.get("groupbuy"));
			item.element("saled", map.get("num") + map.get("unit"));
			ja.add(item);
		}

		job.element("items", ja);

		return job;

	}

	public JSONObject getItemsByType(JisContext jc) throws SQLException,
			JSONException {

		JSONObject paramobj = jc.getJob();
		String type = paramobj.getString("type");
		String code = paramobj.getString("code");
		String orderby = paramobj.getString("orderby");
		int pagenum = paramobj.getInt("pagenum");
		int pagecount = paramobj.getInt("pagecount");
		JSONObject job = new JSONObject();
		JSONArray ja = new JSONArray();
		String order = getorder(orderby);
		// StringBuffer sb=new StringBuffer();

		sql = " SELECT aa.id ,aa.name aname ,aa.type,aa.unit,aa.groupbuy ,aa.oldprice,aa.price ,aa.saleid,aa.imgpath,aa.comment,cc.name cname,cc.id ccid ,IFNULL(bb.num,0) num "
				+ " FROM cs_product aa LEFT  JOIN cs_type cc ON cc.id = aa.tid  LEFT JOIN "
				+ " (SELECT sum(a.num) num,a.pid FROM cs_order_item a ,cs_order b WHERE a.oid=b.id AND b.status='0' GROUP BY a.pid ) "
				+ " bb ON aa.id=bb.pid  WHERE aa.cid=? and aa.groupbuy= ? and (cc.id= ? or cc.pid=?) ORDER BY "
				+ order
				+ "  LIMIT "
				+ (pagenum - 1)
				* pagecount
				+ ", "
				+ pagecount;

		String sqlc = "select count(*) cc from cs_product a, cs_type b WHERE a.tid=b.id and a.cid=? and a.groupbuy= ? AND( b.id=? OR b.pid=?  )";

		List<Map<String, Object>> listc = jc.getDb().exeQueryObject(sqlc,
				jc.getCid(), type, code, code);
		int total = ((Long) listc.get(0).get("cc")).intValue();

		job.element("pagenum", pagenum);
		job.element("pagecount", pagecount);
		job.element("totalcount", total);
		job.element("totalpage", total / pagecount + 1);

		System.out.println(sql);
		System.out.println("---" + total);
		List<Map<String, String>> list = jc.getDb().exeQueryString(sql,
				jc.getCid(), type, code, code);

		for (Map<String, String> map : list) {
			JSONObject item = new JSONObject();
			item.element("code", map.get("id"));
			item.element("name", map.get("aname"));
			item.element("extendinfo", map.get("comment"));
			item.element("categoryname", map.get("cname"));
			item.element("categorycode", map.get("ccid"));
			item.element("imageurl", map.get("imgpath"));
			item.element("price", map.get("price"));
			item.element("oldprice", map.get("oldprice"));
			item.element("shopid", map.get("saleid"));
			item.element("type", map.get("groupbuy"));
			item.element("saled", map.get("num") + map.get("unit"));
			ja.add(item);
		}

		job.element("items", ja);

		return job;
	}

	public JSONObject getItemsByCode(JisContext jc) throws SQLException,
			JSONException {

		JSONObject paramobj = jc.getJob();
		String code = paramobj.getString("code");
		JSONObject job = new JSONObject();

		// StringBuffer sb=new StringBuffer();

		sql = " SELECT aa.id ,aa.name aname ,aa.groupbuy ,aa.unit,aa.type ,aa.oldprice,aa.price ,aa.saleid,aa.imgpath,aa.comment,aa.endtime,cc.name cname,cc.id ccid ,IFNULL(bb.num,0) num,dd.name dname "
				+ " FROM cs_product aa LEFT  JOIN cs_type cc ON cc.id = aa.tid "
				+ " LEFT JOIN  (SELECT sum(a.num) num,a.pid FROM cs_order_item a ,cs_order b WHERE a.oid=b.id AND b.status='1' GROUP BY a.pid )   bb ON aa.id=bb.pid "
				+ " LEFT JOIN cs_saler dd  ON dd.id = aa.saleid "
				+ " WHERE aa.cid=? and aa.id=? ";

		System.out.println(sql);

		List<Map<String, String>> list = jc.getDb().exeQueryString(sql,
				jc.getCid(), code);
		Map<String, String> map = list.get(0);

		job.element("code", map.get("id"));
		job.element("name", map.get("aname"));
		job.element("extendinfo", map.get("comment"));
		job.element("categoryname", map.get("cname"));
		job.element("categorycode", map.get("ccid"));
		job.element("imageurl", map.get("imgpath"));
		job.element("price", map.get("price"));
		job.element("oldprice", map.get("oldprice"));
		job.element("shopid", map.get("saleid"));
		job.element("shopname", map.get("dname"));
		job.element("type", map.get("groupbuy"));
		job.element("endtime", map.get("endtime"));
		job.element("saled", map.get("num") + map.get("unit"));
		
		//得到评论

		sql = "SELECT count(*) cc  FROM cs_comment WHERE pid=?";

		List<Map<String, Object>> listc = jc.getDb().exeQueryObject(sql, code);

		int commentcount = ((Long) listc.get(0).get("cc")).intValue();
		job.element("commentcount", commentcount);

		sql = " SELECT a.id uid ,a.imgurl imgurl,a.name name,b.comment cc, b.createtime ct ,b.id bid FROM cs_user a,cs_comment b WHERE a.id=b.uid and b.pid=? "
				+ "  ORDER BY b.createtime DESC  LIMIT 0,1";
		List<Map<String, String>> listcc = jc.getDb().exeQueryString(sql, code);
		item = new JSONObject();
		if (listcc.size() > 0) {
			map = listcc.get(0);
			item.element("mbrid", map.get("uid"));
			item.element("id", map.get("bid"));
			item.element("name", map.get("name"));
			item.element("content", map.get("cc"));
			item.element("imgurl", map.get("imgurl"));
			item.element("sendtime", map.get("ct"));
		}
		job.element("comment", item);

		//得道商品的图片详情
		sql = "SELECT  a.path  ,a.comment   FROM  cs_detail a where  a.pid = ? ";
		List<Map<String, String>> listi = jc.getDb().exeQueryString(sql, code);

		items = new JSONArray();
		for (Map<String, String> mapi : listi) {
			item = new JSONObject();
			item.element("url", mapi.get("path"));
			item.element("comment", mapi.get("comment"));

			items.add(item);
		}

		job.element("img", items);

		return job;
	}

	private String getorder(String orderby) {
		String order = null;
		switch (orderby) {
		case "10":
			order = "aa.name";
			break;

		case "11":
			order = " aa.name desc";
			break;

		case "20":
			order = " aa.price ";
			break;

		case "21":
			order = " aa.price desc";
			break;
		case "30":
			order = "num";
			break;
		case "31":
			order = " num desc";
			break;
		default:

			order = "aa.name";
			break;

		}
		return order;

	}

	public String orderConfirm(JisContext jc) throws SQLException,
			JSONException {

		JSONObject paramobj = jc.getJob();

		String code = paramobj.getString("code");

		sql = "update cs_order set status='1' where id=?";

		jc.getDb().exeUpdate(sql, code);
		return "Success";

	}

	public String orderSalerCancel(JisContext jc) throws SQLException,
			JSONException {

		JSONObject paramobj = jc.getJob();

		String code = paramobj.getString("code");

		sql = "update cs_order set status='2' where id=?";

		jc.getDb().exeUpdate(sql, code);
		return "Success";

	}

	public String orderBuyCancel(JisContext jc) throws SQLException,
			JSONException {

		JSONObject paramobj = jc.getJob();

		String code = paramobj.getString("code");

		sql = "update cs_order set status='3' where id=?";

		jc.getDb().exeUpdate(sql, code);
		return "Success";

	}

}
