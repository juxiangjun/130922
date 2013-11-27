package com.dyt.lpclub.Receiver;

import android.app.Activity;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import cn.jpush.android.api.JPushInterface;

import com.dyt.lpclub.R;
import com.dyt.lpclub.activity.ActivityWelcome;
import com.dyt.lpclub.activity.domain.ReturnChatMsg;
import com.dyt.lpclub.global.Global;
import com.google.gson.Gson;

public class GlobalReceiver extends BroadcastReceiver {

	//声明通知（消息）管理器
	private NotificationManager m_NotificationManager;
	private PendingIntent m_PendingIntent;
	//声明Notification对象
	private Notification m_Notification;

	@Override
	public void onReceive(Context context, Intent intent) {
		
		if(!Global.isLogin){
			return;
		}
		
		Bundle bundle = intent.getExtras();
		if (m_NotificationManager == null) {
			m_NotificationManager = (NotificationManager) context.getSystemService(Activity.NOTIFICATION_SERVICE);
		}
		if (JPushInterface.ACTION_MESSAGE_RECEIVED.equals(intent.getAction())) {
			String result = bundle.getString(JPushInterface.EXTRA_MESSAGE);
			Gson gs = new Gson();
			if (null != result) {
				ReturnChatMsg rcm = gs.fromJson(result, ReturnChatMsg.class);
				if (rcm != null && rcm.obj != null) {
					//					final Msg msg = new Msg();
					//					msg.id = rcm.obj.id;
					//					msg.group_id = rcm.obj.group_id;
					//					msg.userid = rcm.obj.userid;
					//					msg.type = rcm.obj.type;
					//					msg.TIME = rcm.obj.TIME;
					//					msg.content = rcm.obj.content;
					//					msg.thumb = rcm.obj.thumb;
					//					msg.state = rcm.obj.state;
					if (!Global.isOpen) {
						showNotification(context);
					}
				}
			}
		} else {
			Log.d("lpclub", "Unhandled intent - " + intent.getAction());
		}
	}

	private void showNotification(Context context) {
		//点击通知时转移内容
		Intent intent = new Intent(context, ActivityWelcome.class);
		//intent.addCategory(WINDOW_SERVICE);
		//主要是设置点击通知时显示内容的类
		m_PendingIntent = PendingIntent.getActivity(context, 0, intent, 0); //如果转移内容则用m_Intent();
		//构造Notification对象
		m_Notification = new Notification();
		//设置通知在状态栏显示的图标
		m_Notification.icon = R.drawable.app_logo;
		//当我们点击通知时显示的内容
		m_Notification.tickerText = "有新消息";
		//通知时发出默认的声音
		m_Notification.defaults = Notification.DEFAULT_SOUND;
		//设置通知显示的参数
		m_Notification.setLatestEventInfo(context, "大业堂", "有新消息", m_PendingIntent);
		//可以理解为执行这个通知
		m_NotificationManager.notify(0, m_Notification);
	}

}
