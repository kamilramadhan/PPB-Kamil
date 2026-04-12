import 'package:firebase_core/firebase_core.dart';
import 'package:cruddbfirebase/firebase_options.dart';
import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'package:cruddbfirebase/screens/login.dart';
import 'package:cruddbfirebase/screens/register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(initialRoute: 'login', routes: {
      'home': (context) => const HomePage(),
      'login': (context) => const LoginScreen(),
      'register': (context) => const RegisterScreen(),
    });
  }
}