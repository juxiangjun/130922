package eme.xml;

import java.util.ArrayList;
import java.util.List;

public class Service {
	public String name;
	public String value;
	public List<Function> flist=new ArrayList<Function>();
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getValue() {
		return value;
	}
	public void setValue(String value) {
		this.value = value;
	}
	public List<Function> getFlist() {
		return flist;
	}
	public void setFlist(List<Function> flist) {
		this.flist = flist;
	}
	
	
}
