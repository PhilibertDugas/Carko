package com.carko.carko;

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.ListFragment;
import android.view.View;
import android.widget.ListView;

import java.util.ArrayList;

public class ParkingListFragment extends ListFragment {

    ArrayList<Parking> parkings;
    ParkingAdapter parkingAdapter;

    @Override
    public void onActivityCreated(Bundle savedInstanceState){
        super.onActivityCreated(savedInstanceState);

        //TODO: replace dummy parkings
        parkings = new ArrayList<Parking>();
        parkings.add(new Parking("3235 avenue de la malbaie", "nights", R.drawable.pacman));
        parkings.add(new Parking("1075 boulevard jolicoeur", "evenings", R.drawable.pacmanjaune));
        parkings.add(new Parking("1407 boulevard Desjardins", "all", R.drawable.ghost));
        parkings.add(new Parking(" 10023 rue patate", "nights", R.drawable.pacman));
        parkings.add(new Parking("98124 route paradis", "heaven", R.drawable.ghost));
        parkings.add(new Parking("0123 descente aux enfers", "whenever it's dark motherfucker", R.drawable.pacmanjaune));

        parkingAdapter = new ParkingAdapter(getActivity(), parkings);

        setListAdapter(parkingAdapter);
    }

    @Override
    public void onListItemClick(ListView l, View v, int pos, long id){
        super.onListItemClick(l,v,pos,id);
        launchParkingDetailActivity();
    }

    private void launchParkingDetailActivity(){
        // TODO: Send parking information
        Intent intent = new Intent(getActivity(), ParkingDetailActivity.class);
        startActivity(intent);
    }

}
