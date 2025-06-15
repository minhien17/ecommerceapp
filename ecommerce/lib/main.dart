import 'package:ecommerce/theme.dart';
import 'package:ecommerce/wrappers/authentification_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey = stripePublishableKey;

  await Supabase.initialize(
      anonKey:
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1ma2x5YmNmcGRjYmphZHlvdHduIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY3MDkzNTMsImV4cCI6MjA2MjI4NTM1M30.Ey7RRpqLR22DKCgzB0Ip1JOD2oCWbFnBupWubKxqw0M",
      url: "https://mfklybcfpdcbjadyotwn.supabase.co");
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
