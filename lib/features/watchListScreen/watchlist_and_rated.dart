import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../model/singleton/sinlgleton.dart';

class WatchlistScreen extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute(
      builder: (context) => WatchlistScreen(),
    );
  }
  @override
  _WatchlistScreenState createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen>
    with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /* appBar: AppBar(
        title: Text('GamerGrove'),
        automaticallyImplyLeading: false,
        backgroundColor: Singleton.firstTabColor,
        actions: [
          //TODO: IGDB Logo
          Padding(
            padding: EdgeInsets.all(5),
            child: SvgPicture.asset(
              "assets/images/tmdb_logo.svg",
              fit: BoxFit.fitHeight, //
              alignment:
              Alignment.centerRight, // Adjust the fit property as needed
            ),
          ),
        ],
      ),*/
      body: Container(
      ),
    );
  }
}
