import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:calorie_counter/login_screen.dart';
import 'package:calorie_counter/home_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<FirebaseApp> _initFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    return Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initFirebase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        } else if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Firebase Error: ${snapshot.error}')),
            ),
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Calorie Counter',
          theme: ThemeData(primarySwatch: Colors.purple),
          home: const LoginScreen(),
        );
      },
    );
  }
}
