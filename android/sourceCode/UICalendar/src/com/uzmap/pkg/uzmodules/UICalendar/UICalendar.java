/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
package com.uzmap.pkg.uzmodules.UICalendar;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.json.JSONArray;
import org.json.JSONObject;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.text.TextUtils;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.RelativeLayout.LayoutParams;

import com.uzmap.pkg.uzcore.UZResourcesIDFinder;
import com.uzmap.pkg.uzcore.UZWebView;
import com.uzmap.pkg.uzcore.uzmodule.UZModule;
import com.uzmap.pkg.uzcore.uzmodule.UZModuleContext;
import com.uzmap.pkg.uzkit.UZUtility;

public class UICalendar extends UZModule {

	private CalendarView mCalendarView;

	public static final String TAG = CalendarView.class.getSimpleName();

	public UICalendar(UZWebView webView) {
		super(webView);
	}

	private Config config;

	@SuppressWarnings("deprecation")
	public void jsmethod_open(UZModuleContext uzContext) {

		config = new Config(uzContext, getWidgetInfo(), getContext());

		LayoutParams parms = new LayoutParams(config.w, config.h);
		parms.setMargins(config.x, config.y, 0, 0);

		if (mCalendarView == null) {
			mCalendarView = initView(uzContext, config.specialDateList,
					config.w, config.h, config);
		} else {
			removeViewFromCurWindow(mCalendarView);
			mCalendarView = initView(uzContext, config.specialDateList,
					config.w, config.h, config);
			RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(
					config.w, config.h);
			mCalendarView.setLayoutParams(params);
		}

		mCalendarView.setConfig(config);

		if (config.bgBitmap != null) {
			mCalendarView.setBackgroundDrawable(new BitmapDrawable(
					config.bgBitmap));
		} else {
			mCalendarView.setBackgroundColor(config.bg);
		}
		
		insertViewToCurWindow(mCalendarView, parms, config.fixedOn,
				config.fixed);
	}

	private CalendarView initView(UZModuleContext uzContext,
			ArrayList<SpecicalDateStyle> specialDates, int width, int height,
			Config config) {

		int calendarId = UZResourcesIDFinder
				.getResLayoutID("mo_uicalendar_view_layout");
		CalendarView calanderView = (CalendarView) View.inflate(mContext,
				calendarId, null);
		LinearLayout.LayoutParams params = new android.widget.LinearLayout.LayoutParams(
				width, height);
		calanderView.setLayoutParams(params);
		calanderView.init(uzContext, specialDates, UZUtility.dipToPix(height),
				config);

		return calanderView;
	}

	public void jsmethod_nextMonth(UZModuleContext uzContext) {
		if (mCalendarView != null) {
			mCalendarView.showNextMonth(uzContext);
		}
	}

	public void jsmethod_prevMonth(UZModuleContext uzContext) {
		if (mCalendarView != null) {
			mCalendarView.showPreviousMonth(uzContext);
		}
	}

	public void jsmethod_nextYear(UZModuleContext uzContext) {
		if (mCalendarView != null) {
			mCalendarView.nextYears(uzContext);
		}
	}

	public void jsmethod_prevYear(UZModuleContext uzContext) {
		if (mCalendarView != null) {
			mCalendarView.previousYears(uzContext);
		}
	}

	public void jsmethod_close(UZModuleContext uzContext) {
		removeViewFromCurWindow(mCalendarView);
		mCalendarView = null;
	}

	public void jsmethod_hide(UZModuleContext uzContext) {
		if (mCalendarView != null) {
			mCalendarView.setVisibility(View.GONE);
		}
	}

	public void jsmethod_show(UZModuleContext uzContext) {
		if (mCalendarView != null) {
			mCalendarView.setVisibility(View.VISIBLE);
		}
	}

	public void jsmethod_setDate(UZModuleContext uzContext) {
		String dateText = uzContext.optString("date");
		boolean ignoreSelected = uzContext.optBoolean("ignoreSelected");

		if (!TextUtils.isEmpty(dateText)) {
			mCalendarView.setDate(dateText, uzContext, ignoreSelected);
		} else {
			Calendar calendar = Calendar.getInstance();
			int year = calendar.get(Calendar.YEAR);
			int month = calendar.get(Calendar.MONTH) + 1;
			int day = calendar.get(Calendar.DAY_OF_MONTH);

			String currentDate = year + "-" + month + "-" + day;
			mCalendarView.setDate(currentDate, uzContext, ignoreSelected);

		}
	}

