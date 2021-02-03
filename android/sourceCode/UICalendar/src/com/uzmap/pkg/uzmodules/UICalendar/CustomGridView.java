/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

package com.uzmap.pkg.uzmodules.UICalendar;

import android.annotation.SuppressLint;
import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.widget.GridView;

public class CustomGridView extends GridView{

	public CustomGridView(Context context) {
		super(context);
	}

	public CustomGridView(Context context, AttributeSet attrs, int defStyleAttr) {
		super(context, attrs, defStyleAttr);
	}

	public CustomGridView(Context context, AttributeSet attrs) {
		super(context, attrs);
	}
	
	private int downY = 0;

	@SuppressLint("ClickableViewAccessibility") 
	@Override
	public boolean onTouchEvent(MotionEvent ev) {
		
		switch(ev.getAction()){
		
		case MotionEvent.ACTION_DOWN:
			downY = (int)ev.getRawY();
			break;
		
		case MotionEvent.ACTION_MOVE:
			int offset = (int)ev.getRawY() - downY;
			
//			((View)(((View)getParent()).getParent())).scrollTo(0, - offset);
			
//			if(((View)(((View)getParent()).getParent())).getScrollY() < 0){
//				((View)(((View)getParent()).getParent())).scrollTo(0, 0);
//			}
			break;
			
		case MotionEvent.ACTION_UP:
			break;
		
		}
		return super.onTouchEvent(ev);
	}
	
}
