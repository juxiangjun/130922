package com.dyt.lpclub.activity.domain;

import java.io.Serializable;

public class User implements Comparable<User>, Serializable {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	public int id;
	public String account;
	public int state;
	public String name;
	public String password;
	public String devicetype;
	public String deviceid;
	public String pic;
	public String thumb;
	public int sex;
	public String area1;
	public String area2;
	public String pos;
	public String job1;
	public String job2;
	public String sign;

	public String groupIds;

	public int keyUserId;

	@Override
	public int compareTo(User another) {
		return new Integer(another.id).compareTo(id);
	}

	@Override
	public String toString() {
		return id + "@" + name + "@" + account + "@" + state + "@" + name + "@" + pic + "@" + password + "@" + devicetype + "@" + deviceid + "@" + pic + "@"
				+ sex;
	}
	
	@Override
	public boolean equals(Object o) {
		if (o == this)
			return true;
		if (!(o instanceof User))
			return false;
		User other = (User) o;
		return id == other.id;
	}
	
	@Override
	public int hashCode() {
		int result = 17;
		result = 37 * result + name.hashCode();
		result = 37 * result + id;
		return result;
	}
}
