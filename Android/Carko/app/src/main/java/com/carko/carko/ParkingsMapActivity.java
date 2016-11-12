package com.carko.carko;

import android.content.Intent;
import android.support.v4.app.FragmentActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.MarkerOptions;

public class ParkingsMapActivity extends FragmentActivity implements OnMapReadyCallback {

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
        LatLng polymtl = new LatLng(45.547620, -73.662458);
        mMap.addMarker(new MarkerOptions().position(polymtl).title("Polytechnique Montréal"));
        mMap.moveCamera(CameraUpdateFactory.newLatLng(polymtl));

        LatLng taisei = new LatLng(45.504419, -73.613132);
        mMap.addMarker(new MarkerOptions().position(taisei).title("Tai Sei Do"));

        LatLng sweetie = new LatLng(45.549557, -73.535282);
        mMap.addMarker(new MarkerOptions().position(sweetie).title("Sweetie"));
    }


}
