package com.dyt.lpclub.util;

import java.util.Comparator;

import com.dyt.lpclub.activity.domain.Group;

public class PinyinComparator implements Comparator<Group> {

	@Override
	public int compare(Group o1, Group o2) {
		return o1.spell.compareTo(o2.spell);
	}

}
