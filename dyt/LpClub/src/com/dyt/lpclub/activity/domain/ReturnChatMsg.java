package com.dyt.lpclub.activity.domain;

public class ReturnChatMsg {
	public String msg;
	public boolean success;
	public ReturnObj obj;

	public class ReturnObj {
		public int id;
		public int type;
		public String content;
		public int userid;
		public int group_id;
		public String TIME;
		public String send_time_milli;
		public String state;
		public String thumb;
	}
}
