package com.dyt.lpclub.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.lang.ref.SoftReference;
import java.util.HashMap;

import org.apache.http.Header;
import org.apache.http.HttpEntity;

import android.content.ContentResolver;
import android.content.Context;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.text.TextUtils;
import android.util.Log;

import com.dyt.lpclub.global.CommonCallBack;
import com.dyt.lpclub.global.GlobalContants;

/**
 * @ProjectName LpClub
 * @Author C.xt
 * @Version 1.0.0
 * @CreateDate： 2013-6-4 下午8:08:17
 * @JDK <JDK1.6> Description:
 */
public class UtilBitmap {

	public static void clearAll() {
		if (mIconCache != null) {
			mIconCache.clear();
			mIconCache = null;
		}
	}

	/**
	 * 
	 * @Author C.xt
	 * @Title: getAlwaysDefaultAppIcon
	 * @Description: 根据res ID获取图片Bitmap
	 * @return Bitmap
	 * @throws
	 * @date 2013-6-4 下午8:13:38
	 */
	public static Bitmap getBmByResid(Resources res, int resId) {
		Bitmap draw = BitmapFactory.decodeResource(res, resId);
		return draw;
	}

	/**
	 * 
	 * @Author C.xt
	 * @Title: getDwByResid
	 * @Description: 根据res ID获取图片Drawable
	 * @return Drawable
	 * @throws
	 * @date 2013-6-4 下午8:38:19
	 */
	public static Drawable getDwByResid(Resources res, int resId) {
		Drawable draw = res.getDrawable(resId);
		return draw;
	}

	/**
	 * 
	 * @Author C.xt
	 * @Title: executeThread
	 * @Description: 图片加载执行线程
	 * @return void
	 * @throws
	 * @date 2013-6-12上午10:30:19
	 */
	public static void executeThread(Runnable thread) {
		UtilThread.excuteLoadIcon(thread);
	}

	/** 图标缓存 */
	public static HashMap<String, SoftReference<Bitmap>> mIconCache;

	/**
	 * 
	 * @Author C.xt
	 * @Title: executeThread
	 * @Description: 加载图片，线程模式
	 * @param iconKey
	 * @param iconFilePath
	 * @param iconUrl
	 * @return void
	 * @throws
	 * @date 2013-6-12上午10:30:19
	 */
	public static void loadIconInThread(final String iconKey, final String iconFilePath, final String iconUrl, final CommonCallBack callBack) {
		executeThread(new Runnable() {

			@Override
			public void run() {

				boolean success = loadIcon(iconKey, iconFilePath, iconUrl);
				if (success && callBack != null)
					callBack.invoke();
			}
		});
	}

	public static void loadIconInThread4Group(final String packageName, final String iconFilePath, final String iconUrl, final CommonCallBack callBack) {
		executeThread(new Runnable() {

			@Override
			public void run() {

				boolean success = loadIcon("GROUP" + packageName, iconFilePath, iconUrl);
				if (success && callBack != null)
					callBack.invoke();
			}
		});
	}

	/**
	 * 
	 * 
	 * @Author C.xt
	 * @Title: loadIcon
	 * @Description: 加载图标
	 * @return boolean true:成功
	 * @param loadIconKey
	 *            缓存逐渐
	 * @param iconFilePath
	 *            图片地址
	 * @param iconUrl
	 *            图片url
	 * @throws
	 * @date 2013-6-12上午11:52:22
	 */
	public static boolean loadIcon(final String loadIconKey, final String iconFilePath, final String iconUrl) {
		boolean loadSuccess = false;
		try {
			String fileDir = iconFilePath.substring(0, iconFilePath.lastIndexOf("/"));
			UtilFile.createDir(fileDir);
			Bitmap bmp = null;
			if (UtilFile.isFileExits(iconFilePath)) {
				bmp = BitmapFactory.decodeFile(iconFilePath);
			}
			if (bmp != null) {
				//将图标添加到缓存
				addIconToCache(loadIconKey, bmp);
				loadSuccess = true;

			} else {
				String newIconFilePath = saveInternateImage(iconUrl, iconFilePath);
				if (!TextUtils.isEmpty(newIconFilePath)) {
					bmp = BitmapFactory.decodeFile(iconFilePath);
					addIconToCache(loadIconKey, bmp);
					loadSuccess = true;
				}
			}

		} catch (Exception e) {
		}

		return loadSuccess;
	}

