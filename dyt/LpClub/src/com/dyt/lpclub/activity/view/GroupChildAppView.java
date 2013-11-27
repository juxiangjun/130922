package com.dyt.lpclub.activity.view;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.AttributeSet;
import android.view.View;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;

import com.dyt.lpclub.R;
import com.dyt.lpclub.activity.adapter.GroupChildAdapter;
import com.dyt.lpclub.activity.domain.Group;

/**
 * 描述:子级群组
 * 
 * @author linqiang(866116)
 * @Since 2013-6-6
 */
public class GroupChildAppView extends CommonAppView {

	private Context mContext;
	private GroupChildAdapter mAdapter;
	private ListView listView;
	private List<Group> list;
	private Group group;
	private ImageView serachBtn;
	private EditText serachText;

	public GroupChildAppView(Context paramContext, String title) {
		super(paramContext);
		mContext = paramContext;
		init();
	}

	public GroupChildAppView(Context paramContext) {
		super(paramContext);
		mContext = paramContext;
		init();
	}

	public GroupChildAppView(Context paramContext, AttributeSet paramAttributeSet) {
		super(paramContext, paramAttributeSet);
		mContext = paramContext;
		init();
	}

	/**
	 * 
	 * 方法描述:初始化
	 * 
	 * @Author:solotiger
	 * @Date:2013-6-4
	 * @return:void
	 */
	private void init() {
		addView(R.layout.layout_child_group);
		list = new ArrayList<Group>();
		mAdapter = new GroupChildAdapter(mContext, list);
		listView = (ListView) $(R.id.groupChildList);
		listView.setAdapter(mAdapter);
		serachBtn = (ImageView) findViewById(R.id.serachBtn);
		serachText = (EditText) findViewById(R.id.serachText);
		serachBtn.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				mAdapter.getFilter().filter(serachText.getText());
			}
		});

		serachText.addTextChangedListener(new TextWatcher() {
			@Override
			public void onTextChanged(CharSequence s, int start, int before, int count) {
				mAdapter.getFilter().filter(s);
			}

			@Override
			public void beforeTextChanged(CharSequence s, int start, int count, int after) {

			}

			@Override
			public void afterTextChanged(Editable s) {

			}
		});
	}

	/**
	 * 描述:刷新
	 * 
	 * @author linqiang(866116)
	 * @Since 2013-6-6
	 */
	public void refresh() {
		mAdapter.notifyDataSetChanged();
	}

	private View $(int resId) {
		return findViewById(resId);
	}

	public void setOnItemClickListener(OnItemClickListener linstener) {
		listView.setOnItemClickListener(linstener);
	}

	public void setList(List<Group> list) {
		this.list = list;
		mAdapter.setNewgl(this.list);
	}

	public void addList(List<Group> list) {
		this.list.clear();
		this.list.addAll(list);
		mAdapter.setNewgl(this.list);
	}

	public void setParent(Group group) {
		this.group = group;
	}

	public Group getGroup() {
		return group;
	}

	public void setGroup(Group group) {
		this.group = group;
	}

	public List<Group> getList() {
		return list;
	}
	// private String $Str(int resId) {
	// return mContext.getString(resId);
	// }
}
