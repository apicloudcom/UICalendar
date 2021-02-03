
/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
package com.uzmap.pkg.uzmodules.UICalendar;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;

import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.ColorDrawable;
import android.os.AsyncTask;
import android.os.Handler;
import android.text.TextUtils;
import android.text.format.DateFormat;
import android.util.AttributeSet;
import android.util.Log;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.uzmap.pkg.uzcore.UZResourcesIDFinder;
import com.uzmap.pkg.uzcore.uzmodule.UZModuleContext;

public class CalendarView extends LinearLayout {

	/**
	 * represent the current month
	 */
	public Calendar mCurrentMonth;

	public GridAdapter mAdapter;

	public ArrayList<SpecicalDateStyle> mSpecialDateItems;

	public Context mContext;
	private int viewId = 0;

	/**
	 * represent the current calendar grid
	 */
	private GridView mCalendarGrid;

	private Bitmap mSpecialBgBmp;

	private GestureDetector mDetector;
	static final int PICK_DATE_REQUEST = 1;

	/**
	 * represent the height of the CalendarView
	 */
	private int mHeight;

	private static final String EVENT_TYPE_SHOW = "show";
	private static final String EVENT_TYPE_SWITCH = "switch";
	private static final String EVENT_TYPE_SPECIAL = "special";
	private static final String EVENT_TYPE_NORMAL = "normal";
	
	private static final String EVENT_TYPE_CANCEL_SPECIAL = "cancelSpecial";
	private static final String EVENT_TYPE_CANCEL_NORMAL = "cancelNormal";

	public CalendarView(Context context, AttributeSet attrs) {
		super(context, attrs);
		this.mContext = context;
	}

	public void setSpecialDates(ArrayList<SpecicalDateStyle> specialDateItems){
		this.mSpecialDateItems = specialDateItems;
		refreshDays();
		if(mAdapter != null){
			mAdapter.notifyDataSetChanged();
		}
	}

	private class InitTask extends AsyncTask<Void, Void, Void> {
		
		private UZModuleContext uzContext;
		
		public InitTask(UZModuleContext mContext){
			this.uzContext = mContext;
		}

		@SuppressLint("SimpleDateFormat")
		@Override
		protected Void doInBackground(Void... params) {

			int mo_calendar_sportID = UZResourcesIDFinder
					.getResDrawableID("mo_calendar_sport");
			mSpecialBgBmp = BitmapFactory.decodeResource(
					mContext.getResources(), mo_calendar_sportID);

			mCurrentMonth = Calendar.getInstance();
			SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");

			String date = format.format(new Date());
			String[] dateArr = date.split("-");

			mCurrentMonth.set(Integer.parseInt(dateArr[0]),
					Integer.parseInt(dateArr[1]) - 1, 1);

			/**
			 * update the changes
			 */
			refreshDays();

			Utils.callback(uzContext, EVENT_TYPE_SHOW,
					mCurrentMonth.get(Calendar.YEAR),
					mCurrentMonth.get(Calendar.MONTH),
					todayCalendar.get(Calendar.DAY_OF_MONTH), Utils.TYPE_ALL,viewId);
			return null;
		}
		
		