	/**
	 * 
	 * 
	 * @Author C.xt
	 * @Title: saveInternateImage
	 * @Description: 保存网络图片资源
	 * @param urlString
	 *            图片地址
	 * @param filePath
	 *            保存地址
	 * @return String
	 * @throws
	 * @date 2013-6-12上午11:55:35
	 */
	public static String saveInternateImage(String urlString, String filePath) {

		InputStream is = null;
		Bitmap bmp = null;
		try {
			String fileDir = filePath.substring(0, filePath.lastIndexOf("/"));
			UtilFile.createDir(fileDir);
			//			HttpResponse response = WebUtil.getSimpleHttpGetResponse(urlString, null);
			//			if (response == null)
			//				return null;
			UtilHttp httpCommon = new UtilHttp(urlString);
			HttpEntity entity = httpCommon.getResponseAsEntityGet(null);
			if (entity == null)
				return null;
			Header resHeader = entity.getContentType();
			String contentType = resHeader.getValue();
			CompressFormat format = null;
			if (contentType != null && contentType.equals(GlobalContants.IMAGE_PNG)) {
				format = Bitmap.CompressFormat.PNG;
			} else {
				format = Bitmap.CompressFormat.JPEG;
			}
			is = entity.getContent();
			BitmapFactory.Options options = new BitmapFactory.Options();
			options.inJustDecodeBounds = true;
			// 获取这个图片的宽和高
			bmp = BitmapFactory.decodeStream(is, null, options);
			options.inJustDecodeBounds = false;
			//计算缩放比
			int be = (int) (options.outHeight / (float) 200);
			if (be <= 0)
				be = 1;
			options.inSampleSize = be;
			entity = httpCommon.getResponseAsEntityGet(null);
			is = entity.getContent();
			//重新读入图片，注意这次要把options.inJustDecodeBounds 设为 false哦
			bmp = BitmapFactory.decodeStream(is, null, options);

			if (saveBitmap2file(Bitmap.createScaledBitmap(bmp, 80, 80, true), filePath, format))
				return filePath;
			else
				//失败，删除文件
				UtilFile.delFile(filePath);
		} catch (Exception e) {
			e.printStackTrace();
			Log.d("test", "function saveInternateImage expose exception:" + e.toString());
			//失败，删除文件
			UtilFile.delFile(filePath);
		} finally {

			try {
				if (is != null)
					is.close();
				if (bmp != null && !bmp.isRecycled()) {
					bmp.recycle();
					System.gc();
				}
			} catch (IOException e) {
			}
		}

		return null;
	}

	public static String saveInternateImageNormal(String urlString, String filePath) {

		InputStream is = null;
		Bitmap bmp = null;
		try {
			String fileDir = filePath.substring(0, filePath.lastIndexOf("/"));
			UtilFile.createDir(fileDir);
			//			HttpResponse response = WebUtil.getSimpleHttpGetResponse(urlString, null);
			//			if (response == null)
			//				return null;
			UtilHttp httpCommon = new UtilHttp(urlString);
			HttpEntity entity = httpCommon.getResponseAsEntityGet(null);
			if (entity == null)
				return null;
			Header resHeader = entity.getContentType();
			String contentType = resHeader.getValue();
			CompressFormat format = null;
			if (contentType != null && contentType.equals(GlobalContants.IMAGE_PNG)) {
				format = Bitmap.CompressFormat.PNG;
			} else {
				format = Bitmap.CompressFormat.JPEG;
			}
			is = entity.getContent();
			bmp = BitmapFactory.decodeStream(is);
			if (saveBitmap2file(bmp, filePath, format))
				return filePath;
			else
				//失败，删除文件
				UtilFile.delFile(filePath);
		} catch (Exception e) {
			Log.d("test", "function saveInternateImage expose exception:" + e.toString());
			//失败，删除文件
			UtilFile.delFile(filePath);
		} finally {

			try {
				if (is != null)
					is.close();
				if (bmp != null && !bmp.isRecycled()) {
					bmp.recycle();
					System.gc();
				}
			} catch (IOException e) {
			}
		}

		return null;
	}

	/**
	 * 
	 * 
	 * @Author C.xt
	 * @Title: addIconToCache
	 * @Description: 添加图标缓存
	 * @param loadIconKey
	 *            保存key
	 * @param icon
	 *            void
	 * @throws
	 * @date 2013-6-12上午11:56:31
	 */
	public static void addIconToCache(String loadIconKey, Bitmap icon) {

		if (icon != null && !icon.isRecycled()) {
			HashMap<String, SoftReference<Bitmap>> iconCache = getIconCache();
			iconCache.put(loadIconKey, new SoftReference<Bitmap>(icon));
		}

	}

	/**
	 * 
	 * 
	 * @Author C.xt
	 * @Title: getIconCache
	 * @Description: 图片缓存
	 * @return HashMap<String,SoftReference<Bitmap>>
	 * @throws
	 * @date 2013-6-12上午11:57:15
	 */
	public static HashMap<String, SoftReference<Bitmap>> getIconCache() {
		if (mIconCache == null) {
			mIconCache = new HashMap<String, SoftReference<Bitmap>>();
		}
		return mIconCache;
	}

