package com.carko.carko;

import android.support.design.widget.TabLayout;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;

public class ParkingTabActivity extends AppCompatActivity {

    private TabLayout tabLayout;
    private ViewPager viewPager;
    private ParkingViewPagerAdapter viewPagerAdapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_parkings_tab);

        tabLayout = (TabLayout) findViewById(R.id.main_tab_layout);
        viewPager = (ViewPager) findViewById(R.id.main_view_pager);
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
}
