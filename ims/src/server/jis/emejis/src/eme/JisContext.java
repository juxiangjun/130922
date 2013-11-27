package eme;

 

import org.apache.ibatis.session.SqlSession;

import net.sf.json.JSONObject;

public class JisContext {
	private String cid;
	private JSONObject job;
	private EmeDB db=null; 
	private SqlSession session=null; 
	
	public EmeDB getDb() {
		return db;
	}
	public void setDb(EmeDB db) {
		this.db = db;
	}
	public String getCid() {
		return cid;
	}
	public void setCid(String _cid) {
		this.cid = _cid;
	}
	public JSONObject getJob() {
		return job;
	}
	public void setJob(JSONObject job) {
		this.job = job;
	}
	public JisContext(String cid, JSONObject job,EmeDB db) {
		super();
		this.cid = cid;
		this.job = job;
		this.db=db;
	}
	
	public JisContext(String cid, JSONObject job) {
		super();
		this.cid = cid;
		this.job = job;
		 
	}
	public SqlSession getSession() {
		return session;
	}
	public void setSession(SqlSession session) {
		this.session = session;
	}
	
	
	
	
    
}
