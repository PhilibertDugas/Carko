package com.carko.carko;

import com.mapbox.mapboxsdk.geometry.LatLng;

import java.util.Date;
import java.util.Random;

/**
 * Created by fabrice on 2016-11-11.
 */

public class Parking {

    public static class Address{
        public long streetNumber;
        public String streetName;
        Address(long streetNumber, String streetName){
            this.streetNumber = streetNumber;
            this.streetName = streetName;
        }
    }

    private LatLng latLng;
    private Address address;
    private long id;
    private long dateAdded;

    //TODO: Replace dummy availability for real shnats
    private String availability;

    //TODO: Get real parking image
    private int drawable;

    Parking(){
        // TODO: Create an actual data structure for parkings
        this.latLng = new LatLng(45.547620, -73.662458);
        this.id = new Random(1234).nextInt((500 - 1) + 1) + 1;
        this.dateAdded = new Date().getTime();
        this.address = new Address(3235, "avenue de la malbaie");
        this.availability = "days";
        this.drawable = R.drawable.ghost;
    }

    //Dummy constructor for testing
    Parking(long streetAdress, String streetName, String availability, int drawable){
        this.address = new Address(streetAdress, streetName);
        this.availability = availability;
        this.drawable = drawable;
    }

    //Dummy constructor for testing
    Parking(long streetAdress, String streetName, String availability, int drawable, LatLng ll){
        this.address = new Address(streetAdress, streetName);
        this.availability = availability;
        this.drawable = drawable;
        this.latLng = ll;
    }

    public LatLng getLatLng(){ return latLng; }
    public long getId(){ return id; }
    public long getDateAdded(){ return dateAdded; }
    public String getAvailability() { return availability; }

    public String getAddress() {
        return Long.toString(address.streetNumber) + " " + address.streetName;
    }

    public int getDrawable() {
        return this.drawable;
    }
}
