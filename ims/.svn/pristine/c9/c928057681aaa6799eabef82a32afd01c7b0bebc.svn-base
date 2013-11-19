package com.eme.ims.manager;

import org.apache.mina.core.service.IoHandlerAdapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.Toast;

import com.eme.ims.client.ClientHandler;
import com.eme.ims.client.MessageClient;
import com.eme.ims.codec.Message;
import com.eme.ims.codec.MsgProtocol;
import com.eme.ims.codec.MsgProtocol.Command;
import com.eme.ims.handler.IMessageAdapter;
import com.eme.ims.utils.PropertyConfig;
import com.eme.ims.utils.StringUtils;

public class ChatManager {

	private static final String LOG_TAG = "MessageManager";
	private static MessageClient client = null;
	private PropertyConfig config;
	private Context ctx;
	
	private static ChatManager chatManager = null;
	
	private EditText etMessageSent;
	private Button btnSendMessage;
	private Button btnSendVoice;
	
	private Message message;
	
	private UIViewFactory factory= null;
	
	
	public static ChatManager getInstance(Context ctx, 
			IMessageAdapter adapter, PropertyConfig config, Message message) {
		
		if (chatManager == null) {
			chatManager = new ChatManager(ctx, adapter, config, message);
		}
		
		return chatManager;
	}
	
	
	public LinearLayout getChatLinearLayout() {
		LinearLayout ll = new LinearLayout(ctx);
		
		ll.addView(btnSendVoice,
	            new LinearLayout.LayoutParams(
	                ViewGroup.LayoutParams.WRAP_CONTENT,
	                ViewGroup.LayoutParams.WRAP_CONTENT,
	                0));
		
		ll.addView(etMessageSent,
	            new LinearLayout.LayoutParams(
	                ViewGroup.LayoutParams.WRAP_CONTENT,
	                ViewGroup.LayoutParams.WRAP_CONTENT,
	                0));
		
		ll.addView(btnSendMessage,
	            new LinearLayout.LayoutParams(
	                ViewGroup.LayoutParams.WRAP_CONTENT,
	                ViewGroup.LayoutParams.WRAP_CONTENT,
	                0));
		return ll;
	}
	
	public boolean disconnect() {
		return client.disconnect();
	}
	
	private boolean sendTextMessage(String text) {
		
		if (message.getTo() != "00000-00000-00000-00000-00000-000000") {
			message.setCommandId(MsgProtocol.Command.SEND_P2P_MESSAGE);
		} else {
			message.setCommandId(MsgProtocol.Command.SEND_P2G_MESSAGE);
		}
		
		message.setType(MsgProtocol.MsgType.TEXT);
		message.setContents(text);
		
		if (!client.sessionIsAvailable()) {
			this.connect();
		}
		
		return client.sendMessage(message);
	}
	
	private boolean sendAudioMessage() {
		
		if (message.getTo() != "00000-00000-00000-00000-00000-000000") {
			message.setCommandId(MsgProtocol.Command.SEND_P2P_MESSAGE);
		} else {
			message.setCommandId(MsgProtocol.Command.SEND_P2G_MESSAGE);
		}
		
		message.setType(MsgProtocol.MsgType.VOICE);
		message.setContents("");
		return client.sendMessage(message);
	}
	
	
	
	private boolean connect() {
		
		boolean result = false;
		
		if (client.sessionIsAvailable()) 
			client.disconnect();
		
		if (client.connect()) {
			Log.d(LOG_TAG,"connected to server successfully.");
			message.setCommandId(Command.REGISTRATION);
			client.sendMessage(message);
//			try {
//				Thread.sleep(1000);
//			} catch (InterruptedException e) {
//				e.printStackTrace();
//			}
			result = true;
		} else {
			Log.e(LOG_TAG,"this client will exit immediately");
		}
		
		return result;
		
	}
	
	private View.OnClickListener onButtonSendMessageListener() {
		return new View.OnClickListener() {
			@SuppressLint("ShowToast")
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				String text = etMessageSent.getText().toString();
				if (StringUtils.isBlank(text)) {
					Toast.makeText(ctx, "You can't send out an empty text.", 2);
				} else {
					Log.d(LOG_TAG, "begin to send message out.");
					sendTextMessage(text);
				}
			}
		};
	}
	
	private View.OnClickListener onButtonSendVoiceListener() {
		return new View.OnClickListener() {
			@SuppressLint("ShowToast")
			@Override
			public void onClick(View v) {
				sendAudioMessage();
			}
		};
	}
	
	private ChatManager(final Context ctx, IMessageAdapter adapter, PropertyConfig config, Message message) {
		this.config = config;
		this.ctx = ctx;
		this.factory = UIViewFactory.INSTANCE;
		this.initComponents();
		this.message = message;
		if (client == null) {
        	IoHandlerAdapter handler = new ClientHandler(adapter);
        	client = new MessageClient(this.config, handler);
        	if (this.connect()) {
        		Log.d(LOG_TAG, "");
        	} else {
        		Log.e(LOG_TAG, "failed to connect to server.");
        	}
        }
	}
	
	
	private void initComponents() {
		etMessageSent = factory.createEditText(ctx, "Message to send");
		btnSendMessage = factory.createTextButton(ctx, "M", this.onButtonSendMessageListener());
		btnSendVoice = factory.createTextButton(ctx, "V", this.onButtonSendVoiceListener());
	}
	
	
 }
