package com.example.silverhandapp.view;

import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;

import com.example.silverhandapp.R;
import com.example.silverhandapp.controller.HandController;

public class HandControlActivity extends AppCompatActivity {
    private HandController controller;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_hand_control);

        controller = new HandController();

        findViewById(R.id.btn_close).setOnClickListener(v -> controller.closeHand());
        findViewById(R.id.btn_open).setOnClickListener(v -> controller.openHand());
        findViewById(R.id.btn_calibrate).setOnClickListener(v -> controller.calibrate());
        findViewById(R.id.btn_record).setOnClickListener(v -> controller.recordGesture());
        findViewById(R.id.btn_play_fwd).setOnClickListener(v -> controller.playForward());
        findViewById(R.id.btn_play_rev).setOnClickListener(v -> controller.playReverse());
    }
}