package com.dyt.lpclub.activity.domain;

import java.util.List;

/**
 * 类描述:群组POJO
 * 
 * @Author:solotiger
 * @Date:2013-6-4
 */
public class Group implements Comparable<Group>{

	private int id;
	private String name;
	private boolean state;
	private String remark;
	private String pic;
	private String news;
	private int type;
	private int resId;
	private int parent;
	
	public String spell;
	@Override
	public String toString() {
		String state = this.state ? "0" : "1";
		return id+"@"+name+"@"+userid+"@"+state+"@"+remark+"@"+pic+"@"+news+"@"+type+"@"+resId+"@"+parent+"@"+memberCount;
	}
	
	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Group other = (Group) obj;
		if (other.id == this.id)
			return true;
		else
			return false;
	}

	//子组中显示组员数量
	private int memberCount;

	private List<Group> subGroup;
	
	private String userid;

	public String getUserid() {
		return userid;
	}

	public void setUserid(String userid) {
		this.userid = userid;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getRemark() {
		return remark;
	}

	public void setRemark(String remark) {
		this.remark = remark;
	}

	public String getPic() {
		return pic;
	}

	public void setPic(String pic) {
		this.pic = pic;
	}

	public String getNews() {
		return news;
	}

	public void setNews(String news) {
		this.news = news;
	}

	public int getResId() {
		return resId;
	}

	public void setResId(int resId) {
		this.resId = resId;
	}

	public int getParent() {
		return parent;
	}

	public void setParent(int parent) {
		this.parent = parent;
	}

	public List<Group> getSubGroup() {
		return subGroup;
	}

	public void setSubGroup(List<Group> subGroup) {
		this.subGroup = subGroup;
	}

	public boolean getState() {
		return state;
	}

	public void setState(boolean state) {
		this.state = state;
	}

	public int getType() {
		return type;
	}

	public void setType(int type) {
		this.type = type;
	}

	public int getMemberCount() {
		return memberCount;
	}

	public void setMemberCount(int memberCount) {
		this.memberCount = memberCount;
	}

	@Override
	public int compareTo(Group another) {
		return this.spell.compareTo(another.spell);
	}

	
}
