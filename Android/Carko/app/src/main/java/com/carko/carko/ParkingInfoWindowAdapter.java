package com.carko.carko;

import android.graphics.Color;
import android.support.annotation.NonNull;
import android.text.SpannableString;
import android.text.style.ForegroundColorSpan;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.mapbox.mapboxsdk.annotations.Marker;
import com.mapbox.mapboxsdk.maps.MapboxMap;

/**
 * Created by fabrice on 2016-11-12.
 */


public class ParkingInfoWindowAdapter implements MapboxMap.InfoWindowAdapter {

    private final View mWindow;

    ParkingInfoWindowAdapter(View customInfoWindow){
        mWindow = customInfoWindow;
    }

    @Override
    public View getInfoWindow(@NonNull Marker marker) {
        render(marker, mWindow);
        return mWindow;
    }

    private void render(Marker marker, View view){
        // TODO: Replace placeholders with real information
        //Parking parking = (Parking) marker.getTag();

        ((ImageView) view.findViewById(R.id.marker_info_icon)).setImageResource(R.drawable.pacman);
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
