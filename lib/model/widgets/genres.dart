import 'package:flutter/material.dart';
import 'package:gamer_grove/model/igdb_models/genre.dart';

class GenreList extends StatelessWidget {
  final List<Genre> genres;

  GenreList(
      {required this.genres,});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: genres.map((genre) {
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
              '${genre.name}',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }).toList(),
    );
  }
}
