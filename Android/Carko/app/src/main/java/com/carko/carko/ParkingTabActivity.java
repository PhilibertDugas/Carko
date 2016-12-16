package com.carko.carko;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.support.design.widget.TabLayout;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Toast;

import com.mapbox.mapboxsdk.MapboxAccountManager;
import com.mapbox.mapboxsdk.geometry.LatLng;

import java.util.ArrayList;
import java.util.List;

public class ParkingTabActivity extends AppCompatActivity {

    private TabLayout tabLayout;
    private ViewPager viewPager;
    private ParkingViewPagerAdapter viewPagerAdapter;

    private final int PLACE_PARKING_REQUEST = 1;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_parkings_tab);

        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        tabLayout = (TabLayout) findViewById(R.id.parkings_tab_layout);
        viewPager = (CarkoViewPager) findViewById(R.id.parkings_view_pager);
        viewPagerAdapter = new ParkingViewPagerAdapter(getSupportFragmentManager());

        viewPager.setAdapter(viewPagerAdapter);

        final TabLayout.Tab one = tabLayout.newTab();
        final TabLayout.Tab two = tabLayout.newTab();
        final TabLayout.Tab three = tabLayout.newTab();

        one.setText("ONE");
        two.setText("TWO");
        three.setText("THREE");

        tabLayout.addTab(one, 0);
        tabLayout.addTab(two, 1);
        tabLayout.addTab(three, 2);

        // Listens to swipe movement to change page
        viewPager.addOnPageChangeListener(new TabLayout.TabLayoutOnPageChangeListener(tabLayout));

        // Create a tab listener that is called when the user changes tabs.
        tabLayout.addOnTabSelectedListener(new TabLayout.OnTabSelectedListener() {
            @Override
            public void onTabSelected(TabLayout.Tab tab) {
                viewPager.setCurrentItem(tab.getPosition());
            }

            @Override
            public void onTabUnselected(TabLayout.Tab tab) {

            }

            @Override
            public void onTabReselected(TabLayout.Tab tab) {

            }
        });
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_tabs, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        if (id == R.id.action_settings) {
            return true;
        } else if (id == R.id.action_add_parking) {
            Intent intent = new Intent(this, GeocodingParkingActivity.class);
            startActivityForResult(intent,PLACE_PARKING_REQUEST);
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    protected void onActivityResult(int requestCode, int resultCode,
                                    Intent data) {
        if (requestCode == PLACE_PARKING_REQUEST) {
            if (resultCode == RESULT_OK) {
                // TODO: Add parking to database
                Bundle bundle = data.getParcelableExtra("bundle");
                LatLng pos = bundle != null ? (LatLng) bundle.getParcelable("pos") : null;
                Toast.makeText(this, pos != null ? pos.toString() : "No parkings", Toast.LENGTH_SHORT).show();
            } else {
                Toast.makeText(this, "No parkings", Toast.LENGTH_SHORT).show();
            }
        }
    }
}
