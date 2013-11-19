package com.eme.ims.handler;


public class BaseHandler {
	
	protected IMessageAdapter iMessageAdapter;
	
	public BaseHandler(IMessageAdapter iMessageAdapter) {
		this.iMessageAdapter = iMessageAdapter;
	}
	
	

}
