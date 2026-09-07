package com.example.silverhandapp.controller;

import com.example.silverhandapp.model.TcpClient;

public class HandController {
    private final TcpClient tcpClient;

    public HandController() {
        this.tcpClient = TcpClient.getInstance();
    }

    public void closeHand() { tcpClient.sendCommand("2"); }
    public void openHand() { tcpClient.sendCommand("3"); }
    public void calibrate() { tcpClient.sendCommand("6"); }
    public void recordGesture() { tcpClient.sendCommand("7"); }
    public void playForward() { tcpClient.sendCommand("8"); }
    public void playReverse() { tcpClient.sendCommand("9"); }
}