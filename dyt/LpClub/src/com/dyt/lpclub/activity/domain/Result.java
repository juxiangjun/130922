package com.dyt.lpclub.activity.domain;

/**
 * 类描述:
 * 
 * @Author:solotiger
 * @Date:2013-6-4
 */
public class Result {
	public String msg;
	/**
	 * 0 正常 100 通用错误代码 101 登陆信息失效
	 */
	public int returnCode;
	public boolean success;
	public Object obj;
	public Object obj1;
}
