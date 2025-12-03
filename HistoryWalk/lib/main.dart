import 'package:flutter/material.dart';
import 'package:historywalk/app.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized(); //if flutter needs to call native code this makes sure you have an instance of the widgetsbinding which is required to use platform channels to use native code

  runApp(const App());
}