	/**
	 * 
	 * 
	 * @Author C.xt
	 * @Title: getIconFromCache
	 * @Description: 获取图片
	 * @param loadIconKey
	 *            主键
	 * @return Bitmap
	 * @throws
	 * @date 2013-6-12下午12:18:15
	 */
	public static Bitmap getIconFromCache(String loadIconKey) {
		HashMap<String, SoftReference<Bitmap>> iconCache = getIconCache();
		SoftReference<Bitmap> sfBmp = iconCache.get(loadIconKey);
		if (sfBmp != null)
			return sfBmp.get();
		return null;
	}

	/**
	 * 
	 * 
	 * @Author C.xt
	 * @Title: saveBitmap2file
	 * @Description: 生成图片文件Bitmap.CompressFormat.JPEG格式
	 * @param bmp
	 *            生成图片
	 * @param filePath
	 *            图片地址
	 * @return boolean
	 * @throws
	 * @date 2013-6-12上午11:57:50
	 */
	public static boolean saveBitmap2file(Bitmap bmp, String filePath) {
		CompressFormat format = Bitmap.CompressFormat.JPEG;
		int quality = 100;
		OutputStream stream = null;
		try {
			stream = new FileOutputStream(filePath);
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}
		if (null == stream)
			return false;
		return bmp.compress(format, quality, stream);
	}

	/**
	 * 
	 * 
	 * @Author C.xt
	 * @Title: saveBitmap2file
	 * @Description: 生成图片文件，支持格式
	 * @param bmp
	 * @param filePath
	 * @param format
	 * @return boolean
	 * @throws
	 * @date 2013-6-12上午11:59:07
	 */
	public static boolean saveBitmap2file(Bitmap bmp, String filePath, CompressFormat format) {
		if (bmp == null || bmp.isRecycled())
			return false;

		String fileDir = filePath.substring(0, filePath.lastIndexOf("/"));
		UtilFile.createDir(fileDir);

		int quality = 100;
		OutputStream stream = null;
		try {
			stream = new FileOutputStream(filePath);
		} catch (Exception e) {
			e.printStackTrace();
		}

		if (null == stream)
			return false;

		return bmp.compress(format, quality, stream);
	}

	/**
	 * 
	 * 
	 * @Author C.xt
	 * @Title: getImageFile
	 * @Description: 获取图片文件，指定大小来获取，如果指定的大小超过原图尺寸，则按原图尺寸返回
	 * @param contentUri
	 *            图片资源
	 * @param ctx
	 * @param targetWidth
	 *            宽
	 * @param targetHeight
	 *            高
	 * @return Bitmap
	 * @throws Exception
	 * @date 2013-6-12下午12:09:06
	 */
	public static Bitmap getImageFile(Uri contentUri, Context ctx, int targetWidth, int targetHeight) throws Exception {
		Bitmap tmpBmp = null;

		try {
			if (contentUri == null)// 文件不存在
				return null;
			ContentResolver cr = ctx.getContentResolver();
			BitmapFactory.Options opts = new BitmapFactory.Options();
			opts.inJustDecodeBounds = true;
			// 先测量图片的尺寸
			if (contentUri.toString().indexOf("content") != -1)
				BitmapFactory.decodeStream(cr.openInputStream(contentUri), null, opts);
			else
				BitmapFactory.decodeFile(contentUri.toString(), opts);

			int imWidth = opts.outWidth; // 图片宽
			int imHeight = opts.outHeight; // 图片高

			int scale = 1;
			if (imWidth > imHeight)
				scale = Math.round((float) imWidth / targetWidth);
			else
				scale = Math.round((float) imHeight / targetHeight);
			scale = scale == 0 ? 1 : scale;

			opts.inJustDecodeBounds = false;
			opts.inSampleSize = scale;
			if (contentUri.toString().indexOf("content") != -1)
				tmpBmp = BitmapFactory.decodeStream(cr.openInputStream(contentUri), null, opts);
			else {
				FileInputStream fis = new FileInputStream(new File(contentUri.toString()));
				tmpBmp = BitmapFactory.decodeStream(fis, null, opts);
			}
		} catch (OutOfMemoryError e) {
			e.printStackTrace();
		}
		return tmpBmp;
	}

	public static Bitmap zoomImage(Bitmap bgimage, double newWidth, double newHeight) {
		// 获取这个图片的宽和高
		float width = bgimage.getWidth();
		float height = bgimage.getHeight();
		float max = width > height ? width : height;
		float scale = 0.5f;
		if (max > 1024) {
			scale = 0.05f;
		} else if (max > 640) {
			scale = 0.01f;
		} else if (max > 320) {
			scale = 0.1f;
		}
		// 创建操作图片用的matrix对象
		Matrix matrix = new Matrix();
		// 计算宽高缩放率
		float scaleWidth = ((float) newWidth) / width;
		float scaleHeight = ((float) newHeight) / height;
		// 缩放图片动作
		matrix.postScale(scale, scale);
		Bitmap bitmap = Bitmap.createBitmap(bgimage, 0, 0, (int) width, (int) height, matrix, true);
		return bitmap;
	}
}
