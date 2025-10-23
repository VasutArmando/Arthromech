import 'package:flutter/material.dart';

import './MainPage.dart';

void main() => runApp(new HandControllerApp());

class HandControllerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: MainPage());
  }
}
