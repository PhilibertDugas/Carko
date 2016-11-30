package com.carko.carko;

import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentStatePagerAdapter;

/**
 * Created by fabrice on 2016-11-26.
 */

public class ParkingViewPagerAdapter extends FragmentStatePagerAdapter {

    public ParkingViewPagerAdapter(FragmentManager fm){
        super(fm);
    }

    @Override
    public Fragment getItem(int position){
        Fragment fragment;
        switch(position){
            case 0:
                fragment = new ParkingMapFragment();
                break;
            case 1:
                fragment = new ParkingListFragment();
                break;
            case 2:
                fragment = new MainTabFragment();
                break;
            default:
                fragment = new MainTabFragment();
        }

        return fragment;
    }

    @Override
    public int getCount(){
        return 3;
    }

}
