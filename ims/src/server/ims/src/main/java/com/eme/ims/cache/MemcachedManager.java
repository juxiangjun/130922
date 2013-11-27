package com.eme.ims.cache;

import net.spy.memcached.MemcachedClient;

public class MemcachedManager {

	private static MemcachedClient client = null;
	
	private static MemcachedManager memcachedManager = null;
	
	private MemcachedPool memcachedPool;
	
	public static MemcachedManager getInstance() {
		
		if (memcachedManager == null) {
			memcachedManager = new MemcachedManager();
		}
		return memcachedManager;
	}
	
	private MemcachedManager() {
		this.client = this.memcachedPool.getMemcachedClient();
	}

	public MemcachedPool getMemcachedPool() {
		return memcachedPool;
	}

	public void setMemcachedPool(MemcachedPool memcachedPool) {
		this.memcachedPool = memcachedPool;
	}
	
	
	
 }
