package com.dyt.lpclub.util;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * @ProjectName							LpClub
 * @Author								C.xt				
 * @Version         					1.0.0
 * @CreateDate：							2013-6-4 下午8:08:17
 * @JDK             					<JDK1.6>
 * Description:							统一线程管理
 */
public class UtilThread {

	/** 非固定数量线程池*/
	private static ExecutorService moreExecutorService = Executors.newCachedThreadPool();
//	private static ExecutorService moreExecutorService = Executors.newFixedThreadPool(1);

	/**
	 * 
	* @Author 								C.xt
	* @Title: 								executeMore
	* @Description:							
	* @return@param command:								void				 
	* @throws							
	* @date 								2013-6-4 下午8:50:11
	 */
	public static void executeMore(Runnable command) {
		moreExecutorService.execute(command);
	}
	
	/** 线程池 */
	private static ExecutorService executorService = Executors.newFixedThreadPool(10);

	/**
	 * 
		 * 
		* @Author 								C.xt
		* @Title: 								excuteLoadIcon
		* @Description:							图片专用刷线程
		* @param runnable						void
		* @throws								
		* @date 								2013-6-12下午12:01:22
	 */
	public static void excuteLoadIcon(Runnable runnable){
		executorService.execute(runnable);
	}
}
