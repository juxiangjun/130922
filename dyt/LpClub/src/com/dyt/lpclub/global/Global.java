package com.dyt.lpclub.global;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.dyt.lpclub.activity.ActivityMain;
import com.dyt.lpclub.activity.domain.Group;
import com.dyt.lpclub.activity.domain.User;

public class Global {

	private static Global global;

	private ActivityMain mContext;

	private String encodeStr;
	
	public static boolean isLogin = false;
	public static boolean isOpen;
	public static boolean isTalkOpen;
	public static int userid;

	private Object lock1 = new Object(), lock2  = new Object();
	
	private Global() {
	}

	public static Global getMe() {
		if (null == global) {
			global = new Global();
		}
		return global;
	}

	private User globalUser;
	private Map<Integer, Group> groupMap;
	private List<User> userList;

	public User getGlobalUser() {
		return globalUser;
	}

	public void setGlobalUser(User globalUser) {
		this.globalUser = globalUser;
	}

	public Map<Integer, Group> getGroupList() {
		synchronized (lock1) {
			return groupMap;
		}
	}
	
	public void setGroupList(List<Group> groupList) {
		synchronized (lock1) {
			if (groupMap == null) {
				groupMap = new HashMap<Integer, Group>();
			}
			for (Group g : groupList) {
				groupMap.put(g.getId(), g);
				if (null != g.getSubGroup())
					for (Group cg : g.getSubGroup()) {
						groupMap.put(cg.getId(), cg);
					}
			}
		}
	}

	public List<User> getUserList() {
		synchronized (lock2) {
			return userList;
		}
	}

	public void setUserList(List<User> userList) {
		synchronized (lock2) {
			this.userList = userList;
		}
	}

	public void clearAll() {
		if (globalUser != null) {
			globalUser = null;
		}
		if (userList != null) {
			userList = null;
		}
		if (groupMap != null) {
			groupMap = null;
		}
	}

	public ActivityMain getmContext() {
		return mContext;
	}

	public void setmContext(ActivityMain mContext) {
		this.mContext = mContext;
	}

	public String getEncodeStr() {
		return encodeStr;
	}

	public void setEncodeStr(String encodeStr) {
		this.encodeStr = encodeStr;
	}
}
