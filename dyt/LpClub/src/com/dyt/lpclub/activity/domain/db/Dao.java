package com.dyt.lpclub.activity.domain.db;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.database.Cursor;
import android.util.Log;

import com.dyt.lpclub.activity.domain.Group;
import com.dyt.lpclub.activity.domain.Msg;
import com.dyt.lpclub.activity.domain.User;
import com.dyt.lpclub.global.Global;
import com.dyt.lpclub.global.GlobalContants;

/**
 * 描述:数据库操作类
 * 
 * @author linqiang(866116)
 * @Since 2013-7-4
 */
public class Dao {
	
	/**
	 * 描述:通过USERID查询出所有的GROUP
	 * @author linqiang(866116)
	 * @Since 2013-7-4
	 * @param db
	 * @param userId
	 * @param isParent
	 * @return
	 */
	public ArrayList<Group> getGroupByUserId(AbstractDataBase db, int userId, boolean isParent) {
		ArrayList<Group> groups = new ArrayList<Group>();
		StringBuffer stringBuffer = new StringBuffer();
		stringBuffer.append(GroupTable.CONST_SELECT + " AND " + GroupTable.CONST_USERID + " = " + userId);
		if (isParent) {
			stringBuffer.append(" AND " + GroupTable.CONST_PARENT + " = \"\" ");
		}
		Cursor cursor = null;
		try {
			cursor = db.query(stringBuffer.toString());
			if (null != cursor && cursor.getCount() > 0) {
				
				while (cursor.moveToNext()) {
					Group group 			= 	new Group();
					int indexId 			= 	cursor.getColumnIndex(GroupTable.CONST_ID);
					int indexName 			= 	cursor.getColumnIndex(GroupTable.CONST_NAME);
					int indexState 			= 	cursor.getColumnIndex(GroupTable.CONST_STATE);
					int indexRemark 		= 	cursor.getColumnIndex(GroupTable.CONST_REMARK);
					int indexPic 			= 	cursor.getColumnIndex(GroupTable.CONST_PIC);
					int indexNews 			= 	cursor.getColumnIndex(GroupTable.CONST_NEWS);
					int indexType 			= 	cursor.getColumnIndex(GroupTable.CONST_TYPE);
					int indexResid 			= 	cursor.getColumnIndex(GroupTable.CONST_RESID);
					int indexParent 		= 	cursor.getColumnIndex(GroupTable.CONST_PARENT);
					int indexMembercount 	= 	cursor.getColumnIndex(GroupTable.CONST_MEMBERCOUNT);
					int indexUserid 		= 	cursor.getColumnIndex(GroupTable.CONST_USERID);
					int indexSpell 			= 	cursor.getColumnIndex(GroupTable.CONST_SPELL);

					group.setId(cursor.getInt(indexId));
					group.setName(cursor.getString(indexName));
					group.setState(cursor.getInt(indexState) == 0 ? false : true);
					group.setRemark(cursor.getString(indexRemark));
					group.setPic(cursor.getString(indexPic));
					group.setNews(cursor.getString(indexNews));
					group.setType(cursor.getInt(indexType));
					group.setResId(cursor.getInt(indexResid));
					group.setParent(cursor.getInt(indexParent));
					group.setMemberCount(cursor.getInt(indexMembercount));
					group.setUserid(cursor.getString(indexUserid));
					group.spell = cursor.getString(indexSpell);

					groups.add(group);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (null != cursor)
				cursor.close();
		}
		return groups;
	}
	
	/**
	 * 描述:通过父ID查询出Group
	 * @author linqiang(866116)
	 * @Since 2013-7-4
	 * @param db
	 * @param parentId
	 * @return
	 */
	public ArrayList<Group> getSubGroupByParentId(AbstractDataBase db, int parentId) {
		StringBuffer stringBuffer = new StringBuffer();
		stringBuffer.append(GroupTable.CONST_SELECT + " AND " + GroupTable.CONST_PARENT + " = " + parentId);
		Cursor cursor = null;
		try {
			cursor = db.query(stringBuffer.toString());
			if (null != cursor && cursor.getCount() > 0) {
				ArrayList<Group> groups = new ArrayList<Group>();
				while (cursor.moveToNext()) {
					Group group 			= 	new Group();
					int indexId 			= 	cursor.getColumnIndex(GroupTable.CONST_ID);
					int indexName 			= 	cursor.getColumnIndex(GroupTable.CONST_NAME);
					int indexState 			= 	cursor.getColumnIndex(GroupTable.CONST_STATE);
					int indexRemark 		= 	cursor.getColumnIndex(GroupTable.CONST_REMARK);
					int indexPic 			= 	cursor.getColumnIndex(GroupTable.CONST_PIC);
					int indexNews 			= 	cursor.getColumnIndex(GroupTable.CONST_NEWS);
					int indexType 			= 	cursor.getColumnIndex(GroupTable.CONST_TYPE);
					int indexResid 			= 	cursor.getColumnIndex(GroupTable.CONST_RESID);
					int indexParent 		= 	cursor.getColumnIndex(GroupTable.CONST_PARENT);
					int indexMembercount 	= 	cursor.getColumnIndex(GroupTable.CONST_MEMBERCOUNT);
					int indexUserid 		= 	cursor.getColumnIndex(GroupTable.CONST_USERID);
					int indexSpell 			= 	cursor.getColumnIndex(GroupTable.CONST_SPELL);

					group.setId(cursor.getInt(indexId));
					group.setName(cursor.getString(indexName));
					group.setState(cursor.getInt(indexState) == 0 ? false : true);
					group.setRemark(cursor.getString(indexRemark));
					group.setPic(cursor.getString(indexPic));
					group.setNews(cursor.getString(indexNews));
					group.setType(cursor.getInt(indexType));
					group.setResId(cursor.getInt(indexResid));
					group.setParent(cursor.getInt(indexParent));
					group.setMemberCount(cursor.getInt(indexMembercount));
					group.setUserid(cursor.getString(indexUserid));
					group.spell = cursor.getString(indexSpell);
					groups.add(group);
				}
				return groups;
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (null != cursor)
				cursor.close();
		}
		return null;
	}
	
	/**
	 * 描述:获得用户列表
	 * @author linqiang(866116)
	 * @Since 2013-7-4
	 * @param db
	 * @param userId
	 * @return
	 */
	public ArrayList<User> getUserList(AbstractDataBase db, int userId) {
		ArrayList<User> messages = new ArrayList<User>();
		Cursor cursor = db.query(UserTable.CONST_SELECT + " AND KEY_USER_ID =" + userId);
		if (null != cursor && cursor.getCount() > 0) {
			while (cursor.moveToNext()) {
				User user = new User();
				int indexId 		= 	cursor.getColumnIndex(UserTable.CONST_ID);
				int indexAccount 	= 	cursor.getColumnIndex(UserTable.CONST_ACCOUNT);
				int indexState 		= 	cursor.getColumnIndex(UserTable.CONST_STATE);
				int indexName 		= 	cursor.getColumnIndex(UserTable.CONST_NAME);
				int indexPwd 		= 	cursor.getColumnIndex(UserTable.CONST_PASSWORD);
				int indexType 		= 	cursor.getColumnIndex(UserTable.CONST_DEVICETYPE);
				int indexDevice 	= 	cursor.getColumnIndex(UserTable.CONST_DEVICEID);
				int indexThumb 		= 	cursor.getColumnIndex(UserTable.CONST_PIC);
				int indexSex 		= 	cursor.getColumnIndex(UserTable.CONST_SEX);
				int keyUserId 		= 	cursor.getColumnIndex(UserTable.CONST_KEY_USER);
				int pos 			= 	cursor.getColumnIndex(UserTable.CONST_POS);
				int area1 			= 	cursor.getColumnIndex(UserTable.CONST_AREA1);
				int area2 			= 	cursor.getColumnIndex(UserTable.CONST_AREA2);
				int sign 			= 	cursor.getColumnIndex(UserTable.CONST_SIGN);
				int job1 			= 	cursor.getColumnIndex(UserTable.CONST_JOB1);
				int job2 			= 	cursor.getColumnIndex(UserTable.CONST_JOB2);
				int thumb 			= 	cursor.getColumnIndex(UserTable.CONST_THUMB);

				user.id 			= 	cursor.getInt(indexId);
				user.account 		= 	cursor.getString(indexAccount);
				user.state 			= 	cursor.getInt(indexState);
				user.name 			= 	cursor.getString(indexName);
				user.password 		= 	cursor.getString(indexPwd);
				user.devicetype 	= 	cursor.getString(indexType);
				user.deviceid 		= 	cursor.getString(indexDevice);
				user.pic 			= 	cursor.getString(indexThumb);
				user.sex 			= 	cursor.getInt(indexSex);
				user.keyUserId 		= 	cursor.getInt(keyUserId);
				user.pos 			= 	cursor.getString(pos);
				user.area1 			= 	cursor.getString(area1);
				user.area2 			= 	cursor.getString(area2);
				user.sign 			= 	cursor.getString(sign);
				user.job1 			= 	cursor.getString(job1);
				user.job2 			= 	cursor.getString(job2);
				user.thumb			=   cursor.getString(thumb);
				messages.add(user);
			}
		}
		return messages;
	}

	/**
	 * 
	 * 
	 * @Author C.xt
	 * @Title: getMsgByGroupId
	 * @Description: 通过group_id 拿分页信息
	 * @param messages
	 *            上一次数据集
	 * @param db
	 * @param group_id
	 * @param limit
	 *            limit每次拿多少
	 * @param offset
	 *            offset 跳过多少
	 * @return int 新增加条数
	 * @throws
	 * @date 2013-7-3下午11:23:21
	 */
	public int getMsgByGroupId(List<Msg> messages, AbstractDataBase db, int group_id, int limit, int offset) {
		if (null == messages) {
			messages = new ArrayList<Msg>();
		}
		int count = messages.size();
		
		
		ArrayList<Msg> messageTemp = new ArrayList<Msg>();
		String sql = TalkContentTable.CONST_SELECT_ALL + " AND " + TalkContentTable.CONST_GROUP_ID + "=" + group_id + " AND " + TalkContentTable.CONST_KEY_USER + "=" + Global.userid + " ORDER BY "
				+ TalkContentTable.CONST_ID + " DESC LIMIT  " + limit + " OFFSET " + offset;
		Cursor cursor = db.query(sql);
		if (null != cursor && cursor.getCount() > 0) {

			/**
			 * 查询语句是倒序查10条 查询结果重新倒序 跟list对应
			 */
			boolean ret = cursor.moveToLast();
			while (ret) {
				Msg msg = new Msg();
				int indexId = cursor.getColumnIndex(TalkContentTable.CONST_ID);
				int indexContent = cursor.getColumnIndex(TalkContentTable.CONST_CONTENT);
				int indexUserid = cursor.getColumnIndex(TalkContentTable.CONST_USERID);
				int indexGroupid = cursor.getColumnIndex(TalkContentTable.CONST_GROUP_ID);
				int indexState = cursor.getColumnIndex(TalkContentTable.CONST_STATE);
				int indexType = cursor.getColumnIndex(TalkContentTable.CONST_TYPE);
				int indexTime = cursor.getColumnIndex(TalkContentTable.CONST_TIME);
				int indexThumb = cursor.getColumnIndex(TalkContentTable.CONST_THUMB);
				int indexNewspos = cursor.getColumnIndex(TalkContentTable.CONST_NEWMSGPOS);
				int indexSoundtime = cursor.getColumnIndex(TalkContentTable.CONST_SOUNDTIME);
				int indexNewmsgid = cursor.getColumnIndex(TalkContentTable.CONST_NEWMSG_ID);
				int indexSoundlocal = cursor.getColumnIndex(TalkContentTable.CONST_SOUNDLOCAL);

				msg.localId = cursor.getString(indexId);
				msg.content = cursor.getString(indexContent);
				msg.userid = cursor.getInt(indexUserid);
				msg.group_id = cursor.getInt(indexGroupid);
				msg.state = cursor.getString(indexState);
				msg.type = cursor.getInt(indexType);
				msg.TIME = cursor.getString(indexTime);
				msg.thumb = cursor.getString(indexThumb);
				msg.newMsgPos = cursor.getInt(indexNewspos);
				msg.soundTime = cursor.getString(indexSoundtime);
				msg.newmsgid = cursor.getInt(indexNewmsgid);
				msg.soundLocal = Boolean.valueOf(cursor.getString(indexSoundlocal));
				msg.userid = cursor.getInt(indexUserid);
				messageTemp.add(msg);
				ret = cursor.moveToPrevious();
			}
			messages.clear();
			messages.addAll(messageTemp);
		}
		return messages.size() - count;
	}
	
	/**
	 * 
		 * 
		* @Author 								C.xt
		* @Title: 								getImgUrlByGroupId
		* @Description:							
		* @param hashMapUrls						
		* @param db
		* @param group_id
		* @return								int
		* @throws								
		* @date 								2013-7-6下午10:46:42
	 */
	public ArrayList<String>  getImgUrlByGroupId(Context context, int group_id) {
		
		ArrayList<String> imageUrls = new ArrayList<String>();
		LpClubDB db = new LpClubDB(context);
		Cursor cursor = null;
		try{
			String sql = String.format(TalkContentTable.CONST_SELECT_COL , TalkContentTable.CONST_CONTENT)
								+ " AND " + TalkContentTable.CONST_GROUP_ID + "=" + group_id 
								+ " AND "+TalkContentTable.CONST_TYPE +" = "+ GlobalContants.CONST_INT_MES_TYPE_IMG							
								+ " AND " + TalkContentTable.CONST_KEY_USER + "=" + Global.userid
								+ " ORDER BY " + TalkContentTable.CONST_ID;
			cursor = db.query(sql);
			if (null != cursor && cursor.getCount() > 0) {
				boolean ret = cursor.moveToFirst();
				int i = 0;
				while (ret) {
					String url  = cursor.getString(0);
					imageUrls.add(i, GlobalContants.CONST_STR_BASE_URL+url);
					i++;
					ret = cursor.moveToNext();
				}
			}
		}catch (Exception e) {
			e.printStackTrace();
		}finally{
			if(null != db){
				db.close();
			}
			if(null != cursor){
				cursor.close();
			}
		}
		return imageUrls;
	}

	public Msg getMsgByNewMsgId(AbstractDataBase db, String newmsgid) {
		Msg msg = null;
		Cursor cursor = db.query(TalkContentTable.SELECT_BY_NEWMSG_ID, new String[] { newmsgid, String.valueOf(Global.userid) });
		if (null != cursor && cursor.getCount() > 0) {
			if (cursor.moveToNext()) {
				msg = new Msg();
				int indexId = cursor.getColumnIndex(TalkContentTable.CONST_ID);
				int indexContent = cursor.getColumnIndex(TalkContentTable.CONST_CONTENT);
				int indexUserid = cursor.getColumnIndex(TalkContentTable.CONST_USERID);
				int indexGroupid = cursor.getColumnIndex(TalkContentTable.CONST_GROUP_ID);
				int indexState = cursor.getColumnIndex(TalkContentTable.CONST_STATE);
				int indexType = cursor.getColumnIndex(TalkContentTable.CONST_TYPE);
				int indexTime = cursor.getColumnIndex(TalkContentTable.CONST_TIME);
				int indexThumb = cursor.getColumnIndex(TalkContentTable.CONST_THUMB);
				int indexNewspos = cursor.getColumnIndex(TalkContentTable.CONST_NEWMSGPOS);
				int indexSoundtime = cursor.getColumnIndex(TalkContentTable.CONST_SOUNDTIME);
				int indexNewmsgid = cursor.getColumnIndex(TalkContentTable.CONST_NEWMSG_ID);
				int indexSoundlocal = cursor.getColumnIndex(TalkContentTable.CONST_SOUNDLOCAL);

				msg.localId = cursor.getString(indexId);
				msg.content = cursor.getString(indexContent);
				msg.userid = cursor.getInt(indexUserid);
				msg.group_id = cursor.getInt(indexGroupid);
				msg.state = cursor.getString(indexState);
				msg.type = cursor.getInt(indexType);
				msg.TIME = cursor.getString(indexTime);
				msg.thumb = cursor.getString(indexThumb);
				msg.newMsgPos = cursor.getInt(indexNewspos);
				msg.soundTime = cursor.getString(indexSoundtime);
				msg.newmsgid = cursor.getInt(indexNewmsgid);
				msg.soundLocal = Boolean.valueOf(cursor.getString(indexSoundlocal));
				msg.userid = cursor.getInt(indexUserid);
			}
		}
		return msg;
	}

	public boolean isUserLoginedBefore(AbstractDataBase db, String userid) {
		try {
			Cursor c = db.query(LpClubDB.CONFIG_SELECT, new String[] { LpClubDB.KEY_USER + userid });
			boolean hadInit = c.moveToNext();
			c.close();
			return hadInit;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	public boolean insertUserLogined(AbstractDataBase db, String userid) {
		try {
			db.beginTransaction();
			db.execSQL(LpClubDB.CONFIG_INSERT, new String[] { LpClubDB.KEY_USER + userid, "Y" });
			db.endTransaction();
		} catch (Exception e) {
			e.printStackTrace();
		}

		return false;
	}

	public boolean deleteNewMsgFormId(AbstractDataBase db, int newMsgid) {
		try {
			int userid = Global.userid;
			db.execSQL(NewMsgTable.NEW_MSG_COUNT_DELETE, new String[] { String.valueOf(newMsgid), String.valueOf(userid) });
			db.execSQL(TalkContentTable.DELETE_BY_NEWMSG_ID, new String[] { String.valueOf(newMsgid), String.valueOf(userid) });
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}

}
