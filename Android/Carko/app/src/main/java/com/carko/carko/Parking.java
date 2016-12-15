package com.carko.carko;

import com.mapbox.mapboxsdk.geometry.LatLng;

import java.util.Date;
import java.util.Random;

/**
 * Created by fabrice on 2016-11-11.
 */

public class Parking {

    private long id;
    private LatLng latLng;
    private String address;
    //TODO: Get real parking image
    private int drawable; // private String photoURL;
    private float price;
    private String description;
    private long cid;
    //TODO: Replace dummy availability for real shnats
    private String availability;
    private boolean isAvailable;

    Parking(){
        // TODO: Create an actual data structure for parkings
        this.latLng = new LatLng(45.547620, -73.662458);
        this.id = new Random(1234).nextInt((500 - 1) + 1) + 1;
        this.address = "3235 avenue de la malbaie";
        this.availability = "days";
        this.drawable = R.drawable.ghost;
    }

    //Dummy constructor for testing
    Parking(String address, String availability, int drawable){
        this.address = address;
        this.availability = availability;
        this.drawable = drawable;
    }

    //Dummy constructor for testing
    Parking(String address, String availability, int drawable, LatLng ll){
        this.address = address;
        this.availability = availability;
        this.drawable = drawable;
        this.latLng = ll;
    }

    public long getId(){ return id; }
    public LatLng getLatLng(){ return latLng; }
    public String getAvailability() { return availability; }
    public String getAddress() {return address; }
    public int getDrawable() {
        return this.drawable;
    }
}
