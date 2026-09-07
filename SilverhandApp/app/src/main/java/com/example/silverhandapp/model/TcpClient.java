package com.example.silverhandapp.model;

import java.io.BufferedWriter;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.net.Socket;

public class TcpClient {
    private static TcpClient instance;
    private Socket socket;
    private PrintWriter out;

    private TcpClient() {}

    public static synchronized TcpClient getInstance() {
        if (instance == null) {
            instance = new TcpClient();
        }
        return instance;
    }

    public interface ConnectListener {
        void onSuccess();
        void onError(String message);
    }

    public void connect(String ip, int port, ConnectListener listener) {
        new Thread(() -> {
            try {
                if (socket != null && !socket.isClosed()) {
                    socket.close();
                }
                socket = new Socket(ip, port);
                out = new PrintWriter(new BufferedWriter(new OutputStreamWriter(socket.getOutputStream())), true);
                listener.onSuccess();
            } catch (IOException e) {
                listener.onError(e.getMessage());
            }
        }).start();
    }

    public void sendCommand(String cmd) {
        new Thread(() -> {
            if (out != null && !out.checkError()) {
                out.println(cmd);
            }
        }).start();
    }
}