import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:projectfilecasasuzanna/firebase_options.dart';
import 'package:projectfilecasasuzanna/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const CasaSuzannaApp());
}

class CasaSuzannaApp extends StatelessWidget {
  const CasaSuzannaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Casa Suzanna',
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const HomePage(),
    );
  }
}
