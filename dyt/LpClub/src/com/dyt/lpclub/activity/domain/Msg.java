package com.dyt.lpclub.activity.domain;

import java.io.Serializable;

public class Msg implements Comparable<Msg> ,Serializable{
	
	private static final long serialVersionUID = 1L;
	public long id;
	public String localId;
	public int type;
	public String content;
	public int userid;
	public int group_id;
	public String TIME;
	public String send_time_milli;
	public String state;
	public String thumb;

	public int newMsgPos;
	
	public String soundTime;
	public boolean soundLocal;
	
	public int newmsgid;
	@Override
	public int compareTo(Msg another) {
		return another.TIME.compareTo(this.TIME);
	}
	
	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Msg other = (Msg) obj;
		if (other.localId.equals(this.localId))
			return true;
		else
			return false;
	}
	
	/**
	 * 
	* @Author 								C.xt
	* @Title: 								toString
	* @Description:							转换sql语句
	* @return								void 
	* @throws							
	* @date 								2013-6-19
	 */

	@Override
	public String toString() {
		String soundLocal = this.soundLocal ? "0" : "1";
		return id+"@"+content+"@"+userid+"@"+group_id+"@"+type+"@"+TIME+"@"+state+"@"+thumb+"@"+newMsgPos+"@"+soundTime+"@"+soundLocal+"@"+newmsgid;
	}
}