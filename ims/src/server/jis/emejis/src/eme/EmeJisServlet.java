package eme;

import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;

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

import org.exolab.castor.mapping.Mapping;
import org.exolab.castor.xml.Unmarshaller;
import org.xml.sax.InputSource;

import eme.method.EmeInvok;
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
 
public class EmeJisServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    
    public EmeJisServlet() {
        super();
        
    }

	 
	public void init(ServletConfig config) throws ServletException  {		
		//String mappath=config.getInitParameter("mappath");
		//String definepath=config.getInitParameter("definepath");
		Mapping mapping = new Mapping();
		System.out.println( "----"+System.getProperty("user.dir"));
		String realpath=config.getServletContext().getRealPath("");
		
		realpath=realpath+"/WEB-INF/classes/";
		String mappath=realpath+config.getInitParameter("mappath");
		String definepath=realpath+config.getInitParameter("definepath");
		
		System.out.println( "----"+mappath);
		try{
		mapping.loadMapping(definepath);	  
        Unmarshaller unmar = new Unmarshaller(mapping);
        EmeRoot eme = (EmeRoot) unmar.unmarshal(new InputSource(new FileReader(mappath)));
       // EmeXmlUtil.er=eme;
        EmeInvok.init(eme);
        EmeContext.initMybatis();
        
		}catch (Exception e){			
			  e.printStackTrace();
			  throw new ServletException();
		}
		 
	}

 
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("utf-8");
		String key = request.getParameter("key"); 		
		response.setContentType("text/javascript;charset=utf-8");
        PrintWriter out = response.getWriter();  
         
        System.out.println("--->>>"+key);
        
        
        
        out.println(EmeUtil.getResponseJson(key).toString());
	
	}
 
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	 
		doGet(request,response);
	}

}
