package com.dyt.lpclub.activity.domain;

import java.util.List;

/**
 * 类描述:消息界面POJO
 * 
 * @Author:solotiger
 * @Date:2013-6-11
 */
public class NewMsg implements Comparable<NewMsg> {
	public int id;
	public String name;
	public boolean state;
	public String pic;
	public String news;
	public int type;
	public int parent;
	public int memberCount;
	public int mainGroupId;
	public String mainGroupName;
	public String mainGroupPic;
	public List<Msg> msgs;
	public int userId;

	public String TIME;
	public String content;
	public int msgType;
	public int count;
	
	@Override
	public int compareTo(NewMsg another) {
		return another.TIME.compareTo(this.TIME);
	}
	/**
	 * 
	* @Author 								C.xt
	* @Title: 								toString
	* @Description:							转换sql语句
	* @return								void 
	* @throws							
	* @date 								2013-6-23
	 */

	@Override
	public String toString() {
		String state = this.state ? "0" : "1";
		return id+"@"+name+"@"+state+"@"+pic+"@"+news+"@"+type+"@"+parent+"@"+memberCount+"@"+mainGroupId+"@"+mainGroupName+"@"+mainGroupPic+"@"+userId;
	}
}
