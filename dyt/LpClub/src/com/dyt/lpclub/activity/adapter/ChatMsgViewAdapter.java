package com.dyt.lpclub.activity.adapter;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.content.Intent;
import android.media.MediaPlayer;
import android.media.MediaPlayer.OnCompletionListener;
import android.media.MediaPlayer.OnErrorListener;
import android.net.Uri;
import android.os.Handler;
import android.text.SpannableString;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.dyt.lpclub.R;
import com.dyt.lpclub.activity.ActivityUserDetail;
import com.dyt.lpclub.activity.domain.Msg;
import com.dyt.lpclub.activity.domain.User;
import com.dyt.lpclub.activity.domain.db.Dao;
import com.dyt.lpclub.activity.domain.db.LpClubDB;
import com.dyt.lpclub.activity.domain.db.TalkContentTable;
import com.dyt.lpclub.activity.imgbrowse.ActivityImgBrowse;
import com.dyt.lpclub.global.Global;
import com.dyt.lpclub.global.GlobalContants;
import com.dyt.lpclub.global.GolbalUserCache;
import com.dyt.lpclub.global.GolbalUserCache.GetUserCallBack;
import com.dyt.lpclub.util.UtilExpression;
import com.dyt.lpclub.util.UtilFile;
import com.dyt.lpclub.util.UtilString;
import com.dyt.lpclub.util.UtilThread;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.assist.ImageScaleType;
import com.nostra13.universalimageloader.core.display.RoundedBitmapDisplayer;

public class ChatMsgViewAdapter extends BaseAdapter {

	public static interface IMsgViewType {
		int IMVT_COM_MSG = 0;
		int IMVT_TO_MSG = 1;
	}

	private boolean 			isLeft;
	private List<Msg> 			coll;
	private Context 			ctx;
	private ImageView 			soundPlay;
	private String	 			soundPath;
	private User 				user;
	private LayoutInflater 		mInflater;
	private MediaPlayer 		mMediaPlayer;
	private Handler 			mHandler 	= 	new Handler();
	private DisplayImageOptions headOptions,
								headOptions1;
	private DisplayImageOptions options;
	private int					group_id;
	
	private boolean 			isPlayMusic;
	
	private ArrayList<String> imageUrls;
	
	public ChatMsgViewAdapter(Context context, List<Msg> coll, final Handler mHandler ,int group_id) {
		this.ctx 					= 	context;
		this.coll 					= 	coll;
		mMediaPlayer 				= 	new MediaPlayer();
		mInflater 					= 	LayoutInflater.from(context);
		this.headOptions 			= 	new DisplayImageOptions.Builder()
											.showStubImage(R.drawable.default_head)
											.showImageForEmptyUri(R.drawable.default_head)
											.showImageOnFail(R.drawable.default_head)
											.cacheInMemory(true)
											.cacheOnDisc(true)
											.build();
		this.options 				= 	new DisplayImageOptions.Builder()
											.showStubImage(R.drawable.wallpaper_loading)
											.showImageForEmptyUri(R.drawable.wallpaper_loading)
											.showImageOnFail(R.drawable.wallpaper_loading)
											.imageScaleType(ImageScaleType.EXACTLY)
											.cacheInMemory(true)
											.cacheOnDisc(true)
											.build();
		this.headOptions1 			= 	new DisplayImageOptions.Builder()
											.showStubImage(R.drawable.default_head)
											.showImageForEmptyUri(R.drawable.default_head)
											.showImageOnFail(R.drawable.default_head)
											.imageScaleType(ImageScaleType.EXACTLY)
											.cacheInMemory(true)
											.cacheOnDisc(true)
											.displayer(new RoundedBitmapDisplayer(8))
											.build();
		this.group_id = group_id;
	}

	public int getCount() {
		return coll.size();
	}

	public Object getItem(int position) {
		return coll.get(position);
	}

	public long getItemId(int position) {
		return position;
	}

	@Override
	public int getItemViewType(int position) {
		Msg entity = coll.get(position);
		if (Global.getMe().getGlobalUser().id != entity.userid) {
			return IMsgViewType.IMVT_COM_MSG;
		} else {
			return IMsgViewType.IMVT_TO_MSG;
		}

	}

