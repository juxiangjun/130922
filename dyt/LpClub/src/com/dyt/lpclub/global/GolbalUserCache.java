package com.dyt.lpclub.global;

import java.lang.ref.SoftReference;
import java.util.HashMap;

import com.dyt.lpclub.activity.domain.User;
import com.dyt.lpclub.activity.domain.result.AbstractResult;
import com.dyt.lpclub.activity.domain.result.UserResult;
import com.dyt.lpclub.util.UtilHttp;
import com.dyt.lpclub.util.UtilString;
import com.dyt.lpclub.util.UtilThread;
import com.google.gson.Gson;

/**
 * @ProjectName							LpClub
 * @Author								C.xt				
 * @Version         					1.0.0
 * @CreateDate：							2013-6-12下午12:29:24
 * @JDK             					<JDK1.6>
 * Description:							
 */
public class GolbalUserCache {
	public interface GetUserCallBack {
		public void invoke(User user);
	}

	/**user缓存*/
	private static HashMap<String, SoftReference<User>> mUserCache;

	/**
	 * 
		 * 
		* @Author 								C.xt
		* @Title: 								getUserCache
		* @Description:							获取user缓存
		* @return								HashMap<String,SoftReference<User>>
		* @throws								
		* @date 								2013-6-12下午12:41:05
	 */
	public static HashMap<String, SoftReference<User>> getUserCache() {
		if (mUserCache == null) {
			mUserCache = new HashMap<String, SoftReference<User>>();
		}
		return mUserCache;
	}

	/**
	 * 
	 * 
	 * @Author 								C.xt
	 * @Title: 								getUserFromCache
	 * @Description:						获取user缓存
	 * @param userId							
	 * @return								User
	 * @throws								
	 * @date 								2013-6-12下午12:34:14
	 */
	public static User getUserFromCache(String userId) {
		if(UtilString.isEmpty(userId)){
			return null;
		}
		HashMap<String, SoftReference<User>> iconCache = getUserCache();
		SoftReference<User> sfUser = iconCache.get(userId);
		if (sfUser != null) {
			return sfUser.get();
		}
		return null;
	}
	/**
	 * 
		 * 
		* @Author 								C.xt
		* @Title: 								getUserFromCache
		* @Description:							一直取到为止user缓存
		* @param userId							
		* @param CommonCallBack					回调
		* @return								User
		* @throws								
		* @date 								2013-6-12下午12:34:14
	 */
	public static User getUserFromCache(String userId , GetUserCallBack callBack) {
		if(UtilString.isEmpty(userId)){
			return null;
		}
		
		HashMap<String, SoftReference<User>> iconCache = getUserCache();
		SoftReference<User> sfUser = iconCache.get(userId);
		if (sfUser != null && sfUser.get() != null) {
			if(null != callBack){
				callBack.invoke(sfUser.get());
			}
			return sfUser.get();
		}else{
			getUserFromInternet(userId, callBack);
		}
		return null;
	}

	/**
	 * 
		 * 
		* @Author 								C.xt
		* @Title: 								getUserFromInternet
		* @Description:							通过服务端获取user
		* @param userId	
		* @param callBack						获取成功之后回调
		* @return								User
		* @throws								
		* @date 								2013-6-12下午12:48:13
	 */
	public static void getUserFromInternet(final String userId,
			final GetUserCallBack callBack) {

		UtilThread.executeMore(new Runnable() {
			@Override
			public void run() {
				String url = GlobalContants.GET_MEMBER_INFO;
				url += "&userid=" + userId;
				url += "&encodeStr=" + Global.getMe().getEncodeStr();
				UtilHttp http = new UtilHttp(url, "UTF-8");
				String result = http
						.getResponseAsStringGET(new HashMap<String, String>());
				if (result != null) {
					try {
						Gson gson = new Gson();
						UserResult userResult = gson.fromJson(result, UserResult.class);
						//账号失效
						if (userResult.returnCode == AbstractResult.RETURN_CODE_INVALID) {
							return;
						}
						User user = userResult.obj;
						GolbalUserCache.getUserCache().put(userId,
								new SoftReference<User>(user));
						if(null != callBack){
							callBack.invoke(user);
						}
					} catch (Exception e) {
						e.printStackTrace();
					}
				} else {
				}
			}
		});
	}

}
