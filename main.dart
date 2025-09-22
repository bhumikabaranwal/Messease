import 'package:flutter/material.dart';
import 'package:messease/screens/launch_screen.dart'; // Import Launch Screen
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hostel Mess App',
      home: LaunchScreen(), // Start with LaunchScreen
    );
  }
}
