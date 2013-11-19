package com.eme.ims.handler;

import org.apache.mina.core.session.IoSession;

import android.util.Log;

import com.eme.ims.codec.Message;
import com.eme.ims.codec.MsgProtocol;


public class ClientDispatcher {
	
	
	private static ClientDispatcher clientDispatcher = null;
	private MessageHandler messageHandler = null;
	
	public static ClientDispatcher getInstance(IMessageAdapter iMessageAdapter) {
		if (clientDispatcher == null) {
			clientDispatcher = new ClientDispatcher(iMessageAdapter);
		}
		return clientDispatcher;
	}
	
	private ClientDispatcher(IMessageAdapter iMessageAdapter) {
		this.messageHandler = MessageHandler.getInstance(iMessageAdapter);
	}
	
	
	
	public void dispatch(IoSession session, Message message) {
		
		Log.d("ClientDispatcher", message.getCommandId().toString());
		
		switch(message.getCommandId().intValue()) {
			case MsgProtocol.Command.ON_RECEIVED_P2P_MESSAGE: this.onReceivedP2PMessage(session, message); break;
			case MsgProtocol.Command.SEND_P2P_MESSAGE_RESPONSE: this.onGetP2PMessageResponse(session, message); break;
			default: this.unknown();
		}
		
	}
	
	private void onReceivedP2PMessage(IoSession session, Message message) {
		messageHandler.onReceivedP2PMessage(session, message);
	}
	
	
	private void onGetP2PMessageResponse(IoSession session, Message message) {
		messageHandler.onGetP2PMessageResponse(session, message);
	}
	
	private void unknown() {
		Log.w("ClientDispatcher", "unknown action code... this request will be dropped by client.");
	}

}
