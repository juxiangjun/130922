/**
 * Create Date:2011-7-14下午02:03:22
 */
package com.dyt.lpclub.util;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.File;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.List;

import android.app.Activity;
import android.app.ActivityManager;
import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.speech.RecognizerIntent;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;
import android.view.inputmethod.InputMethodManager;
import android.widget.Toast;

import com.dyt.lpclub.R;

/**
 * 系统工具类
 * 
 */
public class UtilSystem {
	
	private static final String TAG = "SystemUtil";

	/**
	 * 在浏览器中打开指定地址
	 * 
	 * @param url
	 *            网页url
	 */
	public static void openPage(Context ctx, String url) {
		try {
			Uri uri = Uri.parse(url);
			Intent intent = new Intent(Intent.ACTION_VIEW, uri);
			intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
			ctx.startActivity(intent);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}


	/**
	 * 
	 * 安全打开一个APP <br>
	 * Date:2012-7-25下午02:15:12
	 */
	public static void startActivitySafely(Context ctx, Intent intent) {
		if (intent == null) {
			makeShortToast(ctx, R.string.data_error);
			return;
		}

		intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		try {
			ctx.startActivity(intent);
		} catch (ActivityNotFoundException e) {
			makeShortToast(ctx, R.string.activity_not_found);
			Log.e(TAG, "Unable to launch. intent=" + intent, e);
		} catch (SecurityException e) {
			makeShortToast(ctx, R.string.activity_not_found);
			Log.e(TAG, e.getMessage());
		}
	}

	/**
	 * 
	 * 安全打开一个APP <br>
	 * Date:2012-7-25下午02:15:12
	 */
	public static void startActivity(Context ctx, Intent intent) {
		if (intent == null) {
			makeShortToast(ctx, R.string.data_error);
			return;
		}

		try {
			ctx.startActivity(intent);
		} catch (ActivityNotFoundException e) {
			makeShortToast(ctx, R.string.activity_not_found);
			Log.e(TAG, "Unable to launch. intent=" + intent, e);
		} catch (SecurityException e) {
			makeShortToast(ctx, R.string.activity_not_found);
			Log.e(TAG, e.getMessage());
		} catch (Exception e) {
			makeShortToast(ctx, R.string.activity_not_found);
			e.printStackTrace();
		}
	}

	/**
	 * 
	 * 接收Activity返回结果 <br>
k	 * Date:2012-7-25下午02:15:12
	 */
	public static void startActivityForResultSafely(Activity ctx, Intent intent, int requestCode) {
		try {
			ctx.startActivityForResult(intent, requestCode);
		} catch (ActivityNotFoundException e) {
			Toast.makeText(ctx, R.string.activity_not_found, Toast.LENGTH_SHORT).show();
		} catch (SecurityException e) {
			Toast.makeText(ctx, R.string.activity_not_found, Toast.LENGTH_SHORT).show();
			Log.e(TAG, e.getMessage());
		} catch (Exception e) {
			Toast.makeText(ctx, R.string.activity_not_found, Toast.LENGTH_SHORT).show();
			e.printStackTrace();
		}
	}

	/**
	 * 显示软键盘
	 */
	public static void showKeyboard(View view) {
		if (null == view)
			return;
		InputMethodManager imm = (InputMethodManager) view.getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
		imm.showSoftInput(view, 0);
	}

	/**
	 * 隐藏软键盘
	 */
	public static void hideKeyboard(View view) {
		if (null == view)
			return;
		InputMethodManager imm = (InputMethodManager) view.getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
		imm.hideSoftInputFromWindow(view.getWindowToken(), 0);
	}

	/**
	 * 隐藏软键盘
	 */
	public static void createHideInputMethod(Activity ctx) {
		final InputMethodManager manager = (InputMethodManager) ctx.getSystemService(Activity.INPUT_METHOD_SERVICE);
		ctx.getWindow().getDecorView().setOnTouchListener(new OnTouchListener() {
			@Override
			public boolean onTouch(View v, MotionEvent event) {
				if (manager.isActive()) {
					manager.hideSoftInputFromWindow(v.getWindowToken(), 0);
				}
				return true;
			}
		});
	}

	// /**
	// * 更新应用程序使用次数 <br>
	// * Date:2012-6-30下午08:08:38
	// */
	// private static void maybeUpdateUsedTime(Context ctx, ComponentName
	// component) {
	// if (component == null)
	// return;
	// if (ctx.getPackageName().equals(component.getPackageName()))
	// return;
	//
	// AppDataFactory.updateUsedTime(ctx, component);
	// }

	public static void makeShortToast(Context ctx, int resId) {
		if (resId == 0)
			return;
		Toast.makeText(ctx, ctx.getText(resId), Toast.LENGTH_SHORT).show();
	}

	/**
	 * 根据名称得到Drawable <br>
	 * Date:2011-7-22下午05:46:57
	 */
	public static Drawable getDrawableByResourceName(Context ctx, String resName) {
		if (UtilString.isEmpty(resName))
			return null;

		Resources res = ctx.getResources();
		int resId = res.getIdentifier(resName, "drawable", ctx.getPackageName());
		if (resId == 0)
			return null;

		return res.getDrawable(resId);
	}

	/**
	 * 根据名称得到Bitmap <br>
	 * Date:2011-7-22下午05:46:57
	 */
	public static Bitmap getBitmapByResourceName(Context ctx, String resName) {
		if (UtilString.isEmpty(resName))
			return null;

		Resources res = ctx.getResources();
		int resId = res.getIdentifier(resName, "drawable", ctx.getPackageName());
		if (resId == 0)
			return null;

		return ((BitmapDrawable) res.getDrawable(resId)).getBitmap();
	}

	/**
	 * 是不是系统应用
	 * 
	 * @param ctx
	 * @param pkgName
	 * @return
	 */
	public static boolean isSystemApplication(ApplicationInfo appInfo) {
		if (appInfo == null)
			return false;
		// 是否是系统应用
		if ((appInfo.flags & ApplicationInfo.FLAG_UPDATED_SYSTEM_APP) != 0)
			return true;
		else if ((appInfo.flags & ApplicationInfo.FLAG_SYSTEM) != 0)
			return true;

		return false;
	}

	/**
	 * 
	 * @Title: openSuperShell
	 * @Description: 判断是否super root成功
	 * @param @param context
	 * @param @return
	 * @return boolean
	 * @throws
	 */
//	public static boolean openSuperShell(Context context) {
//		if (!hasRootPermission())
//			return false;
//		boolean isFileExits = UtilFile.isFileExits("/system/bin/" + CommonGlobal.SUPER_SHELL_FILE_NAME);
//		if (isFileExits)
//			return true;
//
//		Process process = null;
//		DataOutputStream dos = null;
//
//		File srcFile = new File(CommonGlobal.BASE_DIR, CommonGlobal.SUPER_SHELL_FILE_NAME);
//		String targetDir = "/system/bin/";
//		File targetFile = new File(targetDir, CommonGlobal.SUPER_SHELL_FILE_NAME);
//
//		try {
//
//			// 复制文件到Sdcard上
//			boolean copyAssetsFileToSdcard = UtilFile.copyAssetsFile(context, CommonGlobal.SUPER_SHELL_FILE_NAME, CommonGlobal.BASE_DIR, CommonGlobal.SUPER_SHELL_FILE_NAME);
//			if (!copyAssetsFileToSdcard)
//				return false;
//
//			// 开启root权限进行文件复制
//			process = Runtime.getRuntime().exec("su");
//			dos = new DataOutputStream(process.getOutputStream());
//
//			dos.writeBytes("export LD_LIBRARY_PATH=/vendor/lib:/system/lib \n");
//			dos.writeBytes("mount -oremount,rw /dev/block/mtdblock3 /system\n");
//
//			// 复制文件到/system/bin/目录下
//			dos.writeBytes("cat " + srcFile.getAbsolutePath() + " > " + targetFile.getAbsolutePath() + " \n");
//			// 修改文件的权限，使其具备超级权限
//			dos.writeBytes("chmod 4777 " + targetFile.getAbsolutePath() + " \n");
//
//			dos.writeBytes("exit\n");
//			dos.flush();
//			int resCode = process.waitFor();
//			if (resCode == 0) {
//				return true;
//			} else {
//
//				InputStream is = process.getErrorStream();
//				BufferedReader br = new BufferedReader(new InputStreamReader(is));
//				String line = null;
//				StringBuffer sb = new StringBuffer();
//				while ((line = br.readLine()) != null) {
//					sb.append(line);
//				}
//
//				if (is != null)
//					is.close();
//				Log.d(TAG, "Copy root file failed,rescode:" + resCode + ",msg:" + sb.toString());
//				return false;
//			}
//
//		} catch (Exception e) {
//			Log.w(TAG, "open super shell failed!", e);
//		} finally {
//			try {
//				if (dos != null)
//					dos.close();
//			} catch (Exception e2) {
//			}
//			if (process != null)
//				process.destroy();
//
//			// 删除缓存文件
//			UtilFile.delFile(srcFile.getAbsolutePath());
//		}
//
//		return false;
//
//	}// end openSilentInstall

	/**
	 * 是否拥有root权限
	 * 
	 * @return
	 */
	public static boolean hasRootPermission() {
		boolean rooted = true;
		try {
			File su = new File("/system/bin/su");
			if (su.exists() == false) {
				su = new File("/system/xbin/su");
				if (su.exists() == false) {
					rooted = false;
				}
			}
		} catch (Exception e) {
			rooted = false;
		}
		return rooted;
	}
	
	/**
	 * 判断机型(或固件版本)是否支持google语音识别功能
	 * 
	 * @return 支持返回true, 否则返回false
	 */
	public static boolean isVoiceRecognitionEnable(Context context) {
		PackageManager pm = context.getPackageManager();
		List<ResolveInfo> activities = pm.queryIntentActivities(new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH), 0);
		if (activities.size() != 0)
			return true;
		else
			return false;
	}

	/**
	* @author 									C.xt
	* @Title: 									getCurProcessName
	* @Description:								获取当前进程名
	* @param 									context
	* @return 
	* @return 									String 
	* @throws
	* @date 									2013-5-3 下午4:41:35
	 */

	public static String getCurProcessName(Context context) {
		try {
			int pid = android.os.Process.myPid();
			ActivityManager mActivityManager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
			for (ActivityManager.RunningAppProcessInfo appProcess : mActivityManager.getRunningAppProcesses()) {
				if (appProcess.pid == pid) {
					return appProcess.processName;
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
		return null;
	}
}
