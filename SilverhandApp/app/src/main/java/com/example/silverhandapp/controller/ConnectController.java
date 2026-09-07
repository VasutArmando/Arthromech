package com.example.silverhandapp.controller;

import com.example.silverhandapp.model.TcpClient;

public class ConnectController {
    private final TcpClient tcpClient;

    public interface ConnectCallback {
        void onResult(boolean success, String message);
    }

    public ConnectController() {
        this.tcpClient = TcpClient.getInstance();
    }

    public void attemptConnection(String ipStr, String portStr, ConnectCallback callback) {
        if (ipStr.isEmpty() || portStr.isEmpty()) {
            callback.onResult(false, "IP or Port cannot be empty");
            return;
        }

        try {
            int port = Integer.parseInt(portStr);
            tcpClient.connect(ipStr, port, new TcpClient.ConnectListener() {
                @Override
                public void onSuccess() {
                    callback.onResult(true, "Connected to Silverhand");
                }

                @Override
                public void onError(String message) {
                    callback.onResult(false, "Connection Failed: " + message);
                }
            });
        } catch (NumberFormatException e) {
            callback.onResult(false, "Invalid Port Number");
        }
    }
}