package eme;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLDecoder;
import java.sql.Connection;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebInitParam;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.exolab.castor.mapping.Mapping;
import org.exolab.castor.xml.Unmarshaller;
import org.xml.sax.InputSource;

import eme.util.ConfigUtil;
import eme.util.ToolUtil;
import eme.xml.EmeRoot;
import net.sf.json.JSONException;
import net.sf.json.JSONObject;

/**
 * Servlet implementation class EmeImsServlet
 */

/*
 * 测试
 * http://192.168.7.7:8080/emejis/eme/?key={"root":{"header":{"id":"001","ack":"repuest","sender":"192.0.0.1","datetime":"354387493","cid":"1","version":"1.0","device":"iphon"},"body":{"service":"S_TRADE","function":"APPEME_CATEGORY","param":{"userid":"1","code":"1"}}}}
 
 */
 
public class EmeJisUploadServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    
    public EmeJisUploadServlet() {
        super();
        
    } 
 
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("utf-8");
		 	
		response.setContentType("text/javascript;charset=utf-8");
        PrintWriter out = response.getWriter();  
    	String key=null;
		String path;
		List<String> pathlist=new ArrayList<String>();
		
		
		

		DiskFileItemFactory factory = new DiskFileItemFactory();
		factory.setSizeThreshold(8192);
		String sysPath = request.getSession().getServletContext().getRealPath("/");
		String imgpath=sysPath+ConfigUtil.getImgpath();
		
		
		File tmpfile = new File(sysPath+ConfigUtil.getTmppath());	
		 
		factory.setRepository(tmpfile);
		
		factory.setSizeThreshold(8*1024);  // 设置缓冲区大小，这里是8kb	
	
		try {
			 
			ServletFileUpload upload = new ServletFileUpload(factory);	
		      //设置最大上传大小 10M  
	            upload.setSizeMax(1024*1024*10); 
	            
			List<FileItem> items; 
			items = upload.parseRequest(request);
			  
			for(FileItem fitms:items){				
				if(fitms.isFormField()){					
					if(fitms.getFieldName().equals("key")){						
						//key=fitms.getString(); 
						key=fitms.getString("utf-8");
					 
						
					}
				}				
			}
			if (key==null)
				throw new ServletException("key field don't exist!");
			
			
			String cid=ToolUtil.getCid(key);
			String service=ToolUtil.getServic(key);
			
		 
		 
			File ciddir = new File(imgpath+"/"+cid);
 		if (!ciddir.isDirectory()) {
 				ciddir.mkdirs();
 			}
 		File servicdir = new  File(imgpath+"/"+cid+"/"+service);
 		if (!servicdir.isDirectory()) {
 			servicdir.mkdirs();
			}
 		 
			
			for(FileItem item:items){	
				
				if (!item.isFormField()) { //判断是否为表单控件（非File控件） 
					 
					long sizeInBytes = item.getSize();    
					path=ToolUtil.getDateTime2()+item.getName();
					
					File savedFile = new File(servicdir, path);
					item.write(savedFile); 
					  pathlist.add(ConfigUtil.getImgpath()+"/"+cid+"/"+service+"/"+path); 
				} 
			}
			
			 
			 out.println(EmeUtil.getResponseJson(key,pathlist).toString());
		
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		 
		
	}
 
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	 
		doGet(request,response);
	}

}
