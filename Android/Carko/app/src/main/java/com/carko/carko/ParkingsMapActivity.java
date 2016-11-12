package com.carko.carko;

import android.content.Intent;
import android.support.v4.app.FragmentActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;

import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;

public class ParkingsMapActivity extends FragmentActivity implements
        GoogleMap.OnInfoWindowClickListener,
        OnMapReadyCallback {

    private GoogleMap mMap;
    private Button searchButton;
    private Button mostViewedButton;
    private Button featuredButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_parkings_map);
        // Obtain the SupportMapFragment and get notified when the map is ready to be used.
        SupportMapFragment mapFragment = (SupportMapFragment) getSupportFragmentManager()
                .findFragmentById(R.id.map);
        mapFragment.getMapAsync(this);

        searchButton = (Button) findViewById(R.id.search_button);
        mostViewedButton = (Button) findViewById(R.id.most_viewed_button);
        featuredButton = (Button) findViewById(R.id.featured_button);

        mostViewedButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(ParkingsMapActivity.this, MostViewedActivity.class);
                startActivity(intent);
            }
        });
    }


    /**
     * Manipulates the map once available.
     * This callback is triggered when the map is ready to be used.
     * This is where we can add markers or lines, add listeners or move the camera. In this case,
     * we just add a marker near Sydney, Australia.
     * If Google Play services is not installed on the device, the user will be prompted to install
     * it inside the SupportMapFragment. This method will only be triggered once the user has
     * installed Google Play services and returned to the app.
     */
    @Override
    public void onMapReady(GoogleMap googleMap) {
        mMap = googleMap;

        // Add dummy markers
        Parking pPoly = new Parking(1111, "boulevard edouard montpetit", "tout le temps",
                R.drawable.pacman, new LatLng(45.547620, -73.662458));
        addMarker(pPoly, "Polytechnique Montréal");
        mMap.moveCamera(CameraUpdateFactory.newLatLng(pPoly.getLatLng()));
        mMap.animateCamera(CameraUpdateFactory.zoomTo(10), 2000, null);

        Parking pTaisei = new Parking(2222, "boulevard Saint-Laurent", "soir", R.drawable.ghost,
                new LatLng(45.504419, -73.613132));
        addMarker(pTaisei, "Taisei Dojo");

        Parking pSweetie = new Parking(1407, "boulevard Desjardins", "forever", R.drawable.pacmanjaune,
                new LatLng(45.549557, -73.535282));
        addMarker(pSweetie, "<3");

        //TODO: eventually customize the info window
        View customInfoWindow = null;
        View customInfoContent = getLayoutInflater().inflate(R.layout.marker_info_content, null);
        mMap.setInfoWindowAdapter(new ParkingInfoWindowAdapter(customInfoWindow, customInfoContent));

    }


    private void addMarker(Parking parking, String title){
        Marker marker = mMap.addMarker(new MarkerOptions()
            .position(parking.getLatLng())
            .title(title));
        marker.setTag(parking);
    }

    @Override
    public void onInfoWindowClick(final Marker marker){
        Parking parking = (Parking) marker.getTag();

        Toast.makeText(this, "Click Info Window: " + parking.getAddress(), Toast.LENGTH_SHORT).show();

    }

}
