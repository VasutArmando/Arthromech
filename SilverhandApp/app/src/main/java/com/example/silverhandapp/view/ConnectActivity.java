package com.example.silverhandapp.view;

import android.content.Intent;
import android.os.Bundle;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;

import com.example.silverhandapp.R;
import com.example.silverhandapp.controller.ConnectController;

public class ConnectActivity extends AppCompatActivity {
    private ConnectController controller;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_connect);

        controller = new ConnectController();

        EditText etIp = findViewById(R.id.et_ip);
        EditText etPort = findViewById(R.id.et_port);
        Button btnConnect = findViewById(R.id.btn_connect);

        btnConnect.setOnClickListener(v -> {
            String ip = etIp.getText().toString().trim();
            String port = etPort.getText().toString().trim();

            controller.attemptConnection(ip, port, (success, message) ->
                    runOnUiThread(() -> {
                        Toast.makeText(ConnectActivity.this, message, Toast.LENGTH_SHORT).show();
                        if (success) {
                            Intent intent = new Intent(ConnectActivity.this, HandControlActivity.class);
                            startActivity(intent);
                        }
                    })
            );
        });
    }
}