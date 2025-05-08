import 'package:ecommerce/theme.dart';
import 'package:ecommerce/wrappers/authentification_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Supabase.initialize(
      anonKey:
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJpem5vbm9maW56eHp6a29lZm1wIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ4NjQwMTMsImV4cCI6MjA2MDQ0MDAxM30.CFPRE-kcXY3VAm6ddzZjXa3NE_QczscD64CTbwjXF_4",
      url: "https://biznonofinzxzzkoefmp.supabase.co");
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
