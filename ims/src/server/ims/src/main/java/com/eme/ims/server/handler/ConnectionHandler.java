package com.eme.ims.server.handler;import org.apache.mina.core.session.IoSession;import org.slf4j.Logger;import org.slf4j.LoggerFactory;import com.eme.ims.codec.Message;import com.eme.ims.server.SessionPoolManager;public enum ConnectionHandler {	INSTANCE;	SessionPoolManager manager = SessionPoolManager.INSTANCE;	public static Logger logger = LoggerFactory.getLogger(ConnectionHandler.class);			public void connect(IoSession session,  Message message) {		logger.debug("connection["+message.getFrom()+"] has been registed in connection pool...");		manager.add(message.getFrom(), session);	}		public void disconnect(Message message) {		manager.remove(message.getFrom());	}			}