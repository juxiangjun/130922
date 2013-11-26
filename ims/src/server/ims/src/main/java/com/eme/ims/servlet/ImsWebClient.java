package com.eme.ims.servlet;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import net.spy.memcached.MemcachedClient;

import org.apache.mina.core.service.IoHandlerAdapter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import redis.clients.jedis.Jedis;

import com.eme.ims.cache.JedisPool;
import com.eme.ims.cache.MemcachedPool;
import com.eme.ims.client.ClientHandler;
import com.eme.ims.client.MessageClient;
import com.eme.ims.codec.Message;
import com.eme.ims.codec.MsgProtocol;
import com.eme.ims.utils.PropertyConfig;

public class ImsWebClient {
	
	private static final MessageClient client = new MessageClient();
	private final static Logger logger = LoggerFactory.getLogger(ImsWebClient.class);

	private String configFileName;
	
	private MemcachedPool memcachedPool;
	private JedisPool	jedisPool;
	
	public ImsWebClient(String configFileName) {
		this.configFileName = configFileName;
		this.initialize();
	}
	
	private  void initialize () {
		
		PropertyConfig config = new PropertyConfig(configFileName, 0);
		String host = config.getString("server.host");
		Integer port = config.getInteger("server.port");
		
		IoHandlerAdapter handler = new ClientHandler();
		
		client.setHost(host);
		client.setPort(port);
		client.setHandler(handler);

		if (client.connect(config)) {
			logger.debug("connected to server successfully.");
			Message message = new Message();
			register(client, message);
		} else {
			logger.debug("failed to connect to server, this client will exit immediately");
			System.exit(0);
		}
	}
	
	private void register(MessageClient client, Message message) {
		message.setFrom("00000-00000-00000-00000-00000-000001");
		message.setCommandId(MsgProtocol.Command.REGISTRATION);
		client.sendMessage(message);
	}
	
	public boolean sendMessage(Message message) {
		
		int commandId = message.getCommandId();
		
		/**
		 * 维护群组列表.
		 * ============================================================================================================
		 */
		if (commandId == MsgProtocol.Command.SEND_GROUP_INVITATION)  {
			return this.addMemberToGroup(message);
		}
		
		if (commandId == MsgProtocol.Command.QUIT_GROUP 
					|| commandId == MsgProtocol.Command.REMOVE_MEMBER_FROM_GROUP ) {
			return this.removeMemberFromGroup(message);
		}
		
		/**
		 * 存入消息队列
		 * ============================================================================================================
		 */
		this.addMessageToMemcached(message);
		
		/**
		 * 转发消息.
		 * ============================================================================================================
		 */
		return client.sendMessage(message);
	}
	
	/**
	 * 新成员加入到群组当中
	 * @param message
	 */
	
	private boolean addMemberToGroup(Message message) {
		boolean result = true;
		Jedis jedis = this.jedisPool.getJedis();
		String key = message.getGroupId();
		Object obj = jedis.get(key);
		String[] members = message.getContents().toString().split(",");
		for (String member : members) {
			if (obj == null) {
				jedis.set(key, member);
			} else {
				jedis.append(key, member);
			}
			this.addMessageToMemcached(message);
			client.sendMessage(message);
		}
		jedisPool.recycle(jedis);
		return result;
	}
	
	/**
	 * 移除群组中的成员
	 * @param message
	 */
	
	private boolean removeMemberFromGroup(Message message) {
		
		boolean result = true;
		Jedis jedis = this.jedisPool.getJedis();
		
		synchronized(jedis) {
			String key = message.getGroupId();
			Object obj = jedis.get(key);
			String[] removedMembers = message.getContents().toString().split(",");
			if (obj != null) {
				@SuppressWarnings("unchecked")
				List<String> members = (List<String>) obj;
				int i=0;
				for (String removedMember : removedMembers) {
					for (String member : members) {
						if (member.equals(removedMember)) {
							message.setTo(removedMember);
							this.addMessageToMemcached(message);
							client.sendMessage(message);
							members.remove(i);
						} 
					}
				}
			
				
				for (String member : members) {
					if (i==0) {
						jedis.set(key, member);
					} else {
						jedis.append(key, member);
					}
				}
			} 
		}
		jedisPool.recycle(jedis);
		return result;
	}
	
	/**
	 * 保存消息
	 * @param message
	 */
	private void addMessageToMemcached(Message message) {
		
		MemcachedClient client = this.memcachedPool.getMemcachedClient();
		String key = "MSG_" + this.getHourKey();
		Object obj = client.get(key);
		if (null == obj) {
			client.set(key, 60, message);
		} else {
			client.append(System.nanoTime(), key, message);
		}
		
		this.memcachedPool.recycle(client);
		
	}
	
	private String getHourKey() {
		Date date = new Date();
		SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd-hh");
		return df.format(date);
	}
	
	public void setMemcachedPool(MemcachedPool memcachedPool) {
		this.memcachedPool = memcachedPool;
	}

	public void setJedisPool(JedisPool jedisPool) {
		this.jedisPool = jedisPool;
	}

}
