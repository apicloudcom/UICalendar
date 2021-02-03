/*
 * Copyright 2011 Lauri Nevala.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.uzmap.pkg.uzmodules.UICalendar;

import java.io.File;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

import com.uzmap.pkg.uzcore.UZResourcesIDFinder;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Color;

import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.RelativeLayout.LayoutParams;
import android.widget.TextView;

@SuppressLint("NewApi")
public class GridAdapter extends BaseAdapter {

	private Context mContext;

	private Calendar mMonth;
	private Calendar mSelectedDate;
	private ArrayList<SpecicalDateStyle> mSpecialDates;
	private GridView mGrid;

	@SuppressWarnings("unused")
	private String mSelectedDateTxt;

	private TextView tv_sun;
	private TextView tv_mon;
	private TextView tv_tue;
	private TextView tv_wed;
	private TextView tv_thurs;
	private TextView tv_fri;
	private TextView tv_sat;

	public void setDays(String[] days) {
		this.days = days;
	}

	static class ViewHolder {

		TextView tv_day;
		ImageView backImg;

	}

	public void setMonth(Calendar month) {
		this.mMonth = month;
	}

	public void setSelectedDateTxt(String selectedDateTxt) {
		this.mSelectedDateTxt = selectedDateTxt;
	}

	@SuppressLint("SimpleDateFormat")
	public GridAdapter(Context c, Calendar monthCalendar, GridView gridview, int height, LinearLayout linearLayout) {
		// android
		mMonth = monthCalendar;
		mSelectedDate = Calendar.getInstance();

		mContext = c;
		this.mGrid = gridview;

		initView(linearLayout);
		this.mSpecialDates = new ArrayList<SpecicalDateStyle>();
	}

	private void initView(LinearLayout linearLayout) {

		int tv_sunID = UZResourcesIDFinder.getResIdID("tv_sun");
		tv_sun = (TextView) linearLayout.findViewById(tv_sunID);

		int tv_monID = UZResourcesIDFinder.getResIdID("tv_mon");
		tv_mon = (TextView) linearLayout.findViewById(tv_monID);

		int tv_tueID = UZResourcesIDFinder.getResIdID("tv_tue");
		tv_tue = (TextView) linearLayout.findViewById(tv_tueID);

		int tv_wedID = UZResourcesIDFinder.getResIdID("tv_wed");
		tv_wed = (TextView) linearLayout.findViewById(tv_wedID);

		int tv_thursID = UZResourcesIDFinder.getResIdID("tv_thurs");
		tv_thurs = (TextView) linearLayout.findViewById(tv_thursID);

		int tv_friID = UZResourcesIDFinder.getResIdID("tv_fri");
		tv_fri = (TextView) linearLayout.findViewById(tv_friID);

		int tv_satID = UZResourcesIDFinder.getResIdID("tv_sat");
		tv_sat = (TextView) linearLayout.findViewById(tv_satID);

	}
	

	public void setItems(ArrayList<SpecicalDateStyle> items) {
		if (items == null) {
			return;
		}
		this.mSpecialDates = items;
	}

	public int getCount() {
		return days.length;
	}

	public Object getItem(int position) {
		return null;
	}

	public long getItemId(int position) {
		return 0;
	}

	@SuppressWarnings("deprecation")
	public View getView(int position, View convertView, ViewGroup parent) {

		View view;
		ViewHolder viewHold;
		if (convertView == null) {
			LayoutInflater vi = (LayoutInflater) mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
			int layoutID = UZResourcesIDFinder.getResLayoutID("mo_calendar_calendar_item");
			view = vi.inflate(layoutID, null);
			viewHold = new ViewHolder();
			int dateID = UZResourcesIDFinder.getResIdID("date");
			viewHold.tv_day = (TextView) view.findViewById(dateID);

			int backImgId = UZResourcesIDFinder.getResIdID("backImg");
			viewHold.backImg = (ImageView) view.findViewById(backImgId);

			view.setTag(viewHold);
		} else {
			view = convertView;
			viewHold = (ViewHolder) view.getTag();
		}

		viewHold.tv_day.destroyDrawingCache();
		int height = mGrid.getHeight() / 6;
		LayoutParams lp = new LayoutParams(-1, height);
		lp.addRule(RelativeLayout.CENTER_IN_PARENT, RelativeLayout.TRUE);
		viewHold.tv_day.setLayoutParams(lp);
		viewHold.backImg.setLayoutParams(lp);

		tv_mon.setTextSize(mConfig.weekSize);
		tv_tue.setTextSize(mConfig.weekSize);
		tv_wed.setTextSize(mConfig.weekSize);
		tv_thurs.setTextSize(mConfig.weekSize);
		tv_fri.setTextSize(mConfig.weekSize);

		tv_sun.setTextSize(mConfig.weekSize);
		tv_sat.setTextSize(mConfig.weekSize);

		tv_mon.setTextColor(mConfig.weekdayColor);
		tv_tue.setTextColor(mConfig.weekdayColor);
		tv_wed.setTextColor(mConfig.weekdayColor);
		tv_thurs.setTextColor(mConfig.weekdayColor);
		tv_fri.setTextColor(mConfig.weekdayColor);
		tv_sun.setTextColor(mConfig.weekendColor);
		tv_sat.setTextColor(mConfig.weekendColor);

		viewHold.tv_day.setTextSize(mConfig.dateSize);
		viewHold.tv_day.setTextColor(mConfig.dateColor);

		if (days[position].equals("")) {
			viewHold.tv_day.setClickable(false);
			viewHold.tv_day.setFocusable(false);
		}

		// android_modules
		viewHold.tv_day.setText(days[position]);
		String date = days[position];

		if (date.length() == 1) {
			date = "0" + date;
		}
		String monthStr = "" + (mMonth.get(Calendar.MONTH) + 1);
		if (monthStr.length() == 1) {
			monthStr = "0" + monthStr;
		}

		viewHold.tv_day.setBackgroundDrawable(null);
		viewHold.backImg.setImageBitmap(null);
		viewHold.tv_day.setTextColor(mConfig.dateColor);

		if (position % 7 == 0) {
			viewHold.tv_day.setTextColor(mConfig.weekendColor);
		}

		if (position % 7 == 6) {
			viewHold.tv_day.setTextColor(mConfig.weekendColor);
		}
		
		// Today
		if (mMonth.get(Calendar.YEAR) == mSelectedDate.get(Calendar.YEAR) && mMonth.get(Calendar.MONTH) == mSelectedDate.get(Calendar.MONTH)
				&& days[position].equals("" + mSelectedDate.get(Calendar.DAY_OF_MONTH)) && mConfig.showTodayStyle) {
			if (mConfig.todayBitmap != null) {
				viewHold.backImg.setImageBitmap(mConfig.todayBitmap);
				viewHold.tv_day.setBackgroundDrawable(null);
			} else {
				viewHold.tv_day.setBackgroundColor(mConfig.todayBg);
			}
			viewHold.tv_day.setTextColor(mConfig.todayColor);
		}
		
		// Other Special Day
		if (date.length() > 0 && mSpecialDates != null && mSpecialDates.contains(new SpecicalDateStyle(android.text.format.DateFormat.format("yyyy-MM", mMonth) + "-" + date))) {

			if (mConfig.specialDateBgBitmap != null) {
				viewHold.backImg.setImageBitmap(mConfig.specialDateBgBitmap);
				viewHold.tv_day.setBackgroundDrawable(null);
			} else {
				viewHold.tv_day.setBackgroundColor(mConfig.specialDateBg);
			}

			viewHold.tv_day.setTextColor(mConfig.specialDateColor);

			String curDateStr = android.text.format.DateFormat.format("yyyy-MM", mMonth) + "-" + date;
			SpecicalDateStyle curSpecialDate = getCurrentSpecialDate(curDateStr, mSpecialDates);

			if (curSpecialDate != null && curSpecialDate.hasBg) {
				if (curSpecialDate.bg != null) {

					viewHold.backImg.setImageBitmap(curSpecialDate.bg);
					viewHold.tv_day.setBackgroundDrawable(null);

				} else {
					viewHold.tv_day.setBackgroundColor(curSpecialDate.bgColor);
				}
			}

			if (curSpecialDate != null && curSpecialDate.hasTextColor) {
				viewHold.tv_day.setTextColor(curSpecialDate.color);
			}

		}

		// if(position == mCurrentIndex){
		//
		// if (mConfig.dateSelectedBitmap != null) {
		// viewHold.backImg.setImageBitmap(mConfig.dateSelectedBitmap);
		// viewHold.tv_day.setBackgroundDrawable(null);
		// } else {
		// viewHold.tv_day.setBackgroundColor(mConfig.dateSelectedBg);
		// }
		// viewHold.tv_day.setTextColor(mConfig.dateSelectedColor);
		// }

		for (int i = 0; i < mCurrentList.size(); i++) {
			String current = mCurrentList.get(i);
			
			//单选判断年月
			if (currentYear != -1 && currentMonth != -1) {
				if (mMonth.get(Calendar.YEAR)!=currentYear || mMonth.get(Calendar.MONTH) != currentMonth) {
					continue;
				}
			}
			
			if (!TextUtils.isEmpty(current) && current.equals(viewHold.tv_day.getText())) {
				if (mConfig.dateSelectedBitmap != null) {
					viewHold.backImg.setImageBitmap(mConfig.dateSelectedBitmap);
					viewHold.tv_day.setBackgroundDrawable(null);
				} else {
					viewHold.tv_day.setBackgroundColor(mConfig.dateSelectedBg);
				}
				viewHold.tv_day.setTextColor(mConfig.dateSelectedColor);
			}
		}
		
		//不可点击
		if (!TextUtils.isEmpty(days[position].trim()) && !canClick(days[position])) {
			viewHold.tv_day.setClickable(false);
			viewHold.tv_day.setTextColor(Color.GRAY);
		}

		return view;
	}

	public int mCurrentIndex = -1;
	public List<String> mCurrentList = new ArrayList<String>();
	public int currentYear = -1;
	public int currentMonth = -1;
	
	public void setCurrentYear(int year){
		this.currentYear = year;
	}
	
	public void setCurrentMonth(int month){
		this.currentMonth = month;
	}

	public void setCurrentIndex(int curIndex) {
		this.mCurrentIndex = curIndex;
	}

	//添加选中日期
	public void addCurrentDay(String curDay){
		if (mCurrentList.contains(curDay)) {
			return;
		}
		mCurrentList.add(curDay);
	}
	public void removeCurrentDay(String delDay){
		for (int i = 0; i < mCurrentList.size(); i++) {
			if (TextUtils.equals(delDay, mCurrentList.get(i))) {
				mCurrentList.remove(i);
			}
		}
	}
	
	public void changeCurrentDay(String day){
		for (int i = 0; i < mCurrentList.size(); i++) {
			if (TextUtils.equals(day, mCurrentList.get(i))) {
				mCurrentList.remove(i);
				return;
			}
		}
		mCurrentList.add(day);
	}
	
	public void oneCurrentDay(String day){
		mCurrentList.clear();
		mCurrentList.add(day);
	}

	public Calendar getMonth() {
		return this.mMonth;
	}

	public int px2sp(float pxValue) {
		final float fontScale = mContext.getResources().getDisplayMetrics().scaledDensity;
		return (int) (pxValue / fontScale + 0.5f);
	}

	public int sp2px(float spValue) {
		final float fontScale = mContext.getResources().getDisplayMetrics().scaledDensity;
		return (int) (spValue * fontScale + 0.5f);
	}

	public int dip2px(float dipValue) {
		final float scale = mContext.getResources().getDisplayMetrics().density;
		return (int) (dipValue * scale + 0.5f);
	}

	public String[] days;
	private Config mConfig;

	public void setConfig(Config config) {
		this.mConfig = config;
	}

	public SpecicalDateStyle getCurrentSpecialDate(String dateText, ArrayList<SpecicalDateStyle> dateList) {

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
	
	//是否可点击
		private boolean canClick(String day) {
			Calendar nowCalendar = Calendar.getInstance();
			
			nowCalendar.set(mMonth.get(Calendar.YEAR), mMonth.get(Calendar.MONTH), Integer.parseInt(day));
			//后面月份以后不可点击，并刷新背景
//			if (!mConfig.isAfterChose() && mSelectedDate.before(nowCalendar)) {
////				refreshView();
////				resetAllDayBg();
//				return false;
//			}
//			//前面月份不可点击，并刷新背景
//			if (!mConfig.isBeforeChose() && mSelectedDate.after(nowCalendar)) {
////				refreshView();
////				resetAllDayBg();
//				return false;
//			}
//			当月，当前以前不可点击
			if (mSelectedDate.get(Calendar.YEAR) == nowCalendar.get(Calendar.YEAR) && mSelectedDate.get(Calendar.MONTH) == nowCalendar.get(Calendar.MONTH)) {
				//当月大于当天不可选
				if (!mConfig.isAfterChose() && Integer.parseInt(day)>mSelectedDate.get(Calendar.DAY_OF_MONTH)) {
					return false;
				}
				//当月小于当天不可选
				if (!mConfig.isBeforeChose() && Integer.parseInt(day)<mSelectedDate.get(Calendar.DAY_OF_MONTH)) {
					return false;
				}
			}else{
				if (!mConfig.isAfterChose() && mSelectedDate.before(nowCalendar)) {
					return false;
				}
				//当月小于当天不可选
				if (!mConfig.isBeforeChose() && mSelectedDate.after(nowCalendar)) {
					return false;
				}
			}
			return true;
		}

}