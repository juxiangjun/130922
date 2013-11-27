package eme;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
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
 
public class EmeJisUpload2Servlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    
    public EmeJisUpload2Servlet() {
        super();
        
    } 
 
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("utf-8");
		String key = request.getParameter("key"); 		
		response.setContentType("text/javascript;charset=utf-8");
        PrintWriter out = response.getWriter();  
        System.out.println("-----=="+request.toString());

		DiskFileItemFactory factory = new DiskFileItemFactory();
		factory.setSizeThreshold(8192);
		String tempPath = request.getSession().getServletContext()
				.getRealPath("/")
				+ "/upload";
		File file = new File(tempPath);
		if (!file.isDirectory()) {
			file.mkdirs();
		}
		factory.setRepository(file);
		ServletFileUpload upload = new ServletFileUpload(factory);

		List<FileItem> items;
		System.out.println("-->" + tempPath);

		try {
			items = upload.parseRequest(request);

			Iterator<FileItem> itr = items.iterator();
			while (itr.hasNext()) {// 依次处理每个 form field
				FileItem item = (FileItem) itr.next();
				
				if (!item.isFormField()) { /*
											 * 判断是否为表单控件（非File控件），如果不是表单控件，则上传此文件
											 */
					System.out.println(item.getFieldName() + "----=="+item.getName()+"=-->"+ item.getString() );
					File savedFile = new File(tempPath, item.getName());
					item.write(savedFile);
				} 
				
				else {/* 如果是表单控件，则保存其值 */
					System.out.println("------["+item.getFieldName() + "]--===="+item.getName()+"======>"
							+ item.getString());
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	
	}
 
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	 
		doGet(request,response);
	}

}
