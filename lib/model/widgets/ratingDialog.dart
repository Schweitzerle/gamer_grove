import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';

import '../singleton/sinlgleton.dart';

class CustomRatingDialog extends StatelessWidget {
  final Color colorPalette;
  final Color adjustedTextColor;

  CustomRatingDialog({
   required this.colorPalette, required this.adjustedTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 400,
      child: contentBox(context),
    );
  }
  contentBox(context) {
    return Stack(
      children: <Widget>[
        GlassContainer(
          shadowColor: colorPalette.lighten(20),
          shadowStrength: 8,
          blur: 2,
          color: Theme.of(context).colorScheme.background,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Center(
                  child: GlassContainer(
                    width: double.infinity,
                    blur: 12,
                    color: Theme.of(context).colorScheme.background,
                    shadowStrength: 4,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(14),
                    shadowColor: colorPalette.darken(20),
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        'Rate this Game',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 14,),
                StaggeredGrid.count(
                    crossAxisCount: 12,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 8,
                    children: [
                      StaggeredGridTile.count(
                        crossAxisCellCount: 6,
                        mainAxisCellCount: 4,
                        child: GlassContainer(
                          blur: 12,
                          shadowStrength: 4,
                          color: Colors.blue.lighten(20).withOpacity(.8),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(14),
                          shadowColor: Colors.blue.lighten(20),
                          child: TextButton(
                            onPressed: () {},
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.bookmark,
                                    color: Colors.blue,
                                    size: 30,
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Wishlist',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      StaggeredGridTile.count(
                        crossAxisCellCount: 6,
                        mainAxisCellCount: 4,
                        child: GlassContainer(
                          blur: 12,
                          shadowStrength: 4,
                          shape: BoxShape.rectangle,
                          color: Colors.orange.lighten(20).withOpacity(.8),
                          borderRadius: BorderRadius.circular(14),
                          shadowColor: Colors.orange,
                          child: TextButton(
                            onPressed: () {},
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.recommend_outlined,
                                    color: Colors.orange,
                                    size: 30,
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    'Empfehlung',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      StaggeredGridTile.count(
                        crossAxisCellCount: 4,
                        mainAxisCellCount: 4,
                        child: GlassContainer(
                          blur: 12,
                          shadowStrength: 4,
                          shape: BoxShape.rectangle,
                          color: Colors.black.lighten(20).withOpacity(.8),
                          borderRadius: BorderRadius.circular(14),
                          shadowColor: Colors.black,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Column(
                                children: [
                                  Icon(
                                    CupertinoIcons.arrowshape_turn_up_left,
                                    color: Colors.black,
                                    size: 30,
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Abbruch',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),),
                      StaggeredGridTile.count(
                        crossAxisCellCount: 4,
                        mainAxisCellCount: 4,
                        child: GlassContainer(
                          blur: 12,
                          shadowStrength: 4,
                          shape: BoxShape.rectangle,
                          color: Colors.red.lighten(20).withOpacity(.8),
                          borderRadius: BorderRadius.circular(14),
                          shadowColor: Colors.red,
                          child: TextButton(
                            onPressed: () {
                              // Logic to submit the rating
                              Navigator.of(context).pop();
                            },
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Column(
                                children: [
                                  Icon(
                                    CupertinoIcons.delete_solid,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    'Löschen',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),),
                      StaggeredGridTile.count(
                        crossAxisCellCount: 4,
                        mainAxisCellCount: 4,
                        child: GlassContainer(
                          blur: 12,
                          shadowStrength: 4,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.green.lighten(20).withOpacity(.8),
                          shadowColor: Colors.green,
                          child: TextButton(
                            onPressed: () {},
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Column(
                                children: [
                                  Icon(
                                    CupertinoIcons.gamecontroller_fill,
                                    color: Colors.green,
                                    size: 30,
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    'Anwenden',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),),
                    ]),
                SizedBox(height: 14,),
                Center(
                  child: GlassContainer(
                    blur: 12,
                    shadowStrength: 4,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(14),
                    shadowColor: colorPalette.darken(30),
                    color: adjustedTextColor,
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RatingBar.builder(
                          itemSize: 42,
                          initialRating: 2,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          glowRadius: 1,
                          glowColor: colorPalette.lighten(20),
                          glow: true,
                          unratedColor:adjustedTextColor == Colors.white ? colorPalette.lighten(40) : colorPalette.darken(40),
                          itemCount: 10,
                          itemPadding: EdgeInsets.symmetric(horizontal: 1.5),
                          itemBuilder: (context, _) => Icon(
                            CupertinoIcons.gamecontroller_fill,
                            color:  adjustedTextColor == Colors.white ? colorPalette.darken(40) : colorPalette.lighten(40),

                          ),
                          onRatingUpdate: (updatedRating) {},
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