		@Override
		protected void onPostExecute(Void result) {

			int gridviewID = UZResourcesIDFinder.getResIdID("gridview");
			mCalendarGrid = (GridView) findViewById(gridviewID);
			
			int lldateID = UZResourcesIDFinder.getResIdID("ll_date");
			LinearLayout linearLayout = (LinearLayout) findViewById(lldateID);

			mAdapter = new GridAdapter(mContext, mCurrentMonth, mCalendarGrid,
					mHeight, linearLayout);
			mAdapter.setConfig(mConfig);
			mAdapter.setDays(days);
			mAdapter.setItems(mSpecialDateItems);
			
			mCalendarGrid.setSelector(new ColorDrawable(Color.TRANSPARENT));

			mCalendarGrid.setAdapter(mAdapter);

			mCalendarGrid.setOnTouchListener(new OnTouchListener() {
				@SuppressLint("ClickableViewAccessibility")
				@Override
				public boolean onTouch(View v, MotionEvent event) {
					mDetector.onTouchEvent(event);
					return false;
				}
			});
			
			final ArrayList<String> selectedDays = new ArrayList<String>();
			mCalendarGrid.setOnItemClickListener(new OnItemClickListener() {

				@SuppressLint("DefaultLocale") @SuppressWarnings("deprecation")
				public void onItemClick(AdapterView<?> parent, View v, int position, long id) {
					
					int dateID = UZResourcesIDFinder.getResIdID("date");
					daysText = (TextView) v.findViewById(dateID);

					int backImgId = UZResourcesIDFinder.getResIdID("backImg");
					ImageView backImg = (ImageView) v.findViewById(backImgId);
					
					String day = daysText.getText().toString();
					
					if (!canClick(day)) {
						return;
					};
					
					mAdapter.setCurrentIndex(position);
					if(!mConfig.multipleSelect){
						refreshView();
						resetAllDayBg();
					}
					
					// 
					String today = String.format("%d-%d-%d", mCurrentMonth.get(Calendar.YEAR), mCurrentMonth.get(Calendar.MONTH) + 1, Integer.parseInt(day));
					if(mConfig.multipleSelect && /*selectedDays.contains(today)*/selectedDays.contains(day)){	
						Log.i("debug", "contains");
						
						/// =================================================>

						daysText.setTextColor(mConfig.dateColor);
						daysText.setBackgroundDrawable(null);

						backImg.setImageBitmap(null);

						if (!TextUtils.isEmpty(daysText.getText())) {
							if (mCurrentMonth.get(Calendar.YEAR) == todayCalendar.get(Calendar.YEAR)&& 
									mCurrentMonth.get(Calendar.MONTH) == todayCalendar.get(Calendar.MONTH)&& 
									Integer.parseInt(daysText.getText().toString()) == todayCalendar.get(Calendar.DAY_OF_MONTH) && mConfig.showTodayStyle) {
								daysText.setTextColor(mConfig.todayColor);
								if (mConfig.todayBitmap != null) {
									backImg.setImageBitmap(mConfig.todayBitmap);
									daysText.setBackgroundDrawable(null);
								} else {
									daysText.setBackgroundColor(mConfig.todayBg);
								}
							}
						}
						
						String day1 = daysText.getText().toString();
						if (day1.length() == 1) {
							day1 = "0" + day1;
						}

						if (day1.length() > 0
								&& mSpecialDateItems != null
								&& mSpecialDateItems
										.contains(new SpecicalDateStyle( android.text.format.DateFormat.format(
												"yyyy-MM", mCurrentMonth) + "-" + day1))) {
							
							
							daysText.setTextColor(mConfig.specialDateColor);
							
							if (mConfig.specialDateBgBitmap != null) {
								backImg.setImageBitmap(mConfig.specialDateBgBitmap);
								daysText.setBackgroundDrawable(null);
							} else {
								daysText.setBackgroundColor(mConfig.specialDateBg);
							}
							daysText.setTextColor(mConfig.specialDateColor);
							
							String curDateStr = android.text.format.DateFormat.format(
									"yyyy-MM", mCurrentMonth) + "-" + day1;
							SpecicalDateStyle curSpecialDate = getCurrentSpecialDate(
									curDateStr, mSpecialDateItems);
							
							if (curSpecialDate != null && curSpecialDate.hasBg) {
								if (curSpecialDate.bg != null) {

									backImg.setImageBitmap(curSpecialDate.bg);
									daysText.setBackgroundDrawable(null);

								} else {
									daysText.setBackgroundColor(curSpecialDate.bgColor);
								}
							}

							if (curSpecialDate != null && curSpecialDate.hasTextColor) {
								daysText.setTextColor(curSpecialDate.color);
							}
							
							Utils.callback(uzContext, EVENT_TYPE_CANCEL_SPECIAL,
									mCurrentMonth.get(Calendar.YEAR),
									mCurrentMonth.get(Calendar.MONTH),
									Integer.parseInt(day), Utils.TYPE_ALL,viewId);
						} else {
							Utils.callback(uzContext, EVENT_TYPE_CANCEL_NORMAL,
									mCurrentMonth.get(Calendar.YEAR),
									mCurrentMonth.get(Calendar.MONTH),
									Integer.parseInt(day), Utils.TYPE_ALL,viewId);
						}
						
						mCurrentMonth.set(Calendar.DAY_OF_MONTH, Integer.parseInt(day));
						if(mCurrentMonth.get(Calendar.DAY_OF_WEEK) == Calendar.SATURDAY || mCurrentMonth.get(Calendar.DAY_OF_WEEK) == Calendar.SUNDAY){
							daysText.setTextColor(mConfig.weekendColor);
				        }
						
						selectedDays.remove(day);
//						selectedDays.remove(today);
						mAdapter.removeCurrentDay(day);
						return;
					
						/// =================================================>
						
					}
					
					
					if (daysText instanceof TextView && !daysText.getText().equals("")) {
						Log.i("asher day -- ", day);
						if (mConfig.multipleSelect) {
							
							mAdapter.changeCurrentDay(day);
						}else{
							mAdapter.oneCurrentDay(day);
							mAdapter.setCurrentYear(mCurrentMonth.get(Calendar.YEAR));
							mAdapter.setCurrentMonth(mCurrentMonth.get(Calendar.MONTH));
						}
						
						if(mConfig.multipleSelect){
							selectedDays.add(day);
//							selectedDays.add(today);
						}
						
						if (day.length() == 1) {
							day = "0" + day;
						}
						
						// do unselected
						
						// do unselected
						
						currentIndex = position;
						
						if (day.length() > 0
								&& mSpecialDateItems != null
								&& mSpecialDateItems.contains( new SpecicalDateStyle(DateFormat.format("yyyy-MM",mCurrentMonth)+ "-" + day))) {
							Utils.callback(uzContext, EVENT_TYPE_SPECIAL,
									mCurrentMonth.get(Calendar.YEAR),
									mCurrentMonth.get(Calendar.MONTH),
									Integer.parseInt(day), Utils.TYPE_ALL,viewId);
						} else {
							Utils.callback(uzContext, EVENT_TYPE_NORMAL,
									mCurrentMonth.get(Calendar.YEAR),
									mCurrentMonth.get(Calendar.MONTH),
									Integer.parseInt(day), Utils.TYPE_ALL,viewId);
						}

						if (mConfig.dateSelectedBitmap != null) {
							backImg.setImageBitmap(mConfig.dateSelectedBitmap);
							daysText.setBackgroundDrawable(null);
						} else {
							daysText.setBackgroundColor(mConfig.dateSelectedBg);
						}
						daysText.setTextColor(mConfig.dateSelectedColor);
						
					}
				}
			});
		}

	}
	
	

