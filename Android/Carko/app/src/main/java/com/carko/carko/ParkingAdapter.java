package com.carko.carko;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.ArrayList;

/**
 * Created by fabrice on 2016-11-12.
 */

public class ParkingAdapter extends ArrayAdapter<Parking> {

    // View Holder pattern
    public static class ViewHolder {
        ImageView image;
        TextView address;
        TextView preview;
    }

    ParkingAdapter(Context context, ArrayList<Parking> parkings){ super(context, 0, parkings); }

    @Override
    public View getView(int pos, View convertView, ViewGroup parent){
        // Get the data item for this position
        Parking parking = getItem(pos);

        // Create a new view holder
        ViewHolder viewHolder;

        // Check if an existing view is being reused , otherwise inflate a new view from custom row layout
        if (convertView == null){
            viewHolder = new ViewHolder();
            convertView = LayoutInflater.from(getContext()).inflate(R.layout.parking_list_row, parent, false);

            // Grab references of views
            viewHolder.address = (TextView) convertView.findViewById(R.id.listItemParkingAddress);
            viewHolder.preview = (TextView) convertView.findViewById(R.id.listItemParkingAvailabilityTime);
            viewHolder.image = (ImageView) convertView.findViewById(R.id.listItemParkingImage);

            // Remember our ViewHolder that holds the references to the widgets
            convertView.setTag(viewHolder);
        } else{
            viewHolder = (ViewHolder) convertView.getTag();
        }

        // Fill each new referenced view with data associated with the parking it's referencing
        viewHolder.address.setText(parking.getAddress());
        viewHolder.preview.setText(parking.getAvailability());
        viewHolder.image.setImageResource(parking.getDrawable());

        return convertView;
    }
}
