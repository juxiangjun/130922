package com.dyt.lpclub.global;

import java.lang.ref.SoftReference;
import java.util.HashMap;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import com.dyt.lpclub.util.UtilBitmap;
import com.dyt.lpclub.util.UtilString;

public class LocalBitmapCache {

	private static final int MAXW = 80, MAXH = 80;

	/** user缓存 */
	private static HashMap<String, SoftReference<Bitmap>> mBitmapCache;

	private static HashMap<String, SoftReference<Bitmap>> getUserCache() {
		if (mBitmapCache == null) {
			mBitmapCache = new HashMap<String, SoftReference<Bitmap>>();
		}
		return mBitmapCache;
	}

	public static Bitmap getBitmapFromCache(String filePath) {
		if (UtilString.isEmpty(filePath)) {
			return null;
		}
		HashMap<String, SoftReference<Bitmap>> iconCache = getUserCache();
		SoftReference<Bitmap> sfUser = iconCache.get(filePath);
		if (sfUser != null && sfUser.get() != null) {
			return sfUser.get();
		} else {
			sfUser = createAndAddToCache(filePath, true);
			getUserCache().put(filePath, sfUser);
			if (sfUser != null && sfUser.get() != null) {
				return sfUser.get();
			}
		}
		return null;
	}

	private static SoftReference<Bitmap> createAndAddToCache(String filePath, boolean isZoom) {
		if (isZoom) {
			SoftReference<Bitmap> bitmap;
			try {
				bitmap = new SoftReference<Bitmap>(BitmapFactory.decodeFile(filePath));
			} catch (Exception e) {
				bitmap = UtilBitmap.getIconCache().get(filePath);
			}
			if (bitmap != null && bitmap.get() != null) {
				return new SoftReference<Bitmap>(UtilBitmap.zoomImage(bitmap.get(), MAXW, MAXH));
			}
		}
		return null;
	}
}
