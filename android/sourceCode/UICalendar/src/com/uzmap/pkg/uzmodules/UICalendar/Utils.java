/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
package com.uzmap.pkg.uzmodules.UICalendar;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.text.TextUtils;
import android.view.WindowManager;

import com.uzmap.pkg.uzcore.uzmodule.UZModuleContext;

public class Utils {

	public static final int TYPE_MONTH = 0;
	public static final int TYPE_SWITCH = 1;
	public static final int TYPE_ALL = 2;

	public static void callback(UZModuleContext moduleContext,
			String eventType, int year, int month, int day, int cbType,int id) {
		JSONObject ret = new JSONObject();
		try {
			if (cbType == TYPE_ALL) {
				ret.put("eventType", eventType);
				ret.put("year", year);
				ret.put("month", month + 1);
				ret.put("day", day);
			}

			if (cbType == TYPE_SWITCH) {
				ret.put("eventType", eventType);
				ret.put("year", year);
				ret.put("month", month + 1);
			}

			if (cbType == TYPE_MONTH) {
				ret.put("year", year);
				ret.put("month", month + 1);
			}
			ret.put("id", id);

		} catch (JSONException e) {
			e.printStackTrace();
		}

		if (moduleContext != null) {
			moduleContext.success(ret, false);
		}
	}

	@SuppressWarnings("deprecation")
	public static int getScreenWidth(Context mContext) {
		WindowManager wm = (WindowManager) mContext
				.getSystemService(Context.WINDOW_SERVICE);
		return wm.getDefaultDisplay().getWidth();
	}

	public static String correctDate(String date) {
		if (!TextUtils.isEmpty(date) && date.contains("-")) {
			String[] arr = date.split("-");

			return arr[0] + "-"
					+ String.format("%02d", Integer.valueOf(arr[1])) + "-"
					+ String.format("%02d", Integer.valueOf(arr[2]));
		}

		return null;
	}

	public static final int PATH = 0x01;
	public static final int COLOR = 0x02;
	public static final int INVALIDATE_VALUE = 0x03;

	public static int checkValue(String value) {
		Pattern pattern = Pattern.compile("(widget|fs|http)://");
		Matcher matcher = pattern.matcher(value);
		if (matcher.matches()) {
			return PATH;
		}

		pattern = Pattern.compile("#[0-9A-Fa-f]{6}");
		matcher = pattern.matcher(value);
		if (matcher.matches()) {
			return COLOR;
		}

		pattern = Pattern.compile("#[0-9A-Fa-f]{3}");
		matcher = pattern.matcher(value);
		if (matcher.matches()) {
			return COLOR;
		}

		pattern = Pattern.compile("(rgb|rgba)");
		matcher = pattern.matcher(value);
		if (matcher.matches()) {
			return COLOR;
		}

		return INVALIDATE_VALUE;
	}

}
