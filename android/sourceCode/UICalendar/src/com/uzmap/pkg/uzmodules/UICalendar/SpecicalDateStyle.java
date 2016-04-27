/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
package com.uzmap.pkg.uzmodules.UICalendar;

import android.graphics.Bitmap;

public class SpecicalDateStyle {
	
	public int color;
	public Bitmap bg;
	public String dateText;
	public int bgColor;
	
	public boolean hasTextColor;
	
	public boolean hasBg;
	
	public SpecicalDateStyle(String dateText){
		this.dateText = dateText;
	}
	
	public SpecicalDateStyle(){}
	
	@Override
	public boolean equals(Object o) {
		
		if(this.dateText == null || o == null ){
			return false;
		}
		
		if(this.dateText.equals(((SpecicalDateStyle)o).dateText)){
			return true;
		}
		
		return false;
	}
	
}
