package com.carko.carko;

import android.content.Context;
import android.support.v4.view.ViewPager;
import android.util.AttributeSet;
import android.view.MotionEvent;

/**
 * Created by fabrice on 2016-12-12.
 */

public class CarkoViewPager extends ViewPager {
    public CarkoViewPager(Context context) {
        super(context);
    }

    public CarkoViewPager(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    @Override
    public boolean onInterceptTouchEvent(MotionEvent event){
        // Disable swipe on map view
        return getCurrentItem() != 0 && super.onInterceptTouchEvent(event);
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        // Disable swipe on map view
        return getCurrentItem() != 0 && super.onTouchEvent(event);
    }
}
