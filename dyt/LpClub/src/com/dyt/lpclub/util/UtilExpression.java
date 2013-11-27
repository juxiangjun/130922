package com.dyt.lpclub.util;

import java.lang.reflect.Field;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.style.ImageSpan;
import android.util.Log;

import com.dyt.lpclub.R;
import com.dyt.lpclub.activity.domain.FaceImgMETA;

/**
 * @ProjectName							LpClub
 * @Author								C.xt				
 * @Version         					1.0.0
 * @CreateDate：							2013-6-20下午4:45:24
 * @JDK             					<JDK1.6>
 * Description:							正则表达式Util
 */
public class UtilExpression {
	
	/**
	 * 
		* @Author 								C.xt
		* @Title: 								dealExpression
		* @Description:							对spanableString进行正则判断，如果符合要求，则以表情图片代替
		* @param context
		* @param spannableString
		* @param patten
		* @param start
		* @throws SecurityException
		* @throws NoSuchFieldException
		* @throws NumberFormatException
		* @throws IllegalArgumentException
		* @throws IllegalAccessException		void
		* @throws								
		* @date 								2013-6-29下午3:20:03
	 */
    public static void dealExpression(Context context,SpannableString spannableString, Pattern patten, int start) throws SecurityException, NoSuchFieldException, NumberFormatException, IllegalArgumentException, IllegalAccessException {
    	Matcher matcher = patten.matcher(spannableString);
        while (matcher.find()) {
            String bitMapName = matcher.group(1);
            String value = matcher.group(0);
            if (matcher.start() < start) {
                continue;
            }
//            FaceImgMETA.getFaceImgMap().get(value);
            bitMapName = bitMapName.replace(" ", "");
            Field field = R.drawable.class.getDeclaredField(bitMapName);
			int resId = Integer.parseInt(field.get(null).toString());		//通过上面匹配得到的字符串来生成图片资源id
            if (resId != 0) {
                Bitmap bitmap = BitmapFactory.decodeResource(context.getResources(), resId);	
                ImageSpan imageSpan = new ImageSpan(bitmap);				//通过图片资源id来得到bitmap，用一个ImageSpan来包装
                int end = matcher.start() + value.length();					//计算该图片名字的长度，也就是要替换的字符串的长度
                spannableString.setSpan(imageSpan, matcher.start(), end, Spannable.SPAN_INCLUSIVE_EXCLUSIVE);	//将该图片替换字符串中规定的位置中
                if (end < spannableString.length()) {						//如果整个字符串还未验证完，则继续。。
                    dealExpression(context,spannableString,  patten, end);
                }
                break;
            }
        }
    }
    
	/**
	 * 
		 * 
		* @Author 								C.xt
		* @Title: 								getExpressionString
		* @Description:							得到一个SpanableString对象，通过传入的字符串,并进行正则判断
		* @param context
		* @param str
		* @param rex
		* @return								SpannableString
		* @throws								
		* @date 								2013-6-29下午3:20:27
	 */
	public static SpannableString getExpressionString(Context context,String str,String rex){
    	SpannableString spannableString = new SpannableString(str);
        Pattern sinaPatten = Pattern.compile(rex, Pattern.CASE_INSENSITIVE);		//通过传入的正则表达式来生成一个pattern
        try {
            dealExpression(context,spannableString, sinaPatten, 0);
        } catch (Exception e) {
            Log.e("dealExpression", e.getMessage());
        }
        return spannableString;
    }
	

}