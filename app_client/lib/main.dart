import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tocitech/pages/login_page.dart';

Future<void> main() async {
  // Necesario antes de usar cualquier plugin nativo, incluyendo Firebase.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización manual para Web usando FirebaseOptions.
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCcbhpRUVd6DZYrd2n9bRIbXBNH8aggwMo",
      authDomain: "tocitech-fb311.firebaseapp.com",
      projectId: "tocitech-fb311",
      storageBucket: "tocitech-fb311.firebasestorage.app",
      messagingSenderId: "801078482243",
      appId: "1:801078482243:web:0ccdf3480007e1058acbf6",
      measurementId: "G-NTP5Q86843", // opcional, solo para Analytics
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tocitech Web',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginPage(),
    );
  }
}
