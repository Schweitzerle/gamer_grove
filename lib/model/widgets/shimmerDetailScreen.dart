import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gamer_grove/model/widgets/shimmerGameItem.dart';
import 'package:shimmer/shimmer.dart';

import '../singleton/sinlgleton.dart';

class ShimmerDetailScreen{



  static Widget ShimmerEffectDetailScreens(BuildContext context, Color color) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          // Shimmer Placeholder for Banner
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color.fromRGBO(0, 0, 0, 1),
                  ],
                  stops: [0.1, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.darken,
              child: Shimmer.fromColors(
                baseColor: color,
                highlightColor: Singleton.highlightColor,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: double.infinity,
                  color: color,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.only(
                left: 10,
                right: 10,
                bottom: 10,
                top: MediaQuery.of(context).size.height * 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Row(
                  children: [
                    Stack(
                      children: [
                        // Shimmer Placeholder for Poster
                        Shimmer.fromColors(
                          baseColor: color,
                          highlightColor: Singleton.highlightColor,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: color, // Customize the color here
                            ),
                            height: MediaQuery.of(context).size.width * 0.65,
                            width: MediaQuery.of(context).size.width * 0.4,
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.center,
                                colors: [
                                  Colors.black.withOpacity(0.8),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          Card(
                            color: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Placeholder for Movie Info Rows
                                  Shimmer.fromColors(
                                    baseColor: color,
                                    highlightColor: Singleton.highlightColor,
                                    child: Column(
                                      children: [
                                        SizedBox(height: 10),
                                        Shimmer.fromColors(
                                          baseColor: color,
                                          highlightColor: Singleton.highlightColor,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(10),
                                              color:
                                              color, // Customize the color here
                                            ),
                                            height:
                                            30, // Adjust height as needed
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Shimmer.fromColors(
                                          baseColor: color,
                                          highlightColor: Singleton.highlightColor,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(10),
                                              color:
                                              color, // Customize the color here
                                            ),
                                            height:
                                            30, // Adjust height as needed
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Shimmer.fromColors(
                                          baseColor: color,
                                          highlightColor: Singleton.highlightColor,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(10),
                                              color:
                                              color, // Customize the color here
                                            ),
                                            height:
                                            30, // Adjust height as needed
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Shimmer.fromColors(
                                          baseColor: color,
                                          highlightColor: Singleton.highlightColor,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(10),
                                              color:
                                              color, // Customize the color here
                                            ),
                                            height:
                                            30, // Adjust height as needed
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Shimmer.fromColors(
                                          baseColor: color,
                                          highlightColor: Singleton.highlightColor,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(10),
                                              color:
                                              color, // Customize the color here
                                            ),
                                            height:
                                            30, // Adjust height as needed
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Shimmer.fromColors(
                                          baseColor: color,
                                          highlightColor: Singleton.highlightColor,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(10),
                                              color:
                                              color, // Customize the color here
                                            ),
                                            height:
                                            30, // Adjust height as needed
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Shimmer.fromColors(
                  baseColor: color,
                  highlightColor: Singleton.highlightColor,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Singleton.highlightColor, // Customize the color here
                    ),
                    height: 20,
                    width: 180, // Adjust height as needed
                  ),
                ),
                SizedBox(height: 10),
                Shimmer.fromColors(
                  baseColor: color,
                  highlightColor: Singleton.highlightColor,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Singleton.highlightColor, // Customize the color here
                    ),
                    height: 150, // Adjust height as needed
                  ),
                ),
                SizedBox(height: 10),
                Shimmer.fromColors(
                  baseColor: color,
                  highlightColor: Singleton.highlightColor,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Singleton.highlightColor // Customize the color here
                    ),
                    height: 20,
                    width: 180, // Adjust height as needed
                  ),
                ),
                SizedBox(height: 10),
                // Placeholder for GenreList
                SizedBox(
                  height: 250,
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: 7, // Display 3 shimmer placeholders
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return ShimmerGameItem.buildShimmerMovieItem(color);
                    },
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Shimmer.fromColors(
                  baseColor: color,
                  highlightColor: Singleton.highlightColor,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Singleton.highlightColor, // Customize the color here
                    ),
                    height: 20,
                    width: 180, // Adjust height as needed
                  ),
                ),
                SizedBox(height: 10),
                // Placeholder for ExpansionTile
                SizedBox(
                  height: 250,
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: 7, // Display 3 shimmer placeholders
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return ShimmerGameItem.buildShimmerMovieItem(color);
                    },
                  ),
                ),
                SizedBox(height: 10),
                // Placeholder for WatchProvidersScreen
                Shimmer.fromColors(
                  baseColor: color,
                  highlightColor: Singleton.highlightColor,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Singleton.highlightColor, // Customize the color here
                    ),
                    height: 20,
                    width: 180, // Adjust height as needed
                  ),
                ),
                SizedBox(height: 10),
                Shimmer.fromColors(
                  baseColor: color,
                  highlightColor: Singleton.highlightColor,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Singleton.highlightColor, // Customize the color here
                    ),
                    height: 150, // Adjust height as needed
                  ),
                ),
                SizedBox(height: 10),
                // Placeholder for Banner Ad
                Shimmer.fromColors(
                  baseColor: color,
                  highlightColor: Singleton.highlightColor,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color:Singleton.highlightColor, // Customize the color here
                    ),
                    height: 20,
                    width: 180, // Adjust height as needed
                  ),
                ),
                SizedBox(height: 10),
                Shimmer.fromColors(
                  baseColor: color,
                  highlightColor: Singleton.highlightColor,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Singleton.highlightColor, // Customize the color here
                    ),
                    height: 150, // Adjust height as needed
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}