package eme.modual.person;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import net.sf.json.JSONException;
import net.sf.json.JSONObject;
import eme.EmeBusinessException;
import eme.JisContext;
import eme.modual.team.Team;

public class PersonUtil {

	public Map login(JisContext jc) throws SQLException, EmeBusinessException,
			JSONException {
		JSONObject paramobj = jc.getJob();
		String loginid = paramobj.getString("loginid");
		String password = paramobj.getString("password");

		Map<String, String> map = new HashMap<String, String>();
		map.put("loginid", loginid);
		map.put("password", password);
		map.put("cid", jc.getCid());
		Map<String, Object> person = jc.getSession().selectOne("Person.login",
				map);

		if (person == null)
			throw new EmeBusinessException("登陆失败！");

		return person;

	}

	public JSONObject savePerson(JisContext jc) throws SQLException,
			EmeBusinessException, JSONException {
		JSONObject paramobj = jc.getJob();

		JSONObject job = new JSONObject();
		String userid = null;

		Person person = (Person) JSONObject.toBean(paramobj, Person.class);

		userid = person.getUserid();

		if (userid == null || "".equals(userid)) {

			int i = jc.getSession().selectOne("Person.checkinsert", person);

			if (i >= 1)
				throw new EmeBusinessException("账号已被注册！");
			userid = UUID.randomUUID().toString();

			person.setUserid(userid);
			person.setCid(jc.getCid());
			person.setStatus("0");
			jc.getSession().insert("Person.save_person", person);
		} else {

			jc.getSession().insert("Person.update_person", person);

		}
		job.element("userid", userid);
		job.element("name", person.getName());
		job.element("imgpath", "");
		job.element("label", person.getLabel());
		job.element("loginid", person.getLoginid());
		return job;
	}

	public JSONObject getArea(JisContext jc) throws SQLException,
			EmeBusinessException, JSONException {
		// JSONObject paramobj = jc.getJob();

		List<Area> area = jc.getSession().selectList("Person.get_area");
		JSONObject job = new JSONObject();
		job.element("areaitems", area);
		return job;

	}

	public JSONObject getTeam(JisContext jc) throws SQLException,
			EmeBusinessException, JSONException {
		// JSONObject paramobj = jc.getJob();
		String cid = jc.getCid();

		List<Team> teamlist = jc.getSession()
				.selectList("Person.get_team", cid);
		JSONObject job = new JSONObject();
		job.element("teamitems", teamlist);
		return job;

	}

	public Map<String,Object> getPerson(JisContext jc) throws SQLException,
			EmeBusinessException, JSONException {
		JSONObject paramobj = jc.getJob();

		String userid = paramobj.getString("userid");

		// Map<String ,Object> map =
		// jc.getSession().selectOne("Person.get_team", userid);
		// JSONObject job = new JSONObject();
		// job.putAll(map);
		Map<String,Object> map = jc.getSession().selectOne("Person.get_person", userid);

	 

		return map;

	}

	public JSONObject getImgGroupList(JisContext jc) throws SQLException,
			EmeBusinessException, JSONException {
		JSONObject paramobj = jc.getJob();
		String userid = paramobj.getString("userid");
		String toid = paramobj.getString("toid");
		int pagecount = paramobj.getInt("pagecount");
		int pagenum = paramobj.getInt("pagenum");

		pagenum = (pagenum - 1) * pagecount;

		Map<String, Object> map = new HashMap<String, Object>();
		map.put("userid", userid);
		map.put("toid", toid);
		map.put("pagecount", pagecount);
		map.put("pagenum", pagenum);
		map.put("type", "0");

		List<ImgGroup> list = jc.getSession().selectList("Person.get_imgGroup",	map);

		int totalcount = jc.getSession().selectOne("Person.get_imgGroupCount", map);

		int totalpage = totalcount / pagecount;

		if (totalcount > totalpage * pagecount)
			totalpage++;

		JSONObject job = new JSONObject();
		job.element("userid", userid);
		job.element("toid", toid);
		job.element("totalpage", totalpage);
		job.element("totalcount", totalcount);
		job.element("items", list);

		return job;

	}

	public Map<String, Object> inputImgGroup(JisContext jc) throws SQLException,
			EmeBusinessException, JSONException {
		JSONObject paramobj = jc.getJob();
		String groupid = paramobj.getString("groupid");

	  
		Map<String, Object> map;
		Map<String, Object> map2;
		map = jc.getSession().selectOne("Person.get_imgGroupInfo", groupid);
		map2 = jc.getSession().selectOne("Person.get_imgGroupGoodCommentCount", groupid);
		int totalcount = jc.getSession().selectOne("Person.get_imgCount", groupid);
		if (map2!=null)
		{  map.putAll(map2);
		
		}
		else{
			
			map.put("goodcount", 0);
			map.put("commentcount", 0);
		}
		map.put("totalcount", totalcount);

		return map;

	}
	
	 
	
	
	public Map<String, Object> inputImgGroupComment(JisContext jc) throws SQLException,
					EmeBusinessException, JSONException {
				JSONObject paramobj = jc.getJob();
				String groupid = paramobj.getString("groupid");
			 
				int pagecount = paramobj.getInt("pagecount");
				int pagenum = paramobj.getInt("pagenum");
				
				pagenum = (pagenum - 1) * pagecount;
				
				Map<String, Object> map = new HashMap<String, Object>();
				map.put("groupid", groupid);
				map.put("pagecount", pagecount);
				map.put("pagenum", pagenum); 
				
				Map<String ,Object> rmap= jc.getSession().selectOne("Person.input_ImgGroupComment",	map);
				
				int totalcount = jc.getSession().selectOne("Person.get_imgGroupCommentCount", groupid);
				
				List<Img> list = jc.getSession().selectList("Person.get_img",	groupid);
				List<ImgGroupComment> rl=	(List<ImgGroupComment>)rmap.get("items");
				String commid=rl.get(0).getCommentid();
				
				if (commid==null || "".equals(commid)){
				 
					rmap.remove("items");
					rmap.put("items", new ArrayList());
				}
					
				int totalpage = totalcount / pagecount;
				
				if (totalcount > totalpage * pagecount)
					totalpage++;
				
				//JSONObject job = new JSONObject();
				 
				rmap.put("totalpage", totalpage);
				rmap.put("totalcount", totalcount);
				rmap.put("imgitems", list);
				
				return rmap;

}
	
	
	
	public String  sendGood(JisContext jc) throws SQLException, EmeBusinessException,
	JSONException {
		JSONObject paramobj = jc.getJob();
		String userid = paramobj.getString("userid");
		String groupid = paramobj.getString("groupid");
		
		Map<String, String> map = new HashMap<String, String>();
		map.put("userid", userid);
		map.put("groupid", groupid);
		map.put("id", UUID.randomUUID().toString());
		 jc.getSession().insert("Person.send_good",	map);
		
		 
		
		return "Success";
		
		}
	 
	public String  sendComment(JisContext jc) throws SQLException, EmeBusinessException,
	JSONException {
		JSONObject paramobj = jc.getJob();
		String userid = paramobj.getString("userid");
		String groupid = paramobj.getString("groupid");
		String comment = paramobj.getString("comment");
		Map<String, String> map = new HashMap<String, String>();
		map.put("userid", userid);
		map.put("groupid", groupid);
		map.put("comment", comment);
		map.put("id", UUID.randomUUID().toString());
		 jc.getSession().insert("Person.send_comment",	map); 
		
		return "Success";
		
		}
	
	
	
	public String  delImgGroup(JisContext jc) throws SQLException, EmeBusinessException,
	JSONException {
		JSONObject paramobj = jc.getJob();
		String userid = paramobj.getString("userid");
		String groupid = paramobj.getString("groupid");
	 
		Map<String, String> map = new HashMap<String, String>();
	//	map.put("userid", userid);
		map.put("groupid", groupid);
		  
		
		 jc.getSession().update("Person.del_imgGroup",	map);  
		return "Success";
		
		}
	
	public String  setImg(JisContext jc) throws SQLException, EmeBusinessException,
	JSONException {
		JSONObject paramobj = jc.getJob();
		String userid = paramobj.getString("userid");
		String imgid = paramobj.getString("imgid");
	 
		Map<String, String> map = new HashMap<String, String>();
	 	map.put("userid", userid);
		map.put("imgid", imgid);
		  
		
		 jc.getSession().update("Person.set_img",	map);  
		 
		String path= jc.getSession().selectOne("get_headimg",imgid) ;
		 
		return path;
		
		}
	 
	public String  uploadImgGroup(JisContext jc) throws SQLException, EmeBusinessException,
	JSONException {
		JSONObject paramobj = jc.getJob();
		String userid = paramobj.getString("userid");
		String type = paramobj.getString("type");
		String label = paramobj.getString("label");
		System.out.println("---"+paramobj);
		System.out.println("---"+paramobj.get("info"));
		List<String> list=(List<String>)paramobj.get("info");
	 
		Map<String, String> map = new HashMap<String, String>();
		String groupid=UUID.randomUUID().toString();
	 	map.put("userid", userid);
		map.put("type", type);
		map.put("label", label); 
		map.put("id", groupid); 
		 jc.getSession().insert("Person.insert_imgGroup",	map); 
		// jc.getSession().commit();
		for(String item:list){
			Map<String, String> map1 = new HashMap<String, String>();
			map1.put("id", UUID.randomUUID().toString()); 
		 	map1.put("groupid", groupid);
			map1.put("path", item);		 
			
			jc.getSession().insert("Person.insert_img",	map1);  
			
		}
		
		
		 
		 
		return "Success";
		
		}
	 

}
