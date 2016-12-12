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
import android.view.View;
import android.widget.Button;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.List;

public class MainActivity extends AppCompatActivity {

    private TabLayout tabLayout;
    private ViewPager viewPager;
    private MainViewPagerAdapter viewPagerAdapter;

    private Button signInButton;

    private final int CARKO_PERMISSION_LOCATION = 1;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        signInButton = (Button) findViewById(R.id.sign_in_button);
        signInButton.setEnabled(false);

        tabLayout = (TabLayout) findViewById(R.id.main_tab_layout);
        viewPager = (ViewPager) findViewById(R.id.main_view_pager);
        viewPagerAdapter = new MainViewPagerAdapter(getSupportFragmentManager());

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

        checkPermissions();

    }

    private void checkPermissions(){
        List<String> requiredPermissions = new ArrayList<String>();

        if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) !=
                PackageManager.PERMISSION_GRANTED){
            requiredPermissions.add(Manifest.permission.ACCESS_COARSE_LOCATION);
        }

        if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) !=
                PackageManager.PERMISSION_GRANTED){
            requiredPermissions.add(Manifest.permission.ACCESS_FINE_LOCATION);
        }

        // TODO: Finish this permission stuff
        if (requiredPermissions.size() > 0){
            // Should we show an explanation?
            if (ActivityCompat.shouldShowRequestPermissionRationale(this,
                    Manifest.permission.ACCESS_COARSE_LOCATION) ||
                    ActivityCompat.shouldShowRequestPermissionRationale(this,
                            Manifest.permission.ACCESS_FINE_LOCATION)) {
                Context context = getApplicationContext();
                CharSequence text = "Permission needs explanation!";
                int duration = Toast.LENGTH_SHORT;
                Toast.makeText(context, text, duration).show();
            } else {
                ActivityCompat.requestPermissions(this,
                        requiredPermissions.toArray(new String[requiredPermissions.size()]),
                        CARKO_PERMISSION_LOCATION);
            }
        } else{
            signInButton.setEnabled(true);
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           String permissions[], int[] grantResults) {
        switch (requestCode) {
            case CARKO_PERMISSION_LOCATION: {
                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0
                        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {

                    // permission was granted, yay! Do the
                    // location-related task you need to do.
                    signInButton.setEnabled(true);

                } else {

                    // permission denied, boo! Disable the
                    // functionality that depends on this permission.
                    signInButton.setEnabled(false);
                    Context context = getApplicationContext();
                    CharSequence text = "Grant permissions in user settings.";
                    int duration = Toast.LENGTH_SHORT;
                    Toast.makeText(context, text, duration).show();
                }
                return;
            }

            // other 'case' lines to check for other
            // permissions this app might request
        }
    }

    /** Called when the user clicks the Sign in button */
    public void signIn(View view) {
        Intent intent = new Intent(this, LoginActivity.class);
        startActivity(intent);
    }

    /** Called when the user clicks the Register button */
    public void register(View view) {
        Intent intent = new Intent(this, RegisterActivity.class);
        startActivity(intent);
    }
}
