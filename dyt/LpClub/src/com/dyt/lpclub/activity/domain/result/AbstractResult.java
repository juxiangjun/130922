package com.dyt.lpclub.activity.domain.result;

public class AbstractResult {

	public final static int RETURN_CODE_NORMAL = 0, RETURN_CODE_FAIL = 100, RETURN_CODE_INVALID = 101;

	public String msg;
	/**
	 * 0 正常 100 通用错误代码 101 登陆信息失效
	 */
	public int returnCode;
	public boolean success;
}
