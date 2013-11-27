package eme.modual.person;

import java.util.ArrayList;
import java.util.List;

public class Area {
	private int id;
	private String name;
	private List<Area2> areaitems2=new ArrayList<Area2>();
	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public List<Area2> getAreaitems2() {
		return areaitems2;
	}
	public void setAreaitems2(List<Area2> areaitems2) {
		this.areaitems2 = areaitems2;
	}
	
	
	

}