	private TextView daysText;
	private String[] days;
	private static final int FIRST_DAY_OF_WEEK = 0;

	public void refreshDays() {

		int lastDay = mCurrentMonth.getActualMaximum(Calendar.DAY_OF_MONTH);
		int firstDay = (int) mCurrentMonth.get(Calendar.DAY_OF_WEEK);

		/**
		 * figure size of the array
		 */
		if (firstDay == 1) {
			days = new String[lastDay + (FIRST_DAY_OF_WEEK * 6)];
		} else {
			days = new String[lastDay + firstDay - (FIRST_DAY_OF_WEEK + 1)];
		}

		int j = FIRST_DAY_OF_WEEK;

		/**
		 * populate empty days before first real day
		 */
		if (firstDay > 1) {
			for (j = 0; j < firstDay - FIRST_DAY_OF_WEEK; j++) {
				days[j] = "";
			}
		} else {
			for (j = 0; j < FIRST_DAY_OF_WEEK * 6; j++) {
				days[j] = "";
			}
			j = FIRST_DAY_OF_WEEK * 6 + 1;
		}

		/**
		 * populate days
		 */
		int dayNumber = 1;
		for (int i = j - 1; i < days.length; i++) {
			days[i] = "" + dayNumber;
			dayNumber++;
		}
	}

	
	private Config mConfig;
	private UZModuleContext moduleContext;
	
	

	public int getViewId() {
		return viewId;
	}

	public void setViewId(int id) {
		this.viewId = id;
	}

	public void init(UZModuleContext moduleContext,ArrayList<SpecicalDateStyle> items, int height, Config config) {
		mDetector = new GestureDetector(getContext(), new MyGestureListener());
		this.mSpecialDateItems = items;
		this.mHeight = height;
		this.mConfig = config;
		new InitTask(moduleContext).execute();
		this.moduleContext = moduleContext;
		
	}

