import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';

import '../firebase/firebaseUser.dart';
import '../igdb_models/game.dart';

class RecommendedCarouselSlider extends StatefulWidget {
  final List<Game>? games;
  FirebaseUserModel otherUserModel;

  RecommendedCarouselSlider({
    required this.games,
    required this.otherUserModel
  });

  @override
  _RecommendedCarouselSliderState createState() => _RecommendedCarouselSliderState();
}

class _RecommendedCarouselSliderState extends State<RecommendedCarouselSlider>
    with SingleTickerProviderStateMixin {


  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
  }


  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: GlassContainer(
              blur: 12,
              shadowStrength: 4,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(14),
              shadowColor: Theme.of(context).primaryColor,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: FittedBox(
                  child: Text(
                    '${widget.otherUserModel.username}`s Recommendations',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 14,
        ),
        CarouselSlider(
          options: CarouselOptions(
              autoPlayInterval: const Duration(seconds: 8),
              autoPlayAnimationDuration:
              const Duration(milliseconds: 1500),
              autoPlay: true,
              aspectRatio: 1.5,
              enableInfiniteScroll: true,
              enlargeCenterPage: true,
              viewportFraction: 0.5,
              enlargeFactor: .4),
          items: widget.games!
              .map((item) => GamePreviewView(game: item, isCover: false, buildContext: context, needsRating: true, isClickable: true, otherUserModel: widget.otherUserModel))
              .toList(),
        ),
      ],
    );
  }
}