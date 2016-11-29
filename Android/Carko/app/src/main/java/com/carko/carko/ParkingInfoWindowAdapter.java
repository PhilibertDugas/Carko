/* package com.carko.carko;

import android.graphics.Color;
import android.text.SpannableString;
import android.text.style.ForegroundColorSpan;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.Marker;

/**
 * Created by fabrice on 2016-11-12.
 */

/*
public class ParkingInfoWindowAdapter implements GoogleMap.InfoWindowAdapter {

    private final View mWindow;
    private final View mContents;

    ParkingInfoWindowAdapter(View customInfoWindow, View customInfoContents){
        mWindow = customInfoWindow;
        mContents = customInfoContents;
    }

    // First method called in case we have a custom window layout
    @Override
    public View getInfoWindow(Marker marker) {
        if (mWindow == null) {
            // No custom layout
            return null;
        }
        render(marker, mWindow);
        return mWindow;
    }

    // Called if getInfoWindow returns null which means we only want to customize the content and
    // use the default window layout
    @Override
    public View getInfoContents(Marker marker) {
        if (mContents == null){
            // No custom layout
            return null;
        }
        render(marker, mContents);
        return mContents;
    }

    private void render(Marker marker, View view){
        Parking parking = (Parking) marker.getTag();

        ((ImageView) view.findViewById(R.id.marker_info_icon)).setImageResource(parking.getDrawable());
        String title = marker.getTitle();

        TextView titleUi = ((TextView) view.findViewById(R.id.marker_info_address));
        if (title != null) {
            // Spannable string allows us to edit the formatting of the text.
            SpannableString titleText = new SpannableString(title);
            titleText.setSpan(new ForegroundColorSpan(Color.RED), 0, titleText.length(), 0);
            titleUi.setText(titleText);
        } else {
            titleUi.setText("");
        }

    }
}
*/