import 'package:ecommerce/pages/home/components/body.dart';
import 'package:flutter/material.dart';

import 'components/home_screen_drawer.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(),
      drawer: HomeScreenDrawer(),
    );
  }
}
