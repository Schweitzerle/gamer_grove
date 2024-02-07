import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../singleton/sinlgleton.dart';

class ShimmerGameItem{
  static Widget buildShimmerMovieItem(Color color) {
    return Shimmer.fromColors(
      baseColor: color,
      highlightColor: Singleton.highlightColor,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 160, // Adjust the width as needed
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black,
        ),
      ),
    );
  }
}