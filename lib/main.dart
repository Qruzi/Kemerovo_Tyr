import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Auth/auth.dart';
import 'Theme/theme.dart';
import 'card/card_new.dart';
import 'firebase_options.dart';
import 'navigation/feedback.dart';
import 'navigation/navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: appTheme,
      initialRoute:
          FirebaseAuth.instance.currentUser == null ? '/auth' : '/home',
      routes: {
        '/auth': (context) => AuthScreen(),
        '/home': (context) => NavigationScreen(),
        '/feedback': (context) => FeedbackPage(),
        '/card': (context) => CardListScreen(),
      },
    );
  }
}
