package com.eme.ims.cache;

import java.util.ArrayList;
import java.util.List;

import redis.clients.jedis.Jedis;

public class JedisPool {
	
	private int poolSize;
	private String host;
	private int port;
	private List<Jedis> pool;
	
	public JedisPool(String host, int port, int poolSize) {
		this.poolSize = poolSize;
		this.host = host;
		this.port = port;
		pool = new ArrayList<Jedis>();
		
		for (int i=0; i<poolSize; i++) {
			Jedis jedis = new Jedis(host, port);
			pool.add(jedis);
		}
	}
	
	public Jedis getJedis() {
		Jedis result = null;
		synchronized(pool) {
			if (pool.size()>0) {
				result = pool.get(0);
				pool.remove(0);
			}
		}
		return result;
	}
	
	public void recycle(Jedis jedis) {
		synchronized(pool) {
			pool.add(jedis);
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
