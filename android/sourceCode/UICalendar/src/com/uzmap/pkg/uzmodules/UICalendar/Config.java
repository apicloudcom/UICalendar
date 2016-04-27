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

import org.json.JSONArray;
import org.json.JSONObject;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.text.TextUtils;

import com.uzmap.pkg.uzcore.UZCoreUtil;
import com.uzmap.pkg.uzcore.uzmodule.UZModuleContext;
import com.uzmap.pkg.uzkit.UZUtility;
import com.uzmap.pkg.uzkit.data.UZWidgetInfo;

public class Config {

	public static final String SWITCH_MODE_VERTICAL = "vertical";
	public static final String SWITCH_MODE_HORIZONTAL = "horizontal";
	public static final String SWITCH_MODE_NONE = "none";

	public int x = 0;
	public int y = 0;

	public int w = 320;
	public int h = 280;

	public int bg = 0x00000000;
	public Bitmap bgBitmap;

	public int weekdayColor = 0xFF3b3b3b;
	public int weekendColor = 0xFFa8d400;
	public int weekSize = 24;

	public int dateColor = 0xFF3b3b3b;
	public int dateSelectedColor = 0xFFFFFFFF;
	public int dateSelectedBg = 0xFFa8d500;
	public Bitmap dateSelectedBitmap;
	public int dateSize = 24;

	public int todayColor = 0xFFa8d500;
	public int todayBg;
	public Bitmap todayBitmap;

	public int specialDateColor = 0xFF3b3b3b;
	public int specialDateBg = 0xFFa8d500;
	public Bitmap specialDateBgBitmap;

	public ArrayList<SpecicalDateStyle> specialDateList = new ArrayList<SpecicalDateStyle>();
	public String switchMode = SWITCH_MODE_VERTICAL;
	public String fixedOn;
	public boolean fixed = true;

	private UZWidgetInfo widgetInfo;

