import 'package:ecommerce/theme.dart';
import 'package:ecommerce/wrappers/authentification_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "appName",
        debugShowCheckedModeBanner: false,
        theme: theme(),
        home: AuthentificationWrapper());
  }
}
