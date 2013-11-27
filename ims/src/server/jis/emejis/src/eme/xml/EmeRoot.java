package eme.xml;

import java.util.ArrayList;
import java.util.List;

public class EmeRoot {
	String version;
	List<Service> slist=new ArrayList<Service>();
	public String getVersion() {
		return version;
	}
	public void setVersion(String version) {
		this.version = version;
	}
	public List<Service> getSlist() {
		return slist;
	}
	public void setSlist(List<Service> slist) {
		this.slist = slist;
	}
	
	

}