	public int getViewTypeCount() {
		return 2;
	}

	
	public View getView(final int position, View convertView, ViewGroup parent) {

		final Msg entity = coll.get(position);
		final int userId = entity.userid;
		user = GolbalUserCache.getUserFromCache("" + userId, null);
		final int type = getItemViewType(position);
		final ViewHolder viewHolder;
		/**
		 * 消息来源 true：自己 false:别人
		 */
		//		boolean isComMsg = (Global.getMe().getGlobalUser().id == userId);
		if (convertView == null) {

			switch (type) {
			case IMsgViewType.IMVT_COM_MSG:
				convertView = mInflater.inflate(R.layout.chatting_item_msg_text_left, null);
				break;
			case IMsgViewType.IMVT_TO_MSG:
				convertView = mInflater.inflate(R.layout.chatting_item_msg_text_right, null);
				break;
			}
			viewHolder = new ViewHolder();
			viewHolder.tvContent = (TextView) convertView.findViewById(R.id.tv_chatcontent);
			viewHolder.tvTime = (TextView) convertView.findViewById(R.id.tv_time);
			viewHolder.imgContent = (ImageView) convertView.findViewById(R.id.img_content);
			viewHolder.img_sound = (ImageView) convertView.findViewById(R.id.img_sound);
			viewHolder.imgUserhead = (ImageView) convertView.findViewById(R.id.iv_userhead);
//			viewHolder.layoutContent = (LinearLayout) convertView.findViewById(R.id.layout_chat_content);
			//			viewHolder.user = user;
			convertView.setTag(viewHolder);
		} else {
			viewHolder = (ViewHolder) convertView.getTag();
		}
		
		viewHolder.imgUserhead.setImageResource(R.drawable.default_head);
		
		user = GolbalUserCache.getUserFromCache("" + userId, new GetUserCallBack() {
			@Override
			public void invoke(User user) {
				if(user.id == Global.userid){
					user = Global.getMe().getGlobalUser();;
					if (user.thumb.startsWith("file:/")) {
						ImageLoader.getInstance().displayImage(user.thumb, viewHolder.imgUserhead, headOptions1);
					} else {
						ImageLoader.getInstance().displayImage(GlobalContants.CONST_STR_BASE_URL + user.thumb, viewHolder.imgUserhead, headOptions1);
					}
				}else{
					ImageLoader.getInstance().displayImage(GlobalContants.CONST_STR_BASE_URL + user.thumb, viewHolder.imgUserhead , headOptions);
				}
			}
		});
		
		viewHolder.imgUserhead.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				Msg msg = coll.get(position);
				Intent intent = new Intent(ctx, ActivityUserDetail.class);
				intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
				intent.putExtra("userid", msg.userid);
				ctx.startActivity(intent);
			}
		});

		if (GlobalContants.CONST_INT_MES_TYPE_SOUND == entity.type) {
			String content = "";
			if (type == IMsgViewType.IMVT_COM_MSG) {
				if (null == user) {
				} else {
					content = user.name + ":";
				}
			} else {
				content = "我:";
			}
			viewHolder.tvContent.setText(content);
			viewHolder.img_sound.setVisibility(View.VISIBLE);
			viewHolder.imgContent.setVisibility(View.GONE);
			if (type == IMsgViewType.IMVT_COM_MSG) {
				viewHolder.img_sound.setImageResource(R.drawable.chatto_voice_playing_left);
			} else {
				viewHolder.img_sound.setImageResource(R.drawable.chatto_voice_playing_right);
			}
			
			viewHolder.tvTime.setVisibility(View.VISIBLE);

			final ImageView viewTemp = viewHolder.img_sound;
			

			String fileName = entity.content.substring(entity.content.lastIndexOf("/")+1);
			final String path = GlobalContants.CONST_VIDEO_CACHE_IMG + fileName;
			viewTemp.setTag(path);
			
			viewHolder.img_sound.setOnClickListener(new OnClickListener() {
				public void onClick(View v) {
					
					if(!UtilFile.isFileExits(path)){
						return;
					}
					if(null != soundPlay){
						if ((Boolean) soundPlay.getTag(R.id.tag_first)) {
							soundPlay.setImageResource(R.drawable.chatto_voice_playing_left);
						} else {
							soundPlay.setImageResource(R.drawable.chatto_voice_playing_right);
						}
					}
					initSoundPlay();

					if (GlobalContants.CONST_INT_MES_TYPE_SOUND == entity.type ) {
						isPlayMusic = true;
						soundPlay = viewTemp;
						soundPath = path;
						switch (type) {
						case IMsgViewType.IMVT_COM_MSG:
							isLeft = true;
							break;
						case IMsgViewType.IMVT_TO_MSG:
							isLeft = false;
							break;
						}
						soundPlay.setTag(R.id.tag_first, isLeft);
						mHandler.postDelayed(playSoundAn, REFRESH_INTERVAL);
						UtilThread.executeMore(new Runnable() {
							@Override
							public void run() {
								playMusic(path);
							}
						});
					}
				}
			});
			
			if(UtilString.isAnyEmpty(entity.soundTime)){
					UtilThread.executeMore(new Runnable() {
					@Override
					public void run() {
						String localId =entity.localId;
						String fileName = entity.content.substring(entity.content.lastIndexOf("/")+1);
								   Uri dataSource = Uri.parse("file:///sdcard/LPclub/video/"+fileName);
								   String soundTime = getDuration(dataSource) ;
								   
						if(!UtilString.isEmpty(soundTime)){
							if(type == IMsgViewType.IMVT_COM_MSG){
								entity.soundTime = soundTime + "'" ;
							}else{
								entity.soundTime = "'" + soundTime;
							}
							
							LpClubDB db = null;
							try{
								db = new LpClubDB(ctx);
								db.execSQL("UPDATE [" + TalkContentTable.CONST_TALBENAME+"] SET " + TalkContentTable.CONST_SOUNDTIME + " = "+ soundTime +" WHERE "+
										TalkContentTable.CONST_ID +" = '"+ localId+"'");
								db.close();
							
							}catch (Exception e) {
								e.printStackTrace();
							}finally{
								if(null != db){
									db.close();
								}
							}
							mHandler.post(new Runnable() {
								
								@Override
								public void run() {
									notifyDataSetChanged();
								}
							});
						}
					}
				});
			}else{
				if (!entity.soundTime.startsWith("'")
						&& !entity.soundTime.endsWith("'")) {
					if (type == IMsgViewType.IMVT_COM_MSG) {
						entity.soundTime = entity.soundTime + "'";
					} else {
						entity.soundTime = "'" + entity.soundTime;
					}
				}
			}
			viewHolder.tvTime.setText(entity.soundTime);
		} else if (GlobalContants.CONST_INT_MES_TYPE_TEXT == entity.type) {
			if (type == IMsgViewType.IMVT_COM_MSG) {
				String content;
				
				
				if (null == user) {
					content = entity.content;
				} else {
					content = user.name + ":" + entity.content;

				}
				/**
				 * 正则表达式，用来判断消息内是否有表情
				 */
		        String rex = "\\[(.*?)\\]";
//			 }
				try {
					SpannableString spannableString = UtilExpression.getExpressionString(ctx, content, rex);
					viewHolder.tvContent.setText(spannableString);
//					text.setText(spannableString);
				} catch (NumberFormatException e) {
					e.printStackTrace();
				} catch (SecurityException e) {
					e.printStackTrace();
				} catch (IllegalArgumentException e) {
					e.printStackTrace();
				}
				
			} else {
				 String rex = "\\[(.*?)\\]";
					try {
						SpannableString spannableString = UtilExpression.getExpressionString(ctx, "我："+entity.content, rex);
						viewHolder.tvContent.setText(spannableString);
//						text.setText(spannableString);
					} catch (NumberFormatException e) {
						e.printStackTrace();
					} catch (SecurityException e) {
						e.printStackTrace();
					} catch (IllegalArgumentException e) {
						e.printStackTrace();
					}
					
				//				viewHolder.tvContent.setText(user.name + entity.content);
//				viewHolder.tvContent.setText("我:" + entity.content);
			}
			viewHolder.tvTime.setText("");
			viewHolder.tvTime.setVisibility(View.GONE);
			viewHolder.imgContent.setVisibility(View.GONE);
			viewHolder.img_sound.setVisibility(View.GONE);

		} else if (GlobalContants.CONST_INT_MES_TYPE_IMG == entity.type) {
			String content = "";
			if (type == IMsgViewType.IMVT_COM_MSG) {
				if (null == user) {
				} else {
					content = user.name + ":";
				}
			} else {
				content = "我:";
			}
			viewHolder.tvContent.setText(content);
			
			
			//add by linqiang
			viewHolder.img_sound.setVisibility(View.GONE);
			viewHolder.imgContent.setVisibility(View.VISIBLE);
			viewHolder.imgContent.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View v) {
					if (GlobalContants.CONST_INT_MES_TYPE_IMG == entity.type) {
						Dao dao = new Dao();
						imageUrls = dao.getImgUrlByGroupId(ctx, group_id);
						Intent intent = new Intent(ctx, ActivityImgBrowse.class);
						intent.putExtra("nowUrl", GlobalContants.CONST_STR_BASE_URL + entity.content);
						intent.putStringArrayListExtra("imageUrls", imageUrls);
						ctx.startActivity(intent);
					}
				}
			});
			if(!UtilString.isEmpty(entity.thumb))
				if (entity.thumb.startsWith("file:/")) {
					viewHolder.imgContent.setImageURI(Uri.parse(entity.thumb));
				} else {
					ImageLoader.getInstance().displayImage(GlobalContants.CONST_STR_BASE_URL + entity.thumb, viewHolder.imgContent, options);
				}
			viewHolder.tvTime.setText("");
			viewHolder.tvTime.setVisibility(View.GONE);
		}
		return convertView;
	}

	static class ViewHolder {
		/**
		 * 内容
		 */
		public TextView tvContent;
		public TextView tvTime;
		public ImageView imgContent;
		public ImageView img_sound;
		public ImageView imgUserhead;
//		public LinearLayout layoutContent;
		public User user;
	}

	/**
	 * @Description
	 * @param name
	 */
	private synchronized void playMusic(String name) {
		try {

			if(!new File(name).exists()){
				return;
			}
			
			if (mMediaPlayer.isPlaying()) {
				mMediaPlayer.stop();
			}
			mMediaPlayer.reset();
			mMediaPlayer.setDataSource(name);
			mMediaPlayer.prepare();
			mMediaPlayer.start();
			mMediaPlayer.setOnCompletionListener(new OnCompletionListener() {
				public void onCompletion(MediaPlayer mp) {
					initSoundPlay();
				}
			});

			mMediaPlayer.setOnErrorListener(new OnErrorListener() {
				
				@Override
				public boolean onError(MediaPlayer mp, int what, int extra) {
					initSoundPlay();
					return false;
				}
			});
		} catch (Exception e) {
			e.printStackTrace();
		}

	}

	public void initSoundPlay() {
		try {
			if (null != playSoundAn) {
				mHandler.removeCallbacks(playSoundAn);
				if (null != soundPlay) {
					mHandler.post(new Runnable() {

						@Override
						public void run() {
							if ((Boolean) soundPlay.getTag(R.id.tag_first)) {
								soundPlay.setImageResource(R.drawable.chatto_voice_playing_left);
							} else {
								soundPlay.setImageResource(R.drawable.chatto_voice_playing_right);
							}
							isPlayMusic = false;
						}
					});
				}

			}
		} catch (Exception e) {
			e.printStackTrace();
		}

	}

	private static final int REFRESH_INTERVAL = 300;

	private Runnable playSoundAn = new Runnable() {
		public void run() {
			if(soundPath.equals(soundPlay.getTag())){
				updatePlaySound();
			}else{
				if (isLeft) {
					soundPlay.setImageResource(R.drawable.chatto_voice_playing_left);
				} else {
					soundPlay.setImageResource(R.drawable.chatto_voice_playing_right);
				}
			}
			mHandler.postDelayed(playSoundAn, REFRESH_INTERVAL);
		}
	};

	int index = -1;

	private void updatePlaySound() {
		if (null == soundPlay) {
			return;
		}
		index++;
		switch ((int) index % 3) {
		case 0:
			if (isLeft) {
				soundPlay.setImageResource(R.drawable.chatto_voice_playing_f1_left);
			} else {
				soundPlay.setImageResource(R.drawable.chatto_voice_playing_f1);
			}
			break;
		case 1:
			if (isLeft) {
				soundPlay.setImageResource(R.drawable.chatto_voice_playing_f2_left);
			} else {
				soundPlay.setImageResource(R.drawable.chatto_voice_playing_f2);
			}
			break;
		case 2:
			if (isLeft) {
				soundPlay.setImageResource(R.drawable.chatto_voice_playing_f3_left);
			} else {
				soundPlay.setImageResource(R.drawable.chatto_voice_playing_f3);
			}
			break;
		default:
			if (isLeft) {
				soundPlay.setImageResource(R.drawable.chatto_voice_playing_left);
			} else {
				soundPlay.setImageResource(R.drawable.chatto_voice_playing_right);
			}
			break;
		}
	}
	
	private MediaPlayer mediaPlayer;
	private synchronized String getDuration(Uri dataSource) {
		int soundTime = 0; 
		try {
		mediaPlayer = MediaPlayer.create(ctx, dataSource);
		soundTime = mediaPlayer.getDuration()/(1000) < 1 ? 1 : mediaPlayer.getDuration()/(1000);
		} catch (Exception e) {
			e.printStackTrace();
			return "";
		} 
		return "" + soundTime;
	}

}
