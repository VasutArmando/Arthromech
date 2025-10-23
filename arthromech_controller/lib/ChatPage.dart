import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;

  const ChatPage({required this.server});

  @override
  _ChatPage createState() => new _ChatPage();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _ChatPage extends State<ChatPage> {
  static final clientID = 0;
  BluetoothConnection? connection;

  bool automatic = true;
  bool manual = false;
  bool voiceControl = false;

  String closeText = "close";
  String openText = "open";
  String GestureText = "look";
  String GestureCmd = "23222";
  final closeCtrl = TextEditingController();
  final OpenCtrl = TextEditingController();
  final GestTxtCtrl = TextEditingController();
  final GestCmdCtrl = TextEditingController();
  // stt.SpeechToText _speech = stt.SpeechToText();
  //bool _isListenting = false;
  //String _text = "You need to switch on voice control";
  // double _confidence = 1.0;

  List<_Message> messages = List<_Message>.empty(growable: true);
  String _messageBuffer = '';

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;
  bool get isConnected => (connection?.isConnected ?? false);

  bool isDisconnecting = false;

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _wordsSpoken = "last words";
  var _auxWord;
  // String _lastWord = "last words";
  double _confidenceLevel = 0;
  void statusListener(String status) async {
    debugPrint("status $status");
    if (status == "done" && _speechEnabled) {
      setState(() {
        _speechEnabled = false;
      });
    }
    if (voiceControl) _startListening();
  }

  void initSpeech() async {
    _speechEnabled = await _speechToText.initialize(onStatus: statusListener);
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: onSpeechResult);
    setState(() {
      _confidenceLevel = 0;
    });
  }

  void stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(result) {
    setState(() {
      _wordsSpoken = "${result.recognizedWords}";
      _auxWord = _wordsSpoken.split(' ').last;
      _wordsSpoken = _auxWord.toString();
      _confidenceLevel = result.confidence;
      if (_auxWord.toString() == openText) _sendMessage("3");
      if (_auxWord.toString() == closeText) _sendMessage("2");
      if (_auxWord.toString() == GestureText) _sendMessage(GestureCmd);
    });
  }

  @override
  void initState() {
    super.initState();
    // _speech = stt.SpeechToText();
    initSpeech();
    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection!.input!.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Row> list = messages.map((_message) {
      return Row(
        children: <Widget>[
          Container(
            child: Text(
                (text) {
                  return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
                }(_message.text.trim()),
                style: TextStyle(color: Colors.white)),
            padding: EdgeInsets.all(12.0),
            margin: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            width: 222.0,
            decoration: BoxDecoration(
                color:
                    _message.whom == clientID ? Colors.blueAccent : Colors.grey,
                borderRadius: BorderRadius.circular(7.0)),
          ),
        ],
        mainAxisAlignment: _message.whom == clientID
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
      );
    }).toList();

    final serverName = widget.server.name ?? "Unknown";
    return Scaffold(
        appBar: AppBar(
            title: (isConnecting
                ? Text('Connecting to Arthromech hand...')
                : isConnected
                    ? Text('Arthromech hand is live')
                    : Text('Arthromech hand controller'))),
        body: ListView(
          children: [
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Flexible(
                  //   child: ListView(
                  //       padding: const EdgeInsets.all(12.0),
                  //       controller: listScrollController,
                  //       children: list),
                  // ),
                  // ListTile(title: const Text('General')),
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Container(
                          margin: const EdgeInsets.only(left: 16.0, top: 5.0),
                          child: TextField(
                            style: const TextStyle(fontSize: 15.0),
                            decoration: InputDecoration.collapsed(
                              hintText: isConnecting
                                  ? 'Wait until connected...'
                                  : isConnected
                                      ? 'status: connected'
                                      : 'status: disconnected',
                              hintStyle: const TextStyle(color: Colors.grey),
                            ),
                            enabled: isConnected,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  SwitchListTile(
                    title: const Text('Automatic control'),
                    value: automatic,
                    onChanged: (bool value) {
                      setState(() {
                        if (value) {
                          automatic = true;
                          manual = false;
                          voiceControl = false;
                          _sendMessage("1");
                        } else {
                          automatic = false;
                          _sendMessage("9"); //empty state
                        }
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Manual control'),
                    value: manual,
                    onChanged: (bool value) {
                      setState(() {
                        if (value) {
                          automatic = false;
                          manual = true;
                          _sendMessage("9");
                        } else {
                          manual = false;
                          _sendMessage("9"); //empty state
                        }
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Voice control'),
                    value: voiceControl,
                    onChanged: (bool value) {
                      setState(() {
                        if (value == true) {
                          _startListening();
                          voiceControl = true;
                          automatic = false;
                        } else {
                          voiceControl = false;
                          stopListening();
                        }
                      });
                    },
                  ),
                  Divider(),
                  Container(
                    child: Text("Manual control"),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8.0),
                        child: IconButton(
                            icon: const Icon(Icons.close),
                            iconSize: 25,
                            onPressed: manual ? () => _sendMessage("2") : null),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8.0),
                        child: IconButton(
                            iconSize: 25,
                            icon: const Icon(Icons.open_in_full),
                            onPressed: manual ? () => _sendMessage("3") : null),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 15, right: 15),
                    child: Text(
                      "You can send commands to the hand: 3 to open the finger, 2 to close the finger (ex: message \"23222\" to open the the index finger and close the others)",
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Container(
                          margin: const EdgeInsets.only(left: 16.0),
                          child: TextField(
                            style: const TextStyle(fontSize: 15.0),
                            controller: textEditingController,
                            decoration: InputDecoration(
                              hintText: isConnecting
                                  ? 'Wait until connected...'
                                  : isConnected
                                      ? 'Type your message...'
                                      : 'disconnected',
                              hintStyle: const TextStyle(color: Colors.grey),
                            ),
                            enabled: isConnected,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8.0),
                        child: IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: isConnected && manual
                                ? () => _sendMessage(textEditingController.text)
                                : null),
                      ),
                    ],
                  ),
                  Divider(),
                  Container(
                    child: Text("Voice control"),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 13, bottom: 13),
                    child: AvatarGlow(
                        animate: voiceControl,
                        glowColor: Theme.of(context).primaryColor,
                        duration: const Duration(milliseconds: 2000),
                        repeat: true,
                        child: Icon(voiceControl ? Icons.mic : Icons.mic_none)),
                  ),

                  Text(_speechToText.isListening
                      ? "Listening..."
                      : _speechEnabled
                          ? "Activate voice control to start listening..."
                          : ""),
                  Container(
                      padding: EdgeInsets.all(15),
                      child: Text(
                        _auxWord.toString(),
                      )),
                  Divider(),
                  Container(
                    child: Text("Settings for voice control"),
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                            padding: EdgeInsets.all(15),
                            child: TextField(
                                style: const TextStyle(fontSize: 12.0),
                                controller: closeCtrl,
                                decoration: InputDecoration(
                                  hintText:
                                      "voice command to close the hand ex: (\"close\") ",
                                ))),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8.0),
                        child: IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () {
                              setState(() {
                                closeText = closeCtrl.text;
                              });
                            }),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                            padding: EdgeInsets.all(15),
                            child: TextField(
                                style: const TextStyle(fontSize: 12.0),
                                controller: OpenCtrl,
                                decoration: InputDecoration(
                                  hintText:
                                      "voice command to open the hand (ex: \"open\") ",
                                ))),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8.0),
                        child: IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () {
                              setState(() {
                                openText = OpenCtrl.text;
                              });
                            }),
                      ),
                    ],
                  ),

                  Divider(),
                  Container(
                    child: Text("Gesture settings for voice control"),
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                            padding: EdgeInsets.all(15),
                            child: TextField(
                                style: const TextStyle(fontSize: 12.0),
                                controller: GestCmdCtrl,
                                decoration: InputDecoration(
                                  hintText: "command ex: \"23222\") ",
                                ))),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8.0),
                        child: IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () {
                              setState(() {
                                GestureCmd = GestCmdCtrl.text;
                              });
                            }),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                            padding: EdgeInsets.all(15),
                            child: TextField(
                                style: const TextStyle(fontSize: 12.0),
                                controller: GestTxtCtrl,
                                decoration: InputDecoration(
                                  hintText:
                                      "voice command for gesture ex: \"look\") ",
                                ))),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8.0),
                        child: IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () {
                              setState(() {
                                GestureText = GestTxtCtrl.text;
                              });
                            }),
                      ),
                    ],
                  ),

                  //
                ],
              ),
            ),
          ],
        ));
  }

  // void listen() async {
  //   if (!voiceControl) {
  //     bool available = await _speech.initialize(
  //       onStatus: (val) => print('onStatus: $val'),
  //       onError: (val) => print('onError: $val'),
  //     );
  //     if (available) {
  //       setState(() => voiceControl = true);
  //       _speech.listen(
  //         onResult: (val) => setState(() {
  //           _text = val.recognizedWords;

  //           if (val.hasConfidenceRating && val.confidence > 0) {
  //             _confidence = val.confidence;
  //           }
  //         }),
  //       );
  //     } else {
  //       setState(() => voiceControl = false);
  //       _speech.stop();
  //     }
  //   }
  // }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();

    if (text.length > 0) {
      try {
        connection!.output.add(Uint8List.fromList(utf8.encode(text + "\r\n")));
        await connection!.output.allSent;

        setState(() {
          messages.add(_Message(clientID, text));
        });
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }
}
