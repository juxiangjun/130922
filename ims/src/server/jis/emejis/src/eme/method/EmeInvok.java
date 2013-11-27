package eme.method;

import java.lang.reflect.Method;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

import net.sf.json.JSONException;
import eme.JisContext;
import eme.xml.EmeRoot;
import eme.xml.Function;
import eme.xml.Service;

public class EmeInvok {
	static Map<String, EmeClass> map = null;

	
	// ClassNotFoundException, InstantiationException, IllegalAccessException, NoSuchMethodException, SecurityException, IllegalArgumentException, InvocationTargetException
	public static void init(EmeRoot root) 		 throws ClassNotFoundException, InstantiationException, IllegalAccessException, NoSuchMethodException{
		if(map!=null)
			return;
		
		map = new HashMap<String, EmeClass>();
		
		for(Service servic : root.getSlist()){
			EmeClass emeclass=new EmeClass();
		    String name=servic.getName();
		   
		    Class<?> clazz = Class.forName(servic.getValue());
		    Object ob=clazz.newInstance();			
			emeclass.setOb(ob);
			
			 Map<String, EmeMethod>  mmap=  new HashMap<String ,EmeMethod>();
			 
			 for(Function function : servic.getFlist()){
				 EmeMethod ememethod=new EmeMethod();
				
				 Method method = clazz.getMethod(function.getValue(), JisContext.class);
				 ememethod.setReadonly(function.getReadonly());
				 ememethod.setM(method);
				 ememethod.setClassob(ob);
				 
				 mmap.put(function.getName(), ememethod);
				 
				 
				 
			 }
			
			 emeclass.setMap(mmap);
			 
			map.put(name, emeclass);
			
			
		}
		

	}

	public static Object   invok(String cla, String meth, JisContext c) throws JSONException, SQLException, Exception {
		
		 
		EmeClass clazz = map.get(cla);
		EmeMethod method = clazz.getMap().get(meth);
		return method.invoke(c);

	}

	
	public static Object   emeinvok(String cla, String meth, JisContext c) throws JSONException, SQLException, Exception {
		
	 
		EmeClass clazz = map.get(cla);
		 
		EmeMethod method = clazz.getMap().get(meth);
		return method.emeinvoke(c);

	}

	
}