	public Config(UZModuleContext uzContext, UZWidgetInfo widgetInfo, Context context) {
		this.widgetInfo = widgetInfo;
		
		w = UZCoreUtil.pixToDip(Utils.getScreenWidth(context));
		JSONObject rectObj = uzContext.optJSONObject("rect");
		if (rectObj != null) {
			if (!rectObj.isNull("x")) {
				x = rectObj.optInt("x");
			}

			if (!rectObj.isNull("y")) {
				y = rectObj.optInt("y");
			}

			if (!rectObj.isNull("w")) {
				w = rectObj.optInt("w");
			}

			if (!rectObj.isNull("h")) {
				h = rectObj.optInt("h");
			}
		}

		JSONObject stylesObj = uzContext.optJSONObject("styles");
		if (stylesObj != null) {
			if (!stylesObj.isNull("bg") && !TextUtils.isEmpty(stylesObj.optString("bg"))) {
				bgBitmap = getBitmap(stylesObj.optString("bg"));
				if (bgBitmap == null) {
					bg = UZUtility.parseCssColor(stylesObj.optString("bg"));
				}
			}

			// week
			JSONObject weekObj = stylesObj.optJSONObject("week");
			if (weekObj != null) {
				if (!weekObj.isNull("weekdayColor") && !TextUtils.isEmpty(weekObj.optString("weekdayColor"))) {
					weekdayColor = UZUtility.parseCssColor(weekObj.optString("weekdayColor"));
				}

				if (!weekObj.isNull("weekendColor") && !TextUtils.isEmpty(weekObj.optString("weekendColor"))) {
					weekendColor = UZUtility.parseCssColor(weekObj.optString("weekendColor"));
				}

				if (!weekObj.isNull("size")) {
					weekSize = weekObj.optInt("size");
				}
			}
			
			// date
			JSONObject dateObj = stylesObj.optJSONObject("date");
			if (dateObj != null) {
				
				if (!dateObj.isNull("color") && !TextUtils.isEmpty(dateObj.optString("color"))) {
					dateColor = UZUtility.parseCssColor(dateObj.optString("color"));
				}

				if (!dateObj.isNull("selectedColor") && !TextUtils.isEmpty(dateObj.optString("selectedColor"))) {
					dateSelectedColor = UZUtility.parseCssColor(dateObj.optString("selectedColor"));
				}

				if (!dateObj.isNull("selectedBg") && !TextUtils.isEmpty(dateObj.optString("selectedBg"))) {
					dateSelectedBitmap = getBitmap(dateObj.optString("selectedBg"));
					if (dateSelectedBitmap == null) {
						dateSelectedBg = UZUtility.parseCssColor(dateObj.optString("selectedBg"));
					}
				}

				if (!dateObj.isNull("size")) {
					dateSize = dateObj.optInt("size");
				}
				
			}

			// today
			JSONObject todayObj = stylesObj.optJSONObject("today");
			if (todayObj != null) {

				if (!todayObj.isNull("color") && !TextUtils.isEmpty(todayObj.optString("color"))) {
					todayColor = UZUtility.parseCssColor(todayObj.optString("color"));
				}

				if (!todayObj.isNull("bg") && !TextUtils.isEmpty(todayObj.optString("bg"))) {
					todayBitmap = getBitmap(todayObj.optString("bg"));
					if (todayBitmap == null) {
						todayBg = UZUtility.parseCssColor(todayObj.optString("bg"));
					}
				}
			}

			// SpecialDate
			JSONObject specialDateObj = stylesObj.optJSONObject("specialDate");
			if (specialDateObj != null) {

				if (!specialDateObj.isNull("color") && !TextUtils.isEmpty(specialDateObj.optString("color"))) {
					specialDateColor = UZUtility.parseCssColor(specialDateObj.optString("color"));
				}

				if (!specialDateObj.isNull("bg") && !TextUtils.isEmpty(specialDateObj.optString("bg"))) {

					specialDateBgBitmap = getBitmap(specialDateObj.optString("bg"));
					
					// FIXME
					if (specialDateBgBitmap == null) {
						String colorStr = specialDateObj.optString("bg");
						if(Utils.checkValue(colorStr) == Utils.COLOR){
							specialDateBg = UZUtility.parseCssColor(colorStr);
						} else {
							specialDateBgBitmap = dateSelectedBitmap;
							specialDateBg = dateSelectedBg;
						}
					}
					
				} else {
					specialDateBgBitmap = dateSelectedBitmap;
					specialDateBg = dateSelectedBg;
				}

			}
		}

		JSONArray specialDateArray = uzContext.optJSONArray("specialDate");
		if (specialDateArray != null) {
			
			for (int i = 0; i < specialDateArray.length(); i++) {
				JSONObject tmpObj = specialDateArray.optJSONObject(i);
				if (tmpObj != null) {
					
					SpecicalDateStyle styleItem = new SpecicalDateStyle();
					Bitmap tmpBitmap = getBitmap(tmpObj.optString("bg"));
					
					if(tmpBitmap != null){
						styleItem.bg = tmpBitmap;
					}
					if( !tmpObj.isNull("bg") && !TextUtils.isEmpty(tmpObj.optString("bg"))){
						styleItem.bgColor = UZUtility.parseCssColor(tmpObj.optString("bg"));
						styleItem.hasBg = true;
					} else {
						styleItem.bgColor = specialDateBg;
					}
					
					styleItem.dateText = Utils.correctDate(tmpObj.optString("date"));
					
					if(!tmpObj.isNull("color") && !TextUtils.isEmpty(tmpObj.optString("color"))){
						
						styleItem.color = UZUtility.parseCssColor(tmpObj.optString("color"));
						styleItem.hasTextColor = true;
						
					}
					specialDateList.add(styleItem);
				}
			}
		}

		if (!uzContext.isNull("switchMode")) {
			switchMode = uzContext.optString("switchMode");
		}

		if (!uzContext.isNull("fixedOn")) {
			fixedOn = uzContext.optString("fixedOn");
		}

		if (!uzContext.isNull("fixed")) {
			fixed = uzContext.optBoolean("fixed");
		}

	}
	
	public Bitmap getBitmap(String path) {
		
		if (TextUtils.isEmpty(path)) {
			return null;
		}
		String realPath = UZUtility.makeRealPath(path, widgetInfo);
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
	
}
