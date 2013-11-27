package eme.util;

import java.util.List;

public class Pair {
	String key=null;
	String value=null;
	
	public Pair(String key, String value) {
		super();
		this.key = key;
		this.value = value;
	}
	public String getKey() {
		return key;
	}
	public void setKey(String key) {
		this.key = key;
	}
	public String getValue() {
		return value;
	}
	public void setValue(String value) {
		this.value = value;
	} 
	 
	public static String getV(List<Pair> list,String key){		
		String v=null;		
		for(Pair p:list){			
			if (key.equals(p.getKey()))
					return p.getValue();
		}
		return v;
		
	}
	

}
