package com.eme.ims.servlet;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.eme.ims.cache.JedisPool;
import com.eme.ims.cache.MemcachedPool;
import com.eme.ims.codec.Message;


public class SendMessageServlet extends HttpServlet{
	
	private Logger logger = LoggerFactory.getLogger(SendMessageServlet.class);

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	private ImsWebClient client;
	
	private String from;
	private String to;
	private String groupId;
	private int commandId;
	private String contents;
	

	
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		response.getWriter().write("this method is now allowed to get. please use port method to access.");
	}
	
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
		try {
			
			/**消息发送者*/
			from = request.getParameter("from");
			/**消息接收者*/
			to = request.getParameter("to");
			/**群组ID*/
			groupId = request.getParameter("groupId");
			/**命令类型*/
			commandId = Integer.parseInt(request.getParameter("commandId"));
			/**内容*/
			contents = request.getParameter("contents");
			
			Message message = new Message();
			message.setFrom( from);
			message.setTo(to);
			message.setGroupId( groupId);
			message.setCommandId(commandId);
			message.setContents(contents.getBytes());
			
			boolean result = client.sendMessage(message);
			response.getWriter().write(String.valueOf(result));
			
		} catch (Exception e) {
			//存取参数有异常
			String error = "获取参数异常:" + e.getMessage();
			logger.error(error);
			response.getWriter().write(error);
		}
	}

	

	public ImsWebClient getClient() {
		return client;
	}

	public void setClient(ImsWebClient client) {
		this.client = client;
	}
	
}