	@Override
	public boolean onTouchEvent(MotionEvent ev) {
		
//		switch(ev.getAction()){
//		case MotionEvent.ACTION_DOWN:
//			Log.i("DEBUG", "=== down : " + downY);
//			break;
//		case MotionEvent.ACTION_MOVE:
//			Log.i("DEBUG", "=== move : " + ev.getY());
//			break;
//		case MotionEvent.ACTION_UP:
//			break;
//		}
		
		if(Config.SWITCH_MODE_NONE.equals(mConfig.switchMode.trim())){
			return super.onTouchEvent(ev);
		} else {
			 // === debug ===
			  mDetector.onTouchEvent(ev);
			  return true;
			 // === debug ===
		}
	}

	public class MyGestureListener extends
			GestureDetector.SimpleOnGestureListener {

		@Override
		public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX,
				float velocityY) {
			
			if(Config.SWITCH_MODE_NONE.equals(mConfig.switchMode.trim())){
				return super.onFling(e1, e2, velocityX, velocityY);
			}

			if (Config.SWITCH_MODE_VERTICAL.equals(mConfig.switchMode.trim())) {
				if (e1.getRawY() - e2.getRawY() > 200) {
					/**
					 * The next month
					 */
					new NextUpdate(moduleContext).execute(Utils.TYPE_SWITCH);
					return true;
				}

				if (e2.getRawY() - e1.getRawY() > 200) {
					/**
					 * The previous month
					 */
					new PreviousUpdate(moduleContext).execute(Utils.TYPE_SWITCH);
					return true;
				}
			}

			if (Config.SWITCH_MODE_HORIZONTAL.equals(mConfig.switchMode.trim())) {
				
				if (e1.getRawX() - e2.getRawX() > 200) {
					/**
					 * The next month
					 */
					new NextUpdate(moduleContext).execute(Utils.TYPE_SWITCH);
					return true;
				}

				if (e2.getRawX() - e1.getRawX() > 200) {
					/**
					 * The previous month
					 */
					new PreviousUpdate(moduleContext).execute(Utils.TYPE_SWITCH);
					return true;
				}

			}
			return super.onFling(e1, e2, velocityX, velocityY);
		}

	}

	public void showNextMonth(UZModuleContext uzContext) {
		NextUpdate nextMonthTask = new NextUpdate(uzContext);
		nextMonthTask.execute(Utils.TYPE_MONTH);
	}

	public void showPreviousMonth(UZModuleContext uzContext) {
		PreviousUpdate previousUpdateTask  = new PreviousUpdate(uzContext);
		previousUpdateTask.setModuleContext(uzContext);
		previousUpdateTask.execute(Utils.TYPE_MONTH);
	}

	private class PreviousUpdate extends AsyncTask<Integer, Void, Void> {

		private int cbType;
		private UZModuleContext uzContext;
		
		public PreviousUpdate(UZModuleContext mContext){
			this.uzContext = mContext;
		}
		
		public void setModuleContext(UZModuleContext uzContext){
			this.uzContext = uzContext;
		}

		@Override
		protected Void doInBackground(Integer... params) {

			if (params != null && params.length > 0) {
				cbType = params[0];
			}

			if (mCurrentMonth.get(Calendar.MONTH) == mCurrentMonth
					.getActualMinimum(Calendar.MONTH)) {
				mCurrentMonth.set((mCurrentMonth.get(Calendar.YEAR) - 1),
						mCurrentMonth.getActualMaximum(Calendar.MONTH), 1);
			} else {
				mCurrentMonth.set(Calendar.MONTH,
						mCurrentMonth.get(Calendar.MONTH) - 1);
			}
			refreshDays();
			mAdapter.setDays(days);
			return null;
		}

		@Override
		protected void onPostExecute(Void result) {

			mAdapter.notifyDataSetChanged();

			if (cbType == Utils.TYPE_MONTH) {
				Utils.callback(uzContext, EVENT_TYPE_SWITCH,
						mCurrentMonth.get(Calendar.YEAR),
						mCurrentMonth.get(Calendar.MONTH),
						mCurrentMonth.get(Calendar.DAY_OF_MONTH),
						Utils.TYPE_MONTH,viewId);
			}

			if (cbType == Utils.TYPE_SWITCH) {
				Utils.callback(uzContext, EVENT_TYPE_SWITCH,
						mCurrentMonth.get(Calendar.YEAR),
						mCurrentMonth.get(Calendar.MONTH),
						mCurrentMonth.get(Calendar.DAY_OF_MONTH),
						Utils.TYPE_SWITCH,viewId);
			}

		}

	}

	/**
	 * next years
	 */
	public void nextYears(UZModuleContext uzContext) {
		
		mCurrentMonth.set(Calendar.YEAR, mCurrentMonth.get(Calendar.YEAR) + 1);
		refreshDays();
		mAdapter.setDays(days);
		mAdapter.notifyDataSetChanged();

		if (uzContext != null) {
			Utils.callback(uzContext, "", mCurrentMonth.get(Calendar.YEAR),
					mCurrentMonth.get(Calendar.MONTH), 0, Utils.TYPE_MONTH,viewId);
		}
		
	}

	/**
	 * previous years
	 */
	public void previousYears(UZModuleContext uzContext) {
		
		mCurrentMonth.set(Calendar.YEAR, mCurrentMonth.get(Calendar.YEAR) - 1);
		refreshDays();
		mAdapter.setDays(days);
		mAdapter.notifyDataSetChanged();

		if (uzContext != null) {
			Utils.callback(uzContext, "", mCurrentMonth.get(Calendar.YEAR),
					mCurrentMonth.get(Calendar.MONTH), 0, Utils.TYPE_MONTH,viewId);
		}

	}

	private class NextUpdate extends AsyncTask<Integer, Void, Void> {

		private int cbType;
		private UZModuleContext uzContext;
		
		public NextUpdate(UZModuleContext mContext){
			this.uzContext = mContext;
		}

		@Override
		protected Void doInBackground(Integer... params) {

			if (params != null && params.length > 0) {
				cbType = params[0];
			}

			if (mCurrentMonth.get(Calendar.MONTH) == mCurrentMonth
					.getActualMaximum(Calendar.MONTH)) {
				mCurrentMonth.set((mCurrentMonth.get(Calendar.YEAR) + 1),
						mCurrentMonth.getActualMinimum(Calendar.MONTH), 1);
			} else {
				mCurrentMonth.set(Calendar.MONTH,
						mCurrentMonth.get(Calendar.MONTH) + 1);
			}
			refreshDays();
			mAdapter.setDays(days);
			return null;
		}

		@Override
		protected void onPostExecute(Void result) {
			mAdapter.notifyDataSetChanged();

			if (cbType == Utils.TYPE_MONTH) {
				Utils.callback(uzContext, EVENT_TYPE_SWITCH,
						mCurrentMonth.get(Calendar.YEAR),
						mCurrentMonth.get(Calendar.MONTH),
						mCurrentMonth.get(Calendar.DAY_OF_MONTH),
						Utils.TYPE_MONTH,viewId);
			}
			
			if (cbType == Utils.TYPE_SWITCH) {
				Utils.callback(uzContext, EVENT_TYPE_SWITCH,
						mCurrentMonth.get(Calendar.YEAR),
						mCurrentMonth.get(Calendar.MONTH),
						mCurrentMonth.get(Calendar.DAY_OF_MONTH),
						Utils.TYPE_SWITCH,viewId);
			}

		}

	}

	@SuppressWarnings("deprecation")
	private void refreshView() {
		if (daysText != null) {
			String date = daysText.getText().toString();
			if (date.length() == 1) {
				date = "0" + date;
			}
			View view = mCalendarGrid.getChildAt(currentIndex);
			if (view != null) {
				if (date.length() > 0&& mSpecialDateItems != null&& mSpecialDateItems.contains(android.text.format.DateFormat.format("yyyy-MM", mCurrentMonth)+ "-"+ date)) {
					daysText.setBackgroundDrawable(new BitmapDrawable(mSpecialBgBmp));
				} else {
					daysText.setBackgroundDrawable(null);
				}
			}
		}
	}

	private Calendar todayCalendar = Calendar.getInstance();

	@SuppressWarnings("deprecation")
	public void resetAllDayBg() {
		for (int i = 0; i < mCalendarGrid.getChildCount(); i++) {
			int textId = UZResourcesIDFinder.getResIdID("date");
			TextView tmpTxt = (TextView) (mCalendarGrid.getChildAt(i)
					.findViewById(textId));

			tmpTxt.setTextColor(mConfig.dateColor);
			tmpTxt.setBackgroundDrawable(null);

			int backImgId = UZResourcesIDFinder.getResIdID("backImg");
			ImageView backImg = (ImageView) (mCalendarGrid.getChildAt(i).findViewById(backImgId));
			backImg.setImageBitmap(null);

			if (i % 7 == 0) {
				tmpTxt.setTextColor(mConfig.weekendColor);
			}

			if (i % 7 == 6) {
				tmpTxt.setTextColor(mConfig.weekendColor);
			}

			if (!TextUtils.isEmpty(tmpTxt.getText())) {
				if (mCurrentMonth.get(Calendar.YEAR) == todayCalendar
						.get(Calendar.YEAR)
						&& mCurrentMonth.get(Calendar.MONTH) == todayCalendar
								.get(Calendar.MONTH)
						&& Integer.parseInt(tmpTxt.getText().toString()) == todayCalendar
								.get(Calendar.DAY_OF_MONTH) && mConfig.showTodayStyle) {
					tmpTxt.setTextColor(mConfig.todayColor);
					if (mConfig.todayBitmap != null) {
						backImg.setImageBitmap(mConfig.todayBitmap);
						tmpTxt.setBackgroundDrawable(null);
					} else {
						tmpTxt.setBackgroundColor(mConfig.todayBg);
					}
				}
			}

			String day = tmpTxt.getText().toString();
			if (day.length() == 1) {
				day = "0" + day;
			}

			if (day.length() > 0
					&& mSpecialDateItems != null
					&& mSpecialDateItems
							.contains(new SpecicalDateStyle( android.text.format.DateFormat.format(
									"yyyy-MM", mCurrentMonth) + "-" + day))) {
				
				
				tmpTxt.setTextColor(mConfig.specialDateColor);
				
				if (mConfig.specialDateBgBitmap != null) {
					backImg.setImageBitmap(mConfig.specialDateBgBitmap);
					tmpTxt.setBackgroundDrawable(null);
				} else {
					tmpTxt.setBackgroundColor(mConfig.specialDateBg);
				}
				
				
				tmpTxt.setTextColor(mConfig.specialDateColor);
				
				String curDateStr = android.text.format.DateFormat.format(
						"yyyy-MM", mCurrentMonth) + "-" + day;
				SpecicalDateStyle curSpecialDate = getCurrentSpecialDate(
						curDateStr, mSpecialDateItems);
				
				
				if (curSpecialDate != null && curSpecialDate.hasBg) {
					if (curSpecialDate.bg != null) {

						backImg.setImageBitmap(curSpecialDate.bg);
						tmpTxt.setBackgroundDrawable(null);

					} else {
						tmpTxt.setBackgroundColor(curSpecialDate.bgColor);
					}
				}

				if (curSpecialDate != null && curSpecialDate.hasTextColor) {
					tmpTxt.setTextColor(curSpecialDate.color);
				}
			}
			if (!TextUtils.isEmpty(tmpTxt.getText().toString().trim()) && !canClick(tmpTxt.getText().toString().trim())) {
				tmpTxt.setTextColor(Color.GRAY);
			}
		}
	}

	public SpecicalDateStyle getCurrentSpecialDate(String dateText,
			ArrayList<SpecicalDateStyle> dateList) {

		if (TextUtils.isEmpty(dateText)) {
			return null;
		}

		for (SpecicalDateStyle style : dateList) {
			if (dateText.equals(style.dateText)) {
				return style;
			}
		}

		return null;
	}

	private int currentIndex;

	public void setConfig(Config config) {
		this.mConfig = config;
	}

	@SuppressLint("SimpleDateFormat")
	public void setDate(String date, final UZModuleContext uzContext, final boolean ignoreSelected) {

		final String[] timeArr = date.split("-");
		if (timeArr.length < 3) {
			return;
		}
		
		
		if (isNumeric(timeArr[0]) && isNumeric(timeArr[1])
				&& isNumeric(timeArr[2])) {
			mCurrentMonth.set(Integer.parseInt(timeArr[0]),
					Integer.parseInt(timeArr[1]) - 1, 1);
			refreshDays();
			mAdapter.setDays(days);
			mAdapter.notifyDataSetChanged();
			
			if (mConfig.multipleSelect) {
				
				mAdapter.changeCurrentDay(timeArr[2]);
			}else{
				mAdapter.oneCurrentDay(timeArr[2]);
				mAdapter.setCurrentYear(mCurrentMonth.get(Calendar.YEAR));
				mAdapter.setCurrentMonth(mCurrentMonth.get(Calendar.MONTH));
			}
			
//			if(mConfig.multipleSelect){
//				selectedDays.add(day);
////				selectedDays.add(today);
//			}
		}
		
		new Handler().postDelayed(new Runnable() {

			@SuppressWarnings("deprecation")
			@Override
			public void run() {
				for (int i = 0; i < mCalendarGrid.getChildCount(); i++) {

					View view = mCalendarGrid.getChildAt(i);
					int txtId = UZResourcesIDFinder.getResIdID("date");
					TextView tmpTxt = (TextView) view.findViewById(txtId);

					int backImgId = UZResourcesIDFinder.getResIdID("backImg");
					ImageView backImg = (ImageView) view
							.findViewById(backImgId);

					if (view != null) {

						tmpTxt.setBackgroundDrawable(null);
						backImg.setImageBitmap(null);
						tmpTxt.setTextColor(mConfig.dateColor);
						if (i % 7 == 0) {
							tmpTxt.setTextColor(mConfig.weekendColor);
						}

						if (i % 7 == 6) {
							tmpTxt.setTextColor(mConfig.weekendColor);
						}

						if (!TextUtils.isEmpty(tmpTxt.getText())) {
							if (mCurrentMonth.get(Calendar.YEAR) == todayCalendar
									.get(Calendar.YEAR)
									&& mCurrentMonth.get(Calendar.MONTH) == todayCalendar
											.get(Calendar.MONTH)
									&& Integer.parseInt(tmpTxt.getText()
											.toString()) == todayCalendar
											.get(Calendar.DAY_OF_MONTH) && mConfig.showTodayStyle) {

								tmpTxt.setTextColor(mConfig.todayColor);
								if (mConfig.todayBitmap != null) {
									backImg.setImageBitmap(mConfig.todayBitmap);
									tmpTxt.setBackgroundDrawable(null);
								} else {
									tmpTxt.setBackgroundColor(mConfig.todayBg);
								}
							}
						}

						String day = tmpTxt.getText().toString();
						if (day.length() == 1) {
							day = "0" + day;
						}
						if (day.length() > 0
								&& mSpecialDateItems != null
								&& mSpecialDateItems
										.contains( new SpecicalDateStyle(DateFormat.format("yyyy-MM",mCurrentMonth)+ "-" + day)) ) {
							
							tmpTxt.setTextColor(mConfig.specialDateColor);
							if (mConfig.specialDateBgBitmap != null) {
								backImg.setImageBitmap(mConfig.specialDateBgBitmap);
								tmpTxt.setBackgroundDrawable(null);
							} else {
								tmpTxt.setBackgroundColor(mConfig.specialDateBg);
							}
							tmpTxt.setTextColor(mConfig.specialDateColor);
							
							String curDateStr = android.text.format.DateFormat.format("yyyy-MM", mCurrentMonth) + "-" + day;
							SpecicalDateStyle curSpecialDate = getCurrentSpecialDate(curDateStr, mSpecialDateItems);
							
							if (curSpecialDate != null && curSpecialDate.hasBg) {
								if (curSpecialDate.bg != null) {

									backImg.setImageBitmap(curSpecialDate.bg);
									tmpTxt.setBackgroundDrawable(null);

								} else {
									tmpTxt.setBackgroundColor(curSpecialDate.bgColor);
								}
							}
							
							if(curSpecialDate != null && curSpecialDate.hasTextColor){
								tmpTxt.setTextColor(curSpecialDate.color);
							}
							
						}

						if (!TextUtils.isEmpty(timeArr[2])
								&& (Integer.parseInt(timeArr[2]) + "")
										.equals(tmpTxt.getText().toString()) && !ignoreSelected) {

							if (mConfig.dateSelectedBitmap != null) {
								backImg.setImageBitmap(mConfig.dateSelectedBitmap);
								tmpTxt.setBackgroundDrawable(null);
							} else {
								tmpTxt.setBackgroundColor(mConfig.dateSelectedBg);
							}
							tmpTxt.setTextColor(mConfig.dateSelectedColor);

						}
						//不可点击
						if (!TextUtils.isEmpty(day.trim()) && !canClick(day)) {
							tmpTxt.setClickable(false);
							tmpTxt.setTextColor(Color.GRAY);
						}
					}
					
				}

				JSONObject ret = new JSONObject();
				try {
					ret.put("status", true);
				} catch (JSONException e) {
					e.printStackTrace();
				}
				uzContext.success(ret, false);
			}
		}, 300);
	}

	public boolean isToday(String day) {

		if (mCurrentMonth.get(Calendar.YEAR) == todayCalendar
				.get(Calendar.YEAR)
				&& mCurrentMonth.get(Calendar.MONTH) == todayCalendar
						.get(Calendar.MONTH)
				&& Integer.parseInt(day) == todayCalendar
						.get(Calendar.DAY_OF_MONTH)) {
			return true;
		}
		return false;
	}

	public boolean isSpecialDay(String day) {
		if (day.length() > 0
				&& mSpecialDateItems != null
				&& mSpecialDateItems.contains(android.text.format.DateFormat
						.format("yyyy-MM", mCurrentMonth) + "-" + day)) {
			return true;
		}
		return false;
	}
	
	public static boolean isNumeric(String str) {
		for (int i = 0; i < str.length(); i++) {
			if (!Character.isDigit(str.charAt(i))) {
				return false;
			}
		}
		return true;
	}

	
	public void removeSpecialDates(String[] dates){
		
		if(dates == null){
			return;
		}
		
		for(int i=0; i< dates.length; i++){
			for(int j=0; j<mSpecialDateItems.size(); j++){
				if(mSpecialDateItems.get(j).dateText.equals(dates[i])){
					mSpecialDateItems.remove(j);
				}
			}
		}
		
		refreshDays();
		if(mAdapter != null){
			mAdapter.notifyDataSetChanged();
		}
		
	}
	//是否可点击
	private boolean canClick(String day) {
		if (TextUtils.isEmpty(day)) {
			return false;
		}
		Calendar nowCalendar = Calendar.getInstance();
		nowCalendar.set(mCurrentMonth.get(Calendar.YEAR), mCurrentMonth.get(Calendar.MONTH), Integer.parseInt(day));
		//后面月份以后不可点击，并刷新背景
//		if (!mConfig.isAfterChose() && todayCalendar.before(nowCalendar)) {
////			refreshView();
////			resetAllDayBg();
//			return false;
//		}
//		//前面月份不可点击，并刷新背景
//		if (!mConfig.isBeforeChose() && todayCalendar.after(nowCalendar)) {
////			refreshView();
////			resetAllDayBg();
//			return false;
//		}
		//当月，当前以前不可点击
		if (todayCalendar.get(Calendar.YEAR) == nowCalendar.get(Calendar.YEAR) && todayCalendar.get(Calendar.MONTH) == nowCalendar.get(Calendar.MONTH)) {
			//当月大于当天不可选
			if (!mConfig.isAfterChose() && Integer.parseInt(day)>todayCalendar.get(Calendar.DAY_OF_MONTH)) {
				return false;
			}
			//当月小于当天不可选
			if (!mConfig.isBeforeChose() && Integer.parseInt(day)<todayCalendar.get(Calendar.DAY_OF_MONTH)) {
				return false;
			}
		}else{
			if (!mConfig.isAfterChose() && todayCalendar.before(nowCalendar)) {
				return false;
			}
			//当月小于当天不可选
			if (!mConfig.isBeforeChose() && todayCalendar.after(nowCalendar)) {
				return false;
			}
		}
		return true;
	}
}
