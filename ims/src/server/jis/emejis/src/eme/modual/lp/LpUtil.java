package eme.modual.lp;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import net.sf.json.JSONException;
import net.sf.json.JSONObject;
import eme.EmeBusinessException;
import eme.JisContext;
import eme.util.ToolUtil;

public class LpUtil {

	public Map<String, Object> getFriend(JisContext jc) throws SQLException,
			EmeBusinessException, JSONException {
		JSONObject paramobj = jc.getJob();

		Map<String, String> imap = new HashMap<String, String>();
		String toid = paramobj.getString("toid");
		String userid = paramobj.getString("userid");
		imap.put("userid", userid);
		imap.put("toid", toid);

		Map<String, Object> map = jc.getSession().selectOne("Lp.get_friend",imap);

		List<Map<String, String>> list = jc.getSession().selectList("Lp.get_img", toid);
		map.put("items", list);
		return map;

	}

	public JSONObject getFriendList(JisContext jc) throws SQLException,
			EmeBusinessException, JSONException {
		JSONObject paramobj = jc.getJob();

		Map<String, Object> imap = new HashMap<String, Object>();
		
		String userid = paramobj.getString("userid");
		int pagecount=paramobj.getInt("pagecount");
		int pagenum=paramobj.getInt("pagenum");
		
		pagenum = (pagenum - 1) * pagecount;
 if (ToolUtil.hasParm(paramobj, "name")){
	 imap.put("name", paramobj.getString("name"));
		 }
		
		imap.put("userid", userid);
		imap.put("cid",jc.getCid());
		imap.put("pagecount", pagecount);
		imap.put("pagenum", pagenum);

		List<Map<String, String>> list = jc.getSession().selectList("Lp.get_friendlist",imap);
		int totalcount= jc.getSession().selectOne("Lp.get_friendlistcount",imap);
	 
		int totalpage = totalcount / pagecount;

		if (totalcount > totalpage * pagecount)
			totalpage++;

		JSONObject job = new JSONObject();
		job.element("userid", userid);
		job.element("pagenum", pagenum);
		job.element("pagecount", pagecount);
		job.element("totalpage", totalpage);
		job.element("totalcount", totalcount);
		job.element("items", list);

		
		  
		return job;

	}
	
	
	
	
	
	
	public String  addFriend(JisContext jc) throws SQLException, EmeBusinessException,
	JSONException {
		JSONObject paramobj = jc.getJob();
		String userid = paramobj.getString("userid");
		String toid = paramobj.getString("toid");
	 
		Map<String, String> map = new HashMap<String, String>();
	 	map.put("userid", userid);
		map.put("toid", toid);
		map.put("type", "0"); 
		jc.getSession().insert("Lp.insert_lpfriend",	map);  
		 
		 
		 
		 
		 Map<String, String> map2 = new HashMap<String, String>();
			map2.put("userid", toid);
			map2.put("toid", userid);
			map2.put("type", "0");		 
		 jc.getSession().insert("Lp.insert_lpfriend",	map2);  
		 
		 
		 //todo
		  
		 
		 
		return "Success";
		
		}
	
	
	public String  addBlack(JisContext jc) throws SQLException, EmeBusinessException,
	JSONException {
		JSONObject paramobj = jc.getJob();
		String userid = paramobj.getString("userid");
		String toid = paramobj.getString("toid");
	 
		Map<String, String> map = new HashMap<String, String>();
	 	map.put("userid", userid);
		map.put("toid", toid);
		map.put("type", "1"); 
		jc.getSession().insert("Lp.insert_lpfriend",	map);  
		 
		  
		 
		 //todo
		  
		 
		 
		return "Success";
		
		}
	
	public String  delFriend(JisContext jc) throws SQLException, EmeBusinessException,
	JSONException {
		JSONObject paramobj = jc.getJob();
		String userid = paramobj.getString("userid");
		String toid = paramobj.getString("toid");
	 
		Map<String, String> map = new HashMap<String, String>();
	 	map.put("userid", userid);
		map.put("toid", toid);
	 
		jc.getSession().insert("Lp.del_lpfriend",	map);   
		 
		 Map<String, String> map2 = new HashMap<String, String>();
			map2.put("userid", toid);
			map2.put("toid", userid);
			 	 
		 jc.getSession().insert("Lp.del_lpfriend",	map2);  
		 
		 
		 //todo
		  
		 
		 
		return "Success";
		
		}
	

}
