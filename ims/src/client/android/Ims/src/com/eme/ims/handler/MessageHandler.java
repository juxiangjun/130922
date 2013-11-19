package com.eme.ims.handler;

import org.apache.mina.core.session.IoSession;

import android.util.Log;
import com.eme.ims.codec.Message;

public class MessageHandler extends BaseHandler {
	
	private MessageHandler(IMessageAdapter iMessageAdapter) {
		super(iMessageAdapter);
	}

	private static MessageHandler messageHandler = null;
	
	public static MessageHandler getInstance(IMessageAdapter iMessageAdapter) {
		if (messageHandler == null) {
			messageHandler = new MessageHandler(iMessageAdapter);
		}
		return messageHandler;
	}
	
	public void onReceivedP2PMessage(IoSession session, Message message) {
		Log.d("MessageHandler", "received p2p message from ["+message.getTo()+"]");
		this.iMessageAdapter.onReceivedP2PMessage(message);
	}
	
	public void sendMessage(IoSession session, Message message) {
		
	}
	
	public void onGetP2PMessageResponse(IoSession session, Message message) {
		Log.d("MessageHandler", "Get p2p message response from server");
		this.iMessageAdapter.onGetP2PMessageResponse(message);
	}

}
