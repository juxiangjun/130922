package com.dyt.lpclub.util;

import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileFilter;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.FilenameFilter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.RandomAccessFile;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.ThumbnailUtils;
import android.util.Log;

import com.dyt.lpclub.R;

/**
 * 描述:文件相关的工具类
 * 
 * @author linqiang(866116)
 * @Since 2012-5-16
 */
public class UtilFile {

	private static final String TAG="FileUtil";
	/**
	 * 根据字节内容生成新文件
	 * 
	 * @param newFile
	 * @param musicDatas
	 * @return
	 */
	public static boolean generateFile(File file, List<byte[]> datas) {
		BufferedOutputStream bos = null;
		try {
			bos = new BufferedOutputStream(new FileOutputStream(file));
			for (byte[] data : datas) {
				bos.write(data);
			}
			return true;
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (bos != null) {
				try {
					bos.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
		return false;
	}

	/**
	 * 往现有文件中追加数据
	 * 
	 * @param file
	 * @param datas
	 * @return
	 */
	public static boolean appendData(File file, byte[]... datas) {
		RandomAccessFile rfile = null;
		try {
			rfile = new RandomAccessFile(file, "rw");
			rfile.seek(file.length());
			for (byte[] data : datas) {
				rfile.write(data);
			}
			return true;
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (rfile != null) {
				try {
					rfile.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
		return false;
	}

	/**
	 * 创建文件夹
	 */
	public static void createDir(String dir) {
		File f = new File(dir);
		if (!f.exists()) {
			f.mkdirs();
		}

	}

	/**
	 * 往创建文件，并往文件中写内容
	 */
	public static void writeFile(String path, String content, boolean append) {
		try {
			File f = new File(path);
			if (!f.getParentFile().exists()) {
				f.getParentFile().mkdirs();
			}
			if (!f.exists()) {
				f.createNewFile();
				f = new File(path); // 重新实例化
			}
			FileWriter fw = new FileWriter(f, append);
			if ((content != null) && !"".equals(content)) {
				fw.write(content);
				fw.flush();
			}
			fw.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * 删除某个文件
	 * 
	 * @param path
	 *            文件路径
	 */
	public static void delFile(String path) {
		try {
			File f = new File(path);
			if (f.exists()) {
				f.delete();
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * 删除文件夹
	 * 
	 * @param folderPath
	 */
	public static void delFolder(String folderPath) {
		try {
			delAllFile(folderPath); // 删除完里面所有内容
			String filePath = folderPath;
			filePath = filePath.toString();
			File f = new File(filePath);
			f.delete(); // 删除空文件夹
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * 
	* @Author 								C.xt
	* @Title: 								delAllFile
	* @Description:							
	* @param path							删除path 下全部文件
	* @return:								boolean	删除成功			 
	* @throws							
	* @date 								2013-5-9 下午2:30:48
	 */
	public static boolean delAllFile(String path) {
		return delAllFile(path, null);
	}
	
	
	/**
	 * 
	* @author								C.xt
	* @Title: 								delAllFile
	* @Description:							删除文件夹内所有文件 @param dontDelFile 除外
	* @param: 								path 文件夹目录
	* @param: 								filenameFilter 过滤器 支持null
	* @return: 								boolean 删除成功
	* @throws
	* @date 							2013-4-27 下午5:30:27
	 */
	public static boolean delAllFile(String path, FilenameFilter filenameFilter) {
		boolean flag = false;
		File file = new File(path);
		if (!file.exists()) {
			return flag;
		}
		if (!file.isDirectory()) {
			return flag;
		}
		File[] tempList = file.listFiles(filenameFilter);
		int length = tempList.length;
		for (int i = 0; i < length; i++) {

			if (tempList[i].isFile()) {
				tempList[i].delete();
			}
			if (tempList[i].isDirectory()) {
				/**
				 * 删除内部文件
				 */
				delAllFile(tempList[i].getAbsolutePath(), filenameFilter);
				/**
				 * 删除空文件夹
				 */
				String[] ifEmptyDir = tempList[i].list();
				if (null == ifEmptyDir || ifEmptyDir.length <= 0) {
					tempList[i].delete();
				}
				flag = true;
			}
		}
		return flag;
	}


	/**
	 * 文件复制类
	 * 
	 * @param srcFile
	 *            源文件
	 * @param destFile
	 *            目录文件
	 * @return 是否复制成功
	 * @modify by 						C.xt
	 */
	public static boolean copy(String srcFile, String destFile) {
		FileInputStream in = null;
		FileOutputStream out = null;
		try {
			in = new FileInputStream(srcFile);
			out = new FileOutputStream(destFile);
			byte[] bytes = new byte[1024];
			int c;
			while ((c = in.read(bytes)) != -1) {
				out.write(bytes, 0, c);
			}
			out.flush();
			return true;
		} catch (Exception e) {
			System.out.println("Error!" + e);
			return false;
		}finally{
			if(null != in){
				try {
					in.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
			if(null != out){
				try {
					out.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
	}

	/**
	 * 复制整个文件夹内容
	 * 
	 * @param oldPath
	 *            String 原文件路径 如：c:/fqf
	 * @param newPath
	 *            String 复制后路径 如：f:/fqf/ff
	 * @return boolean
	 */
	public static void copyFolder(String oldPath, String newPath) {
		(new File(newPath)).mkdirs(); // 如果文件夹不存在 则建立新文件夹
		File a = new File(oldPath);
		String[] file = a.list();
		if (null == file)
			return;
		File temp = null;
		for (int i = 0; i < file.length; i++) {
			try {
				if (oldPath.endsWith(File.separator)) {
					temp = new File(oldPath + file[i]);
				} else {
					temp = new File(oldPath + File.separator + file[i]);
				}

				if (temp.isFile()) {
					FileInputStream input = new FileInputStream(temp);
					FileOutputStream output = new FileOutputStream(newPath + "/" + (temp.getName()).toString());
					byte[] b = new byte[1024 * 5];
					int len;
					while ((len = input.read(b)) != -1) {
						output.write(b, 0, len);
					}
					output.flush();
					output.close();
					input.close();
				}
				if (temp.isDirectory()) {// 如果是子文件夹
					copyFolder(oldPath + "/" + file[i], newPath + "/" + file[i]);
				}
			} catch (Exception e) {
				e.printStackTrace();
				continue;
			}
		}
	}

	/**
	 * 移动文件到指定目录
	 * 
	 * @param oldPath
	 *            String 如：c:/fqf.txt
	 * @param newPath
	 *            String 如：d:/fqf.txt
	 */
	public static void moveFile(String oldPath, String newPath) {
		copy(oldPath, newPath);
		delFile(oldPath);

	}

	/**
	 * 重命名文件或文件夹
	 * 
	 * @param resFilePath
	 *            源文件路径
	 * @param newFileName
	 *            重命名
	 * @return 操作成功标识
	 */
	public static boolean renameFile(String resFilePath, String newFilePath) {
		File resFile = new File(resFilePath);
		File newFile = new File(newFilePath);
		return resFile.renameTo(newFile);
	}

	/**
	 * 移动文件夹到指定目录
	 * 
	 * @param oldPath
	 *            String 如：c:/fqf
	 * @param newPath
	 *            String 如：d:/fqf
	 */
	public static void moveFolder(String oldPath, String newPath) {
		copyFolder(oldPath, newPath);
		delFolder(oldPath);
	}

	/**
	 * <br>
	 * Description: 将输入流保存为文件 <br>
	 * Author:caizp <br>
	 * Date:2011-7-19下午02:37:25
	 * 
	 * @param in
	 * @param fileName
	 *            文件名称
	 */
	public static void saveStream2File(InputStream in, String fileName) {
		int size;
		byte[] buffer = new byte[1000];
		BufferedOutputStream bufferedOutputStream = null;
		try {
			bufferedOutputStream = new BufferedOutputStream(new FileOutputStream(new File(fileName)));
			while ((size = in.read(buffer)) > -1) {
				bufferedOutputStream.write(buffer, 0, size);
			}
			bufferedOutputStream.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * 图片文件过滤器
	 */
	public static FileFilter imagefileFilter = new FileFilter() {
		public boolean accept(File pathname) {
			String tmp = pathname.getName().toLowerCase();
			if (tmp.endsWith(".png") || tmp.endsWith(".jpg") || tmp.endsWith(".bmp") || tmp.endsWith(".gif") || tmp.endsWith(".jpeg")) {
				return true;
			}
			return false;
		}
	};

	/**
	 * 铃声文件过滤器
	 */
	public static FileFilter mp3fileFilter = new FileFilter() {
		public boolean accept(File pathname) {
			String tmp = pathname.getName().toLowerCase();
			if (tmp.endsWith(".mp3")) {
				return true;
			}
			return false;
		}
	};

	public static File[] getFilesFromDir(String dirPath, FileFilter fileFilter) {
		File dir = new File(dirPath);
		if (dir.isDirectory()) {
			if (fileFilter != null)
				return dir.listFiles(fileFilter);
			else
				return dir.listFiles();
		}
		return null;
	}

	/**
	 * <br>
	 * Description: 获取已存在的文件名列表 <br>
	 * Author:caizp <br>
	 * Date:2011-8-10上午11:22:07
	 * 
	 * @param dir
	 * @param fileFilter
	 * @param hasSuffix
	 * @return
	 */
	public static List<String> getExistsFileNames(String dir, FileFilter fileFilter, boolean hasSuffix) {
		String path = dir;
		File file = new File(path);
		File[] files = file.listFiles(fileFilter);
		List<String> fileNameList = new ArrayList<String>();
		if (null != files) {
			for (File tmpFile : files) {
				String tmppath = tmpFile.getAbsolutePath();
				String fileName = getFileName(tmppath, hasSuffix);
				fileNameList.add(fileName);
			}
		}
		return fileNameList;
	}

	/**
	 * 描述: 获取已存在的文件名列表 (包括子目录)
	 * 
	 * @author linqiang(866116)
	 * @Since 2012-6-6
	 * @param dir
	 * @param fileFilter
	 * @param hasSuffix
	 * @return
	 */
	public static List<String> getAllExistsFileNames(String dir, boolean hasSuffix) {
		String path = dir;
		createDir(dir);
		File file = new File(path);
		File[] files = file.listFiles();
		List<String> fileNameList = new ArrayList<String>();
		if (null != files) {
			for (File tmpFile : files) {
				if (tmpFile.isDirectory()) {
					fileNameList.addAll(getAllExistsFileNames(tmpFile.getPath(), hasSuffix));
				} else {
					String tmp = tmpFile.getName().toLowerCase();
					if (tmp.endsWith(".png") || tmp.endsWith(".jpg") || tmp.endsWith(".bmp") || tmp.endsWith(".gif") || tmp.endsWith(".jpeg")) {
						fileNameList.add(tmpFile.getAbsolutePath());
					}
				}
			}
		}
		return fileNameList;
	}

	/**
	 * 从路径中获取 文件名
	 * 
	 * @param path
	 * @param hasSuffix
	 *            是否包括后缀
	 * @return
	 */
	public static String getFileName(String path, boolean hasSuffix) {
		if (null == path || -1 == path.lastIndexOf("/") || -1 == path.lastIndexOf("."))
			return null;
		if (!hasSuffix)
			return path.substring(path.lastIndexOf("/") + 1, path.lastIndexOf("."));
		else
			return path.substring(path.lastIndexOf("/") + 1);
	}

	/**
	 * 获取目录
	 * 
	 * @param path
	 * @return
	 */
	public static String getPath(String path) {
		File file = new File(path);

		try {
			if (!file.exists() || !file.isDirectory())
				file.mkdirs();
			return file.getAbsolutePath();

		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}

	/**
	 * 指定目录下是否存在指定名称的文件
	 * 
	 * @param path
	 *            目录
	 * @param fileName
	 *            文件名称
	 * @return
	 */
	public static boolean isFileExits(String dir, String fileName) {
		fileName = fileName == null ? "" : fileName;
		dir = dir == null ? "" : dir;
		int index = dir.lastIndexOf("/");
		String filePath;
		if (index == dir.length() - 1)
			filePath = dir + fileName;
		else
			filePath = dir + "/" + fileName;
		File file = new File(filePath);
		return file.exists();
	}

	/**
	 * 指定路么下是否存在文件
	 * 
	 * @param filePath
	 *            文件路径
	 * @return
	 */
	public static boolean isFileExits(String filePath) {
		try {
			File file = new File(filePath);
			if (file.exists())
				return true;
		} catch (Exception e) {

		}
		return false;
	}

	/**
	 * 保存图片
	 * 
	 * @param path
	 * @param fileName
	 * @param bmp
	 * @return
	 */
	public static boolean saveImageFile(String dirPath, String fileName, Bitmap bmp) {
		try {
			File dir = new File(dirPath);

			// 目录不存时创建目录
			if (!dir.exists()) {
				boolean flag = dir.mkdirs();
				if (flag == false)
					return false;
			}

			// 未指定文件名时取当前毫秒作为文件名
			if (fileName == null || fileName.trim().length() == 0)
				fileName = System.currentTimeMillis() + ".jpg";
			File picPath = new File(dirPath, fileName);
			FileOutputStream fos = new FileOutputStream(picPath);
			bmp.compress(Bitmap.CompressFormat.JPEG, 100, fos);
			fos.flush();
			fos.close();
			return true;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	/**
	 * 保存图片,带保存格式：jpg\png
	 * 
	 * @param path
	 * @param fileName
	 * @param bmp
	 * @param format
	 *            保存的格式
	 * @return
	 */
	public static boolean saveImageFile(String dirPath, String fileName, Bitmap bmp, Bitmap.CompressFormat format) {
		try {
			File dir = new File(dirPath);

			// 目录不存时创建目录
			if (!dir.exists()) {
				boolean flag = dir.mkdirs();
				if (flag == false)
					return false;
			}

			format = format == null ? Bitmap.CompressFormat.JPEG : format;
			// 未指定文件名时取当前毫秒作为文件名
			if (fileName == null || fileName.trim().length() == 0) {
				fileName = System.currentTimeMillis() + "";
				if (format.equals(Bitmap.CompressFormat.PNG))
					fileName += ".png";
				else
					fileName += ".jpg";
			}
			File picPath = new File(dirPath, fileName);
			FileOutputStream fos = new FileOutputStream(picPath);
			bmp.compress(format, 100, fos);
			fos.flush();
			fos.close();
			return true;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	/**
	 * 获取文件夹总大小 B单位
	 * 
	 * @author youy
	 * @since 2012-11-13
	 * @param path
	 * @return
	 */
	public static long getFileAllSize(String path) {
		File file = new File(path);
		if (file.exists()) {
			if (file.isDirectory()) {
				File[] children = file.listFiles();
				long size = 0;
				for (File f : children)
					size += getFileAllSize(f.getPath());
				return size;
			} else {
				long size = file.length();
				return size;
			}
		} else {
			return 0;
		}

	}

	/**
	 * 读取文件内容
	 * 
	 * @param path
	 * @return
	 */
	public static String readFileContent(String path) {
		StringBuffer sb = new StringBuffer();
		if (!isFileExits(path)) {
			return sb.toString();
		}
		InputStream ins = null;
		try {
			ins = new FileInputStream(new File(path));
			BufferedReader reader = new BufferedReader(new InputStreamReader(ins));
			String line = null;
			while ((line = reader.readLine()) != null) {
				sb.append(line);
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (ins != null) {
				try {
					ins.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
		return sb.toString();
	}

	// add by linqiang 从FileManagerUtil.java移动过来
	/**
	 * 获取缩略图
	 * 
	 * @author Jimmy <br>
	 *         create at 2012-8-8 下午03:37:12 <br>
	 *         modify at 2012-8-8 下午03:37:12
	 * @param path
	 * @param width
	 * @param height
	 * @param defaultId
	 * @return
	 */
//	public static Bitmap getBitmapThumbnail(Context cxt, String path, int defaultId) {
//		int photoWidth = cxt.getResources().getDimensionPixelSize(R.dimen.myfile_photo_width);
//		int photoHeight = cxt.getResources().getDimensionPixelSize(R.dimen.myfile_photo_height);
//		Bitmap bitmap = null;
//		try {
//			bitmap = getBitmapFromCache(cxt, path, photoWidth, photoHeight, defaultId);
//		} catch (Exception e) {
//			e.printStackTrace();
//		}
//		return bitmap;
//	}

	public static String getMemorySizeString(long size) {
		float result = size;
		if (result < 1024) {
			BigDecimal temp = new BigDecimal(result);
			temp = temp.setScale(2, BigDecimal.ROUND_HALF_UP);
			return temp + "Bytes";
		} else {
			result = result / 1024;
			if (result < 1024) {
				BigDecimal temp = new BigDecimal(result);
				temp = temp.setScale(2, BigDecimal.ROUND_HALF_UP);
				return temp + "KB";
			} else {
				result = result / 1024;
				if (result < 1024) {
					BigDecimal temp = new BigDecimal(result);
					temp = temp.setScale(2, BigDecimal.ROUND_HALF_UP);
					return temp + "MB";
				} else {
					result = result / 1024;
					if (result < 1024) {
						BigDecimal temp = new BigDecimal(result);
						temp = temp.setScale(2, BigDecimal.ROUND_HALF_UP);
						return temp + "GB";
					} else {
						result = result / 1024;
						BigDecimal temp = new BigDecimal(result);
						temp = temp.setScale(2, BigDecimal.ROUND_HALF_UP);
						return temp + "TB";
					}
				}
			}
		}
	}

	public static String getMemoryPercentString(float percent) {
		BigDecimal result = new BigDecimal(percent * 100.0f);
		return result.setScale(2, BigDecimal.ROUND_HALF_UP) + "%";
	}

	/**
	 * 生成缩略图
	 * 
	 * @param path
	 * @return
	 */
	public static Bitmap getBitmapFromCache(Context context, String path, int width, int height, int defaultId) {
		Bitmap bitmap = null;
		Bitmap bp = null;
		try {
			InputStream is = new FileInputStream(path);
			try {
				BitmapFactory.Options options = new BitmapFactory.Options();
				options.inJustDecodeBounds = true;
				// 获取这个图片的宽和高，注意此处的bitmap为null
				bp = BitmapFactory.decodeFile(path, options);
				options.inJustDecodeBounds = false; // 设为 false
				// 计算缩放比
				int h = options.outHeight;
				int w = options.outWidth;
				int beWidth = w / width;
				int beHeight = h / height;
				int be = 1;
				if (beWidth < beHeight) {
					be = beWidth;
				} else {
					be = beHeight;
				}
				if (be <= 0) {
					be = 1;
				}
				options.inSampleSize = be;
				// 重新读入图片，读取缩放后的bitmap，注意这次要把options.inJustDecodeBounds 设为 false
				bp = BitmapFactory.decodeFile(path, options);
				bitmap = ThumbnailUtils.extractThumbnail(bp, width, height, ThumbnailUtils.OPTIONS_RECYCLE_INPUT);
			} finally {
				try {
					is.close();
					is = null;
					if (bp != null && !bp.isRecycled())
						bp.recycle();
				} catch (Exception ex) {
					ex.printStackTrace();
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		} catch (OutOfMemoryError e1) {
			return null;
		}
		if (bitmap == null || bitmap.isRecycled()) {
			if (defaultId == 0) {
				defaultId = R.drawable.ic_launcher;
			}
			bitmap = BitmapFactory.decodeResource(context.getResources(), defaultId);
		}
		return bitmap;
	}
	
	/**
	 * 从assets目录复制文件到指定路径
	 * @param context
	 * @param srcFileName 复制的文件名
	 * @param targetDir 目标目录
	 * @param targetFileName 目标文件名
	 * @return
	 */
	public static boolean copyAssetsFile(Context context,String srcFileName,String targetDir,String targetFileName)
	{
		AssetManager asm=null;
		FileOutputStream fos=null;
		DataInputStream dis=null;
		try {
			asm=context.getAssets();
			dis=new DataInputStream(asm.open(srcFileName));
			createDir(targetDir);
			File targetFile=new File(targetDir, targetFileName);
			if(targetFile.exists())
			{
				targetFile.delete();
			}
			
			fos=new FileOutputStream(targetFile);
			byte[] buffer=new byte[1024];
			int len=0;
			while((len=dis.read(buffer))!=-1)
			{
				fos.write(buffer, 0, len);
			}
			fos.flush();
			return true;
		} catch (Exception e) {
			Log.w(TAG, "copy assets file failed:"+e.toString());
		} finally{
			try {
				if(fos!=null)
					fos.close();
				if(dis!=null)
					dis.close();
			} catch (Exception e2) {
			}
		}
		
		return false;
	}//end copyAssetsFile

}