	public void jsmethod_setSpecialDates(UZModuleContext uzContext) {

		JSONArray specialDates = uzContext.optJSONArray("specialDates");
		if (specialDates != null) {
			for (int i = 0; i < specialDates.length(); i++) {

				JSONObject styleObj = specialDates.optJSONObject(i);

				SpecicalDateStyle styleItem = parseStyle(styleObj);

				if (!config.specialDateList.contains(styleItem)) {
					config.specialDateList.add(styleItem);
				} else {
					SpecicalDateStyle tmp = findSpecialDate(
							config.specialDateList, styleObj.optString("date"));
					setSpecialStyle(tmp, styleItem);
				}
				
				if (mCalendarView != null) {
					mCalendarView.setSpecialDates(config.specialDateList);
				}
			}
		}
	}

	public void setSpecialStyle(SpecicalDateStyle oldStyle,
			SpecicalDateStyle newStyle) {

		if (oldStyle == null || newStyle == null) {
			return;
		}

		oldStyle.bg = newStyle.bg;
		oldStyle.bgColor = newStyle.bgColor;
		if (newStyle.hasBg) {
			oldStyle.hasBg = true;
		}

		if (newStyle.hasTextColor) {
			oldStyle.color = newStyle.color;
		}
	}

	public SpecicalDateStyle parseStyle(JSONObject styleObj) {

		SpecicalDateStyle eStyle = new SpecicalDateStyle(
				Utils.correctDate(styleObj.optString("date")));

		if (!styleObj.isNull("bg")
				&& !TextUtils.isEmpty(styleObj.optString("bg"))) {

			eStyle.hasBg = true;
			Bitmap bgBitmap = getBitmap(styleObj.optString("bg"));
			if (bgBitmap != null) {
				eStyle.bg = bgBitmap;
			} else {
				eStyle.bgColor = UZUtility.parseCssColor(styleObj
						.optString("bg"));
			}

		}

		if (!styleObj.isNull("color")
				&& !TextUtils.isEmpty(styleObj.optString("color"))) {

			eStyle.color = UZUtility.parseCssColor(styleObj.optString("color"));
			eStyle.hasTextColor = true;

		}

		return eStyle;
	}

	public SpecicalDateStyle findSpecialDate(
			ArrayList<SpecicalDateStyle> specialDateList, String date) {

		if (specialDateList == null || TextUtils.isEmpty(date)) {
			return null;
		}

		for (SpecicalDateStyle sDt : specialDateList) {
			if (date.equals(sDt.dateText)) {
				return sDt;
			}
		}

		return null;

	}

	public Bitmap getBitmap(String path) {

		if (TextUtils.isEmpty(path)) {
			return null;
		}

		String realPath = UZUtility.makeRealPath(path, this.getWidgetInfo());

		try {
			InputStream input = UZUtility.guessInputStream(realPath);
			Bitmap bitmap = BitmapFactory.decodeStream(input);
			if (input != null) {
				input.close();
			}
			return bitmap;
		} catch (IOException e) {
			e.printStackTrace();
		}
		return null;
	}

	public void jsmethod_cancelSpecialDates(UZModuleContext uzContext) {
		JSONArray specialDatesArray = uzContext.optJSONArray("specialDates");
		String[] datesArr = null;
		if (specialDatesArray != null) {
			datesArr = new String[specialDatesArray.length()];
			for (int i = 0; i < specialDatesArray.length(); i++) {
				datesArr[i] = Utils.correctDate(specialDatesArray.optString(i));
			}
		}

		if (mCalendarView != null) {
			mCalendarView.removeSpecialDates(datesArr);
		}

	}
	
	public void jsmethod_turnPage(UZModuleContext uzContext){
		String dateText = verifyDate(uzContext.optString("date"));

		if (!TextUtils.isEmpty(dateText)) {
			mCalendarView.setDate(dateText, uzContext, true);
		} else {
			
			Calendar calendar = Calendar.getInstance();
			int year = calendar.get(Calendar.YEAR);
			int month = calendar.get(Calendar.MONTH) + 1;
			int day = calendar.get(Calendar.DAY_OF_MONTH);

			String currentDate = year + "-" + month + "-" + day;
			mCalendarView.setDate(currentDate, uzContext, true);

		}
	}
	
	public String verifyDate(String date){
		
		Pattern pattern = Pattern.compile("\\d{4}-\\d{1,2}");
		Matcher matcher = pattern.matcher(date);
		if(matcher.matches()){
			return date + "-01";
		}
		return date;
		
	}
}
