package com.dyt.lpclub.util;

import java.util.Arrays;
import java.util.List;

import android.util.Log;

/**
 * @ProjectName							LpClub
 * @Author								C.xt				
 * @Version         					1.0.0
 * @CreateDate：							2013-6-20下午4:45:24
 * @JDK             					<JDK1.6>
 * Description:							容器Util
 */
public class UtilContainer {

	/**
	 * 
		 * 
		* @Author 								C.xt
		* @Title: 								getSubListPage
		* @Description:							截取list
		* @param list							目标list
		* @param skip							开始
		* @param pageSize						结束
		* @return								List<T>
		* @throws								
		* @date 								2013-6-20下午4:45:56
	 */
	public static <T> List<T> getSubListPage(List<T> list, int startIndex,
			int endIndex) {
		if (list == null || list.isEmpty()) {
			return list;
		}
		startIndex =  startIndex  < 0 ? 0 : startIndex;
		if (startIndex > endIndex || startIndex > list.size()) {
			return list.subList(0, 0);
		}
		if (endIndex > list.size()) {
			endIndex = list.size();
		}
		return list.subList(startIndex, endIndex);
	}
	
	/**
	 * 
		 * 
		* @Author 								C.xt
		* @Title: 								indexOf
		* @Description:							indexof位置
		* @param objects
		* @param object
		* @return								int
		* @throws								
		* @date 								2013-6-23下午7:51:18
	 */
	public static int indexOf(Object[] objects, Object object) {

		if (object == null) {
			for (int i = 0, size = objects.length; i < size; i++)
				if (objects[i] == null)
					return i;
		} else {
			for (int i = 0, size = objects.length; i < size; i++)
				if (object.equals(objects[i]))
					return i;
		}
		return -1;
	}
	
	/**
	 * 
		 * 
		* @Author 								C.xt
		* @Title: 								contains
		* @Description:							数组是否包含
		* @param objects
		* @param object
		* @return								boolean
		* @throws								
		* @date 								2013-6-23下午7:51:00
	 */
	public static boolean contains(Object[] objects, Object object) {
		return indexOf(objects, object) >= 0;
	}
}


