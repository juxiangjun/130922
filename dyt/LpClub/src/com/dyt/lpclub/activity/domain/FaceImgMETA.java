package com.dyt.lpclub.activity.domain;

import java.util.HashMap;

/**
 * @ProjectName							LpClub
 * @Author								C.xt				
 * @Version         					1.0.0
 * @CreateDate：							2013-6-28上午0:45:21
 * @JDK             					<JDK1.6>
 * Description:							匹配表情
 */
public class FaceImgMETA {


	/**
	 * 
		 * 
		* @Author 								C.xt
		* @Title: 								getFaceImgMap
		* @Description:							表情字符匹配
		* @return								HashMap<String,String>
		* @throws								
		* @date 								2013-6-29下午3:53:15
	 */
	public static HashMap<String, String> getFaceImgMap() {
		if (keyResMap == null) {
			init();
		}
		return keyResMap;
	}
	
	/**
	 * 记录主键id和资源图片的对应关系
	 */
	private static HashMap<String, String> keyResMap;

	private static String[][] mIds = {

			{ "001", "hee hee" }, 
			{ "002", "lol" },
			{ "003", "nice" },
			{ "004", "dizzy" },
			{ "005", "cry" }, 
			{ "006", "greedy" },
			{ "007", "crazy" },

			{ "008", "hum" }, 
			{ "009", "cute" },
			{ "010", "angry" },
			{ "011", "sweat" },
			{ "012", "smile" }, 
			{ "013", "sleepy" },
			{ "014", "money" },

			{ "015", "razz" }, 
			{ "016", "cool" },
			{ "017", "bad luck" },
			{ "018", "surprise" }, 
			{ "019", "curse" },
			{ "020", "contempt" },
			{ "021", "booger" },

			{ "022", "lust" }, 
			{ "023", "clap" },
			{ "024", "sad" },
			{ "025", "think" }, 
			{ "026", "sick" },
			{ "027", "kiss" },
			{ "028", "hug" }, 
			{ "029", "supercilious" },
			{ "030", "right hum" },
			{ "031", "left hum" },

			{ "032", "quiet" }, 
			{ "033", "grievance" },
			{ "034", "yawn" },
			{ "035", "beat" }, 
			{ "036", "question" },
			{ "037", "winking" }, 
			{ "038", "shy" },
			{ "039", "gonna cry" },
			{ "040", "bye" },
			{ "041", "silent" },
			{ "042", "strong" },
			{ "043", "weak" },
			{ "044", "awesome" },
			{ "045", "meaningless" },
			{ "046", "onlooker" }, 
			{ "047", "mighty" },
			{ "048", "camera" }, 
			{ "049", "car" }, 
			{ "050", "plane" },
			{ "051", "love" },
			{ "052", "ultraman" },
			{ "053", "rabbit" },
			{ "054", "panda" },
			{ "055", "no" },
			{ "056", "ok" }, 
			{ "057", "like" }, 
			{ "058", "tempt" },
			{ "059", "yeah" }, 
			{ "060", "love u" },
			{ "061", "fist" },
			{ "062", "poor" }, 
			{ "063", "shake hand" },
			{ "064", "rose" }, 
			{ "065", "heart" },
			{ "066", "broken heart" }, 
			{ "067", "pig" },
			{ "068", "coffee" },
			{ "069", "mic" }, 
			{ "070", "moon" },
			{ "071", "sun" }, 
			{ "072", "beer" }, 
			{ "073", "adorable" },
			{ "074", "gift" }, 
			{ "075", "follow" }, 
			{ "076", "clock" },
			{ "077", "bike" }, 
			{ "078", "cake" }, 
			{ "079", "scarf" },
			{ "080", "glove" },
			{ "081", "snow" }, 
			{ "082", "snowman" },
			{ "083", "hat" }, 
			{ "084", "leaf" }, 
			{ "085", "football" }

	};

	/**
	 * 初始化
	 */
	private static void init() {
		keyResMap = new HashMap<String, String>();
		for (String[] ids : mIds) {
			keyResMap.put(ids[0], ids[1]);
		}
	}
}
