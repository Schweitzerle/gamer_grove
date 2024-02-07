import 'package:flutter/material.dart';
import 'package:gamer_grove/model/igdb_models/genre.dart';
import 'package:gamer_grove/model/igdb_models/keyword.dart';

class KeywordList extends StatelessWidget {
  final List<Keyword> keywords;

  KeywordList(
      {required this.keywords,});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: keywords.map((keyword) {
        return GestureDetector(
          onTap:  () {
            /*
            HapticFeedback.lightImpact();
            Get.to(()=> transition: Transition.downToUp, duration: Duration(milliseconds: 700));

            TODO: Auf All Screen von Genres
             */
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            child: Text(
              '${keyword.name}',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }).toList(),
    );
  }
}
