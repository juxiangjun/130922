package com.eme.ims.utils;

public abstract class StoppableThread extends Thread {

	protected volatile boolean stop = false;
	
	public abstract void run();
	
	public void stopThread() {
		stop = true;
	}
}
