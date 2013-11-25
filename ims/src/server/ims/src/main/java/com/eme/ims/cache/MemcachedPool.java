package com.eme.ims.cache;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.SocketAddress;
import java.util.ArrayList;
import java.util.List;

import net.spy.memcached.MemcachedClient;


public class MemcachedPool {
	
	private int poolSize;
	private String host;
	private int port;
	private List<MemcachedClient> pool;
	
	
	public MemcachedPool(String host, int port, int poolSize) {
		this.poolSize = poolSize;
		this.host = host;
		this.port = port;
		pool = new ArrayList<MemcachedClient>();
		
		for (int i=0; i<poolSize; i++) {
			MemcachedClient memcachedClient;
			try {
				memcachedClient = new MemcachedClient(new InetSocketAddress(host, port));
				pool.add(memcachedClient);
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	
	public MemcachedClient getMemcachedClient() {
		MemcachedClient result = null;
		synchronized(pool) {
			if (pool.size()>0) {
				result = pool.get(0);
				pool.remove(0);
			}
		}
		return result;
	}
	
	public void recycle(MemcachedClient memcachedClient) {
		synchronized(pool) {
			pool.add(memcachedClient);
		}
	}
	
	public int getPoolSize() {
		return poolSize;
	}
	public void setPoolSize(int poolSize) {
		this.poolSize = poolSize;
	}
	public String getHost() {
		return host;
	}
	public void setHost(String host) {
		this.host = host;
	}
	public int getPort() {
		return port;
	}
	public void setPort(int port) {
		this.port = port;
	}
	

}
