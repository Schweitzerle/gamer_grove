import 'package:carousel_slider/carousel_slider.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerItem {
  static Widget buildShimmerHomeScreenItem(BuildContext context) {
    Color color = Theme.of(context).colorScheme.primaryContainer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 40),
        ),
        ShimmerGlassContainerEventCarousel(color: color),
        ShimmerGlassContainerGameList(color: color,),
        ShimmerGlassContainerGameList(color: color,),
        ShimmerGlassContainerGameList(color: color,),
      ],
    );
  }

  static Widget buildShimmerWishlistScreenItem(BuildContext context) {
    Color color = Theme.of(context).colorScheme.primaryContainer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        buildShimmerTopThreeGamesItem(context),
        const SizedBox(
          height: 14,
        ),
        ShimmerGlassContainerGameList(color: color,),
        ShimmerGlassContainerGameList(color: color,),
        ShimmerGlassContainerGameList(color: color,),
      ],
    );
  }

  static Widget buildShimmerGameGridItem(BuildContext context) {
    Color color = Theme.of(context).colorScheme.primaryContainer;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: .74,
          crossAxisCount: 2,
        ),
        itemBuilder: (context, index) {
          return ShimmerGlassContainerGame(
            needsRating: true, color: color,
          ); // Entfernen Sie das 'const' Keyword hier
        },
        itemCount: 10,
      ),
    );
  }

  static Widget buildShimmerTopThreeGamesItem(BuildContext context) {
    Color color = Theme.of(context).colorScheme.primaryContainer;
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    Color secondColor = color.computeLuminance() <= 0.5 ? color.lighten(10) : color.darken(10);
    return  Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * .04,
          width: MediaQuery.of(context).size.width * .42,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 3,
                child: GlassContainer(
                  blur: 12,
                  borderRadius: BorderRadius.circular(14),
                  color: color
                      .withOpacity(.2),
                  child: Shimmer.fromColors(
                    baseColor: Colors.transparent,
                    highlightColor:
                    color.onColor,
                    child: Container(
                      color: secondColor
                          .withOpacity(.8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Row(
          children: [
            Expanded(
                flex: 5,
                child: SizedBox(
                    height: mediaQueryHeight * .21,
                    child: const ShimmerGlassContainerGameTopGames(
                      needsRating: false,
                    ))),
            Expanded(
                flex: 6,
                child: SizedBox(
                    height: mediaQueryHeight * .26,
                    child: const ShimmerGlassContainerGameTopGames(
                      needsRating: false,
                    ))),
            Expanded(
                flex: 4,
                child: SizedBox(
                    height: mediaQueryHeight * .16,
                    child: const ShimmerGlassContainerGameTopGames(
                      needsRating: false,
                    ))),
          ],
        ),
      ],
    );
  }

  static Widget buildShimmerCompanyGridItem(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemBuilder: (context, index) {
          return const ShimmerGlassContainerCompany(); // Entfernen Sie das 'const' Keyword hier
        },
        itemCount: 10,
      ),
    );
  }

  static Widget buildShimmerEventGridItem(BuildContext context) {
    Color color = Theme.of(context).colorScheme.primaryContainer;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 1.4,
          crossAxisCount: 2,
        ),
        itemBuilder: (context, index) {
          return ShimmerGlassContainerEvent(color: color,); // Entfernen Sie das 'const' Keyword hier
        },
        itemCount: 10,
      ),
    );
  }

  static Widget buildShimmerGameDetailScreen(BuildContext context, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 14),
        ),
        ShimmerGlassContainerToggleInfo(color: color,),
        ShimmerGlassContainerToggleCollection(color: color),
        ShimmerGlassContainerToggleGames(color: color),
        ShimmerGlassContainerToggleImages(color: color)
      ],
    );
  }

  static Widget buildShimmerEventDetailScreen(BuildContext context, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 14),
        ),
        ShimmerGlassContainerToggleInfo(color: color,),
        ShimmerGlassContainerToggleCollection(color: color),
        ShimmerGlassContainerToggleGames(color: color),
      ],
    );
  }

  static Widget buildShimmerCompanyDetailScreen(BuildContext context, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 14),
        ),
        ShimmerGlassContainerToggleInfo(color: color,),
        ShimmerGlassContainerToggleGames(color: color,),
      ],
    );
  }
}

class ShimmerGlassContainerEventCarousel extends StatelessWidget {
  final Color color;
  const ShimmerGlassContainerEventCarousel({required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Color secondColor = color.computeLuminance() <= 0.5 ? color.lighten(10) : color.darken(10);
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.only(bottom: mediaQueryHeight * 0.01),
      child: CarouselSlider(
        options: CarouselOptions(
          autoPlayInterval: const Duration(seconds: 10),
          autoPlayAnimationDuration: const Duration(milliseconds: 4500),
          autoPlay: true,
          enableInfiniteScroll: true,
          enlargeCenterPage: true,
          viewportFraction: 0.8,
          enlargeFactor: .3,
        ),
        items: List.generate(3, (index) {
          return ShimmerGlassContainerEvent(color: color);
        }),
      ),
    );
  }
}

class ShimmerGlassContainerGameList extends StatelessWidget {
  final Color color;
  const ShimmerGlassContainerGameList({required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Color secondColor = color.computeLuminance() <= 0.5 ? color.lighten(10) : color.darken(10);
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final coverScaleHeight = mediaQueryHeight / 3.1;
    final coverScaleWidth = coverScaleHeight * 0.69;
    return Container(
      margin: EdgeInsets.only(bottom: mediaQueryHeight * 0.01),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GlassContainer(
              height: mediaQueryHeight * .05,
              width: mediaQueryHeight * .2,
              blur: 12,
              borderRadius: BorderRadius.circular(14),
              color: color
                  .withOpacity(.2),
              child: Shimmer.fromColors(
                baseColor: Colors.transparent,
                highlightColor:color.onColor,
                child: Container(
                  color: secondColor
                      .withOpacity(.8),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: 4,
              itemBuilder: (context, index) {
                return ShimmerGlassContainerGame(
                  needsRating: true, color: color,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerGlassContainerGame extends StatelessWidget {
  final bool needsRating;
  final Color color;

  const ShimmerGlassContainerGame({
    super.key,
    required this.needsRating,
    required this.color
  });

  @override
  Widget build(BuildContext context) {
    Color secondColor = color.computeLuminance() <= 0.5 ? color.lighten(10) : color.darken(10);
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final coverScaleHeight = mediaQueryHeight / 3.1;
    final coverScaleWidth = coverScaleHeight * 0.69;
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: AspectRatio(
            aspectRatio: 9 / 13,
            child: GlassContainer(
              blur: 12,
              borderRadius: BorderRadius.circular(14),
              color:
                  secondColor.withOpacity(.2),
              child: Stack(
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.transparent,
                    highlightColor:
                        secondColor.onColor,
                    child: Container(
                        decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: secondColor
                          .withOpacity(.8),
                    )),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height: needsRating
                          ? mediaQueryHeight * .06
                          : mediaQueryHeight * .04,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (needsRating)
                              Expanded(
                                flex: 3,
                                child: GlassContainer(
                                  blur: 12,
                                  borderRadius: BorderRadius.circular(14),
                                  color: color
                                      .withOpacity(.2),
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.transparent,
                                    highlightColor: color.onColor,
                                    child: Container(
                                      color: secondColor
                                          .withOpacity(.8),
                                    ),
                                  ),
                                ),
                              ),
                            if (needsRating) const SizedBox(width: 8),
                            Expanded(
                              flex: 5,
                              child: GlassContainer(
                                blur: 12,
                                borderRadius: BorderRadius.circular(14),
                                color: color
                                    .withOpacity(.2),
                                child: Shimmer.fromColors(
                                  baseColor: Colors.transparent,
                                  highlightColor: color.onColor,
                                  child: Container(
                                    color: secondColor
                                        .withOpacity(.8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}


class ShimmerGlassContainerGameTopGames extends StatelessWidget {
  final bool needsRating;

  const ShimmerGlassContainerGameTopGames({
    super.key,
    required this.needsRating,
  });

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).colorScheme.primaryContainer;
    Color secondColor = color.computeLuminance() <= 0.5 ? color.lighten(10) : color.darken(10);
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final coverScaleHeight = mediaQueryHeight / 3.1;
    final coverScaleWidth = coverScaleHeight * 0.69;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GlassContainer(
        height: coverScaleHeight,
        width: coverScaleWidth,
        blur: 12,
        borderRadius: BorderRadius.circular(14),
        color:
        color.withOpacity(.2),
        child: Stack(
          children: [
            Shimmer.fromColors(
              baseColor: Colors.transparent,
              highlightColor:
              color.onColor,
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: secondColor
                        .withOpacity(.8),
                  )),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: needsRating
                    ? mediaQueryHeight * .06
                    : mediaQueryHeight * .04,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (needsRating)
                        Expanded(
                          flex: 3,
                          child: GlassContainer(
                            blur: 12,
                            borderRadius: BorderRadius.circular(14),
                            color: color
                                .withOpacity(.2),
                            child: Shimmer.fromColors(
                              baseColor: Colors.transparent,
                              highlightColor: color.onColor,
                              child: Container(
                                color: secondColor
                                    .withOpacity(.8),
                              ),
                            ),
                          ),
                        ),
                      if (needsRating) const SizedBox(width: 8),
                      Expanded(
                        flex: 5,
                        child: GlassContainer(
                          blur: 12,
                          borderRadius: BorderRadius.circular(14),
                          color: color
                              .withOpacity(.2),
                          child: Shimmer.fromColors(
                            baseColor: Colors.transparent,
                            highlightColor: color.onColor,
                            child: Container(
                              color: secondColor
                                  .withOpacity(.8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerGlassContainerCompany extends StatelessWidget {
  const ShimmerGlassContainerCompany({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).colorScheme.primaryContainer;
    Color secondColor = color.computeLuminance() <= 0.5 ? color.lighten(10) : color.darken(10);
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    const coverScaleHeight = 200;
    const coverScaleWidth = coverScaleHeight;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GlassContainer(
        height: coverScaleHeight.toDouble(),
        width: coverScaleWidth.toDouble(),
        blur: 12,
        borderRadius: BorderRadius.circular(14),
        color: color.withOpacity(.2),
        child: Stack(
          children: [
            Shimmer.fromColors(
              baseColor: Colors.transparent,
              highlightColor: color.onColor,
              child: Container(
                  decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: secondColor
                    .withOpacity(.8),
              )),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: mediaQueryHeight * .06,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        flex: 3,
                        child: GlassContainer(
                          blur: 12,
                          borderRadius: BorderRadius.circular(14),
                          color: color
                              .withOpacity(.2),
                          child: Shimmer.fromColors(
                            baseColor: Colors.transparent,
                            highlightColor: color.onColor,
                            child: Container(
                              color: secondColor
                                  .withOpacity(.8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerGlassContainerEvent extends StatelessWidget {
  final Color color;

  const ShimmerGlassContainerEvent({required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Color secondColor = color.computeLuminance() <= 0.5 ? color.lighten(10) : color.darken(10);
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: GlassContainer(
            blur: 12,
            borderRadius: BorderRadius.circular(14),
            color:
                color.withOpacity(.2),
            child: Stack(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.transparent,
                  highlightColor:
                      color.onColor,
                  child: Container(
                      decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: secondColor
                        .withOpacity(.8),
                  )),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: mediaQueryHeight * .07,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            flex: 3,
                            child: GlassContainer(
                              blur: 12,
                              borderRadius: BorderRadius.circular(14),
                              color: color
                                  .withOpacity(.2),
                              child: Shimmer.fromColors(
                                baseColor: Colors.transparent,
                                highlightColor: color.onColor,
                                child: Container(
                                  color: secondColor
                                      .withOpacity(.8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 5,
                            child: GlassContainer(
                              blur: 12,
                              borderRadius: BorderRadius.circular(14),
                              color: color
                                  .withOpacity(.2),
                              child: Shimmer.fromColors(
                                baseColor: Colors.transparent,
                                highlightColor: color.onColor,
                                child: Container(
                                  color: secondColor
                                      .withOpacity(.8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class ShimmerGlassContainerToggleInfo extends StatelessWidget {
  final Color color;

  const ShimmerGlassContainerToggleInfo({ required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    Color secondColor = color.computeLuminance() <= 0.5 ? color.lighten(10) : color.darken(10);
    return Container(
      height: mediaQueryHeight * .16,
      padding: const EdgeInsets.only(right: 16.0, left: 16, top: 24),
      child: GlassContainer(
        blur: 12,
        borderRadius: BorderRadius.circular(14),
        color: color.withOpacity(.2),
        child: Stack(
          children: [
            Shimmer.fromColors(
              baseColor: Colors.transparent,
              highlightColor: secondColor.onColor,
              child: Container(
                  decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: secondColor
                    .withOpacity(.8),
              )),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: mediaQueryHeight * .07,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (int i = 0; i < 5; i++)
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2.0),
                            child: GlassContainer(
                              blur: 12,
                              borderRadius: BorderRadius.circular(14),
                              color: color
                                  .withOpacity(.2),
                              child: Shimmer.fromColors(
                                baseColor: Colors.transparent,
                                highlightColor:color.onColor,
                                child: Container(
                                  color: secondColor
                                      .withOpacity(.8),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: mediaQueryHeight * .07,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        flex: 1,
                        child: GlassContainer(
                          blur: 12,
                          borderRadius: BorderRadius.circular(14),
                          color: color
                              .withOpacity(.2),
                          child: Shimmer.fromColors(
                            baseColor: Colors.transparent,
                            highlightColor:color.onColor,
                            child: Container(
                              color: secondColor
                                  .withOpacity(.8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerGlassContainerToggleCollection extends StatelessWidget {
  final Color color;

  const ShimmerGlassContainerToggleCollection({ required this.color,
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    Color secondColor = color.computeLuminance() <= 0.5 ? color.lighten(10) : color.darken(10);
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final coverScaleHeight = mediaQueryHeight / 3.1;
    final coverScaleWidth = coverScaleHeight * 0.69;
    return Padding(
      padding: const EdgeInsets.only(right: 16.0, left: 16, top: 24),
      child: GlassContainer(
        blur: 12,
        borderRadius: BorderRadius.circular(14),
        color: color.withOpacity(.2),
        child: Stack(
          children: [
            Shimmer.fromColors(
              baseColor: Colors.transparent,
              highlightColor: secondColor.onColor,
              child: Container(
                  decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: secondColor
                    .withOpacity(.8),
              )),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  SizedBox(
                    height: mediaQueryHeight * .07,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(flex: 1, child: Container()),
                          for (int i = 0; i < 4; i++)
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2.0),
                                child: GlassContainer(
                                  blur: 12,
                                  borderRadius: BorderRadius.circular(14),
                                  color: color
                                      .withOpacity(.2),
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.transparent,
                                    highlightColor: color.onColor,
                                    child: Container(
                                      color: secondColor
                                          .withOpacity(.8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 7,
                          child: GlassContainer(
                            blur: 12,
                            height: mediaQueryHeight * .2,
                            borderRadius: BorderRadius.circular(14),
                            color: color
                                .withOpacity(.2),
                            child: Shimmer.fromColors(
                              baseColor: Colors.transparent,
                              highlightColor: color.onColor,
                              child: Container(
                                color: secondColor
                                    .withOpacity(.8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: GlassContainer(
                            blur: 12,
                            height: mediaQueryHeight * .09,
                            borderRadius: BorderRadius.circular(14),
                            color:  color
                                .withOpacity(.2),
                            child: Shimmer.fromColors(
                              baseColor: Colors.transparent,
                              highlightColor: color.onColor,
                              child: Container(
                                color: secondColor
                                    .withOpacity(.8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerGlassContainerToggleGames extends StatelessWidget {
  final Color color;

  const ShimmerGlassContainerToggleGames({required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Color secondColor = color.computeLuminance() <= 0.5 ? color.lighten(10) : color.darken(10);
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final coverScaleHeight = mediaQueryHeight / 3.1;
    final coverScaleWidth = coverScaleHeight * 0.69;
    return Padding(
      padding: const EdgeInsets.only(right: 16.0, left: 16, top: 24),
      child: GlassContainer(
        blur: 12,
        borderRadius: BorderRadius.circular(14),
        color: color.withOpacity(.2),
        child: Stack(
          children: [
            Shimmer.fromColors(
              baseColor: Colors.transparent,
              highlightColor: secondColor.onColor,
              child: Container(
                  decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: secondColor
                    .withOpacity(.8),
              )),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  SizedBox(
                    height: mediaQueryHeight * .07,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(flex: 1, child: Container()),
                          for (int i = 0; i < 4; i++)
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2.0),
                                child: GlassContainer(
                                  blur: 12,
                                  borderRadius: BorderRadius.circular(14),
                                  color: color
                                      .withOpacity(.2),
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.transparent,
                                    highlightColor: color.onColor,
                                    child: Container(
                                      color: secondColor
                                          .withOpacity(.8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  ShimmerGlassContainerGameList(color: color,)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerGlassContainerToggleImages extends StatelessWidget {
  final Color color;
  const ShimmerGlassContainerToggleImages({required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Color secondColor = color.computeLuminance() <= 0.5 ? color.lighten(10) : color.darken(10);
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final coverScaleHeight = mediaQueryHeight / 3.1;
    final coverScaleWidth = coverScaleHeight * 0.69;
    return Padding(
      padding: const EdgeInsets.only(right: 16.0, left: 16, top: 24),
      child: GlassContainer(
        blur: 12,
        borderRadius: BorderRadius.circular(14),
        color: color.withOpacity(.2),
        child: Stack(
          children: [
            Shimmer.fromColors(
              baseColor: Colors.transparent,
              highlightColor: secondColor.onColor,
              child: Container(
                  decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: secondColor
                    .withOpacity(.8),
              )),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  SizedBox(
                    height: mediaQueryHeight * .07,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(flex: 2, child: Container()),
                          for (int i = 0; i < 2; i++)
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2.0),
                                child: GlassContainer(
                                  blur: 12,
                                  borderRadius: BorderRadius.circular(14),
                                  color: color
                                      .withOpacity(.2),
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.transparent,
                                    highlightColor: color.onColor,
                                    child: Container(
                                      color: secondColor
                                          .withOpacity(.8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: StaggeredGrid.count(
                      crossAxisCount: 4,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      children: [
                        StaggeredGridTile.count(
                          crossAxisCellCount: 4,
                          mainAxisCellCount: 2,
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            // Aspect ratio for the first artwork
                            child: GlassContainer(
                              blur: 12,
                              borderRadius: BorderRadius.circular(14),
                              color: color
                                  .withOpacity(.2),
                              child: Shimmer.fromColors(
                                baseColor: Colors.transparent,
                                highlightColor: color.onColor,
                                child: Container(
                                  color: secondColor
                                      .withOpacity(.8),
                                ),
                              ),
                            ),
                          ),
                        ),
                        StaggeredGridTile.count(
                          crossAxisCellCount: 2,
                          mainAxisCellCount: 2,
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            // Aspect ratio for the second artwork
                            child: GlassContainer(
                              blur: 12,
                              borderRadius: BorderRadius.circular(14),
                              color: color
                                  .withOpacity(.2),
                              child: Shimmer.fromColors(
                                baseColor: Colors.transparent,
                                highlightColor: color.onColor,
                                child: Container(
                                  color: secondColor
                                      .withOpacity(.8),
                                ),
                              ),
                            ),
                          ),
                        ),
                        StaggeredGridTile.count(
                          crossAxisCellCount: 2,
                          mainAxisCellCount: 1,
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            // Aspect ratio for the second artwork
                            child: GlassContainer(
                              blur: 12,
                              borderRadius: BorderRadius.circular(14),
                              color: color
                                  .withOpacity(.2),
                              child: Shimmer.fromColors(
                                baseColor: Colors.transparent,
                                highlightColor: color.onColor,
                                child: Container(
                                  color: secondColor
                                      .withOpacity(.8),
                                ),
                              ),
                            ),
                          ),
                        ),
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 1,
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            // Aspect ratio for the fifth artwork
                            child: GlassContainer(
                              blur: 12,
                              borderRadius: BorderRadius.circular(14),
                              color: color
                                  .withOpacity(.2),
                              child: Shimmer.fromColors(
                                baseColor: Colors.transparent,
                                highlightColor: color.onColor,
                                child: Container(
                                  color: secondColor
                                      .withOpacity(.8),
                                ),
                              ),
                            ),
                          ),
                        ),
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 1,
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            // Aspect ratio for the fourth artwork
                            child: GlassContainer(
                              blur: 12,
                              borderRadius: BorderRadius.circular(14),
                              color: color
                                  .withOpacity(.2),
                              child: Shimmer.fromColors(
                                baseColor: Colors.transparent,
                                highlightColor: color.onColor,
                                child: Container(
                                  color: secondColor
                                      .withOpacity(.8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerUserItem extends StatelessWidget {
  const ShimmerUserItem({super.key});

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).colorScheme.primaryContainer;
    Color secondColor = color.computeLuminance() <= 0.5 ? color.lighten(10) : color.darken(10);
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        GlassContainer(
          height: 80,
          blur: 12,
          borderRadius: BorderRadius.circular(14),
          color:
              secondColor.withOpacity(.2),
          child: Stack(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.transparent,
                highlightColor:
                    secondColor.onColor,
                child: Container(
                    decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: color
                      .withOpacity(.8),
                )),
              ),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GlassContainer(
                        blur: 12,
                        width: mediaQueryHeight * .065,
                        borderRadius: BorderRadius.circular(90),
                        color: color
                            .withOpacity(.2),
                        child: Shimmer.fromColors(
                          baseColor: Colors.transparent,
                          highlightColor:
                              color.onColor,
                          child: Container(
                            color: secondColor
                                .withOpacity(.8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Expanded(
                                child: GlassContainer(
                                  blur: 12,
                                  borderRadius: BorderRadius.circular(14),
                                  color: color
                                      .withOpacity(.2),
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.transparent,
                                    highlightColor: color.onColor,
                                    child: Container(
                                      color: secondColor
                                          .withOpacity(.8),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 7,
                              ),
                              Expanded(
                                child: GlassContainer(
                                  blur: 12,
                                  borderRadius: BorderRadius.circular(14),
                                  color: color
                                      .withOpacity(.2),
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.transparent,
                                    highlightColor: color.onColor,
                                    child: Container(
                                      color: secondColor
                                          .withOpacity(.8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
    );
  }
}
