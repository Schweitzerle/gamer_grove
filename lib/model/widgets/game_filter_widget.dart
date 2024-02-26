import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:bottom_bar_matu/utils/app_utils.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gamer_grove/model/widgets/rating_count_slider.dart';
import 'package:gamer_grove/model/widgets/rating_range_slider.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:multi_select_flutter/bottom_sheet/multi_select_bottom_sheet_field.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../igdb_models/age_rating.dart';
import '../igdb_models/game.dart';
import '../igdb_models/game_mode.dart';
import '../igdb_models/genre.dart';
import '../igdb_models/platform.dart';
import '../igdb_models/player_perspectiverequest_path.dart';
import '../igdb_models/theme.dart';

class GameFilterOptions {
  int minRatings = 0;
  int minTotalRatings = 0;
  int minAggregatedRatings = 0;
  int minFollows = 0;
  int minHypes = 0;
  SfRangeValues releaseDateValues =
      SfRangeValues(DateTime(1947), DateTime.now());
  SfRangeValues ratingValues = const SfRangeValues(0.0, 100.0);
  SfRangeValues totalRatingValues = const SfRangeValues(0.0, 100.0);
  SfRangeValues aggregatedRatingValues = const SfRangeValues(0.0, 100.0);
  List<int?>? selectedAgeRating = [];
  List<int?>? selectedCategory = [];
  List<int?>? selectedGenres = [];
  List<int?>? selectedStatus = [];
  List<int?>? selectedThemes = [];
  List<int?>? selectedGameModes = [];
  List<int?>? selectedPlatforms = [];
  List<int?>? selectedPlayerPerspectives = [];
  List<String?> selectedSorting = ['total_rating_count desc'];

  // Constructor
  GameFilterOptions({
    this.minRatings = 0,
    this.minTotalRatings = 0,
    this.minAggregatedRatings = 0,
    this.minFollows = 0,
    this.minHypes = 0,
    required this.releaseDateValues,
    this.selectedAgeRating,
    this.selectedCategory,
    this.selectedStatus,
    this.selectedGameModes,
    this.selectedThemes,
    this.selectedGenres,
    this.selectedPlatforms,
    this.selectedPlayerPerspectives,
    required this.selectedSorting,
  });
}

enum SortByGame {
  firstReleaseDateAsc,
  firstReleaseDateDesc,
  nameAsc,
  nameDesc,
  aggregatedRatingsAsc,
  aggregatedRatingsDesc,
  aggregatedRatingCountAsc,
  aggregatedRatingCountDesc,
  ratingsAsc,
  ratingsDesc,
  ratingCountAsc,
  ratingCountDesc,
  totalRatingsAsc,
  totalRatingsDesc,
  totalRatingCountAsc,
  totalRatingCountDesc,
  followsAsc,
  followsDesc,
  hypesAsc,
  hypesDesc,
}

extension SortByGameExtension on SortByGame {
  String get value {
    return _ratingToString(this);
  }

  String get valueApi {
    return _ratingToStringApi(this);
  }

  int get intValue {
    return this.index;
  }

  static SortByGame fromString(int value) {
    switch (value) {
      case 0:
        return SortByGame.firstReleaseDateAsc;
      case 1:
        return SortByGame.firstReleaseDateDesc;
      case 2:
        return SortByGame.nameAsc;
      case 3:
        return SortByGame.nameDesc;
      case 4:
        return SortByGame.aggregatedRatingsAsc;
      case 5:
        return SortByGame.aggregatedRatingsDesc;
      case 6:
        return SortByGame.aggregatedRatingCountAsc;
      case 7:
        return SortByGame.aggregatedRatingCountDesc;
      case 8:
        return SortByGame.ratingsAsc;
      case 9:
        return SortByGame.ratingsDesc;
      case 10:
        return SortByGame.ratingCountAsc;
      case 11:
        return SortByGame.ratingCountDesc;
      case 12:
        return SortByGame.totalRatingsAsc;
      case 13:
        return SortByGame.totalRatingsDesc;
      case 14:
        return SortByGame.totalRatingCountAsc;
      case 15:
        return SortByGame.totalRatingCountDesc;
      case 16:
        return SortByGame.followsAsc;
      case 17:
        return SortByGame.followsDesc;
      case 18:
        return SortByGame.hypesAsc;
      case 19:
        return SortByGame.hypesDesc;
      default:
        throw ArgumentError('Invalid value');
    }
  }
}

String _ratingToString(SortByGame? rating) {
  if (rating == null) return 'N/A';
  switch (rating) {
    case SortByGame.firstReleaseDateAsc:
      return 'First Release Date Asc';
    case SortByGame.firstReleaseDateDesc:
      return 'First Release Date Desc';
    case SortByGame.nameAsc:
      return 'Name A-Z';
    case SortByGame.nameDesc:
      return 'Name Z-A';
    case SortByGame.aggregatedRatingsAsc:
      return 'Aggregated Ratings Asc';
    case SortByGame.aggregatedRatingsDesc:
      return 'Aggregated Ratings Desc';
    case SortByGame.aggregatedRatingCountAsc:
      return 'Aggregated Rating Count Asc';
    case SortByGame.aggregatedRatingCountDesc:
      return 'Aggregated Rating Count Desc';
    case SortByGame.ratingsAsc:
      return 'Ratings Asc';
    case SortByGame.ratingsDesc:
      return 'Ratings Desc';
    case SortByGame.ratingCountAsc:
      return 'Rating Count Asc';
    case SortByGame.ratingCountDesc:
      return 'Rating Count Desc';
    case SortByGame.totalRatingsAsc:
      return 'Total Ratings Asc';
    case SortByGame.totalRatingsDesc:
      return 'Total Ratings Desc';
    case SortByGame.totalRatingCountAsc:
      return 'Total Rating Count Asc';
    case SortByGame.totalRatingCountDesc:
      return 'Total Rating Count Desc';
    case SortByGame.followsAsc:
      return 'Follows Asc';
    case SortByGame.followsDesc:
      return 'Follows Desc';
    case SortByGame.hypesAsc:
      return 'Hypes Asc';
    case SortByGame.hypesDesc:
      return 'Hypes Desc';
    default:
      return 'N/A';
  }
}

String _ratingToStringApi(SortByGame? rating) {
  if (rating == null) return 'N/A';
  switch (rating) {
    case SortByGame.firstReleaseDateAsc:
      return 'first_release_date asc';
    case SortByGame.firstReleaseDateDesc:
      return 'first_release_date desc';
    case SortByGame.nameAsc:
      return 'name asc';
    case SortByGame.nameDesc:
      return 'name desc';
    case SortByGame.aggregatedRatingsAsc:
      return 'aggregated_rating asc';
    case SortByGame.aggregatedRatingsDesc:
      return 'aggregated_rating desc';
    case SortByGame.aggregatedRatingCountAsc:
      return 'aggregated_rating_count asc';
    case SortByGame.aggregatedRatingCountDesc:
      return 'aggregated_rating_count desc';
    case SortByGame.ratingsAsc:
      return 'rating asc';
    case SortByGame.ratingsDesc:
      return 'rating desc';
    case SortByGame.ratingCountAsc:
      return 'rating_count asc';
    case SortByGame.ratingCountDesc:
      return 'rating_count desc';
    case SortByGame.totalRatingsAsc:
      return 'total_rating asc';
    case SortByGame.totalRatingsDesc:
      return 'total_rating desc';
    case SortByGame.totalRatingCountAsc:
      return 'total_rating_count asc';
    case SortByGame.totalRatingCountDesc:
      return 'total_rating_count desc';
    case SortByGame.followsAsc:
      return 'follows asc';
    case SortByGame.followsDesc:
      return 'follows desc';
    case SortByGame.hypesAsc:
      return 'hypes asc';
    case SortByGame.hypesDesc:
      return 'hypes desc';
    default:
      return 'N/A';
  }
}

class GameFilterScreen extends StatefulWidget {
  final List<Genre> genres;
  final List<GameMode> gameModes;
  final List<PlatformIGDB> platforms;
  final List<PlayerPerspective> playerPerspectives;
  final List<ThemeIDGB> themes;
  final FloatingSearchBarController searchBarController;
  final PagingController pagingController;
  final GameFilterOptions filterOptions;

  GameFilterScreen(
      {super.key,
      required this.genres,
      required this.gameModes,
      required this.platforms,
      required this.playerPerspectives,
      required this.themes,
      required this.searchBarController,
      required this.pagingController,
      required this.filterOptions});

  @override
  _GameFilterScreenState createState() => _GameFilterScreenState();
}

class _GameFilterScreenState extends State<GameFilterScreen> {
  late int _selectedIndex = 0;
  late int _selectedIndexDropdown = 0;

  @override
  Widget build(BuildContext context) {
    widget.genres.sort((a, b) => a.name!.compareTo(b.name!));
    widget.gameModes.sort((a, b) => a.name!.compareTo(b.name!));
    widget.platforms.sort((a, b) => a.name!.compareTo(b.name!));
    widget.playerPerspectives.sort((a, b) => a.name!.compareTo(b.name!));
    widget.themes.sort((a, b) => a.name!.compareTo(b.name!));

    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;

    Color color = Theme.of(context).colorScheme.tertiaryContainer;
    Color onColor = Theme.of(context).colorScheme.onTertiaryContainer;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ClayContainer(
            spread: 2,
            depth: 60,
            borderRadius: 14,
            color: Theme.of(context).colorScheme.tertiaryContainer,
            parentColor: onColor,
            child: SizedBox(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: MultiSelectDropDown(
                          borderRadius: 14,
                          borderWidth: 4,
                          focusedBorderWidth: 2,
                          focusedBorderColor: color.darken(20),
                          fieldBackgroundColor: color,
                          borderColor: color.darken(20),
                          optionsBackgroundColor: color.lighten(10),
                          selectedOptionBackgroundColor: color.lighten(15),
                          dropdownBorderRadius: 14,
                          hintColor: onColor,
                          hint: 'Sort By',
                          onOptionSelected: (options) {
                            widget.filterOptions.selectedSorting =
                                options.map((item) => item.value).toList();
                          },
                          onOptionRemoved: (index, item) {
                            setState(() {
                              widget.filterOptions.selectedSorting!
                                  .remove(item.value);
                            });
                          },
                          options: SortByGame.values.map((rating) {
                            return ValueItem(
                              label: rating.value,
                              value: rating.valueApi,
                            );
                          }).toList(),
                          maxItems: SortByGame.values.length,
                          selectionType: SelectionType.single,
                          chipConfig: const ChipConfig(wrapType: WrapType.wrap),
                          dropdownHeight: 300,
                          optionTextStyle: const TextStyle(fontSize: 16),
                          selectedOptionIcon: const Icon(Icons.check_circle),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 14,
          ),
          ClayContainer(
            spread: 2,
            depth: 60,
            borderRadius: 14,
            color: color,
            parentColor: onColor,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: mediaQueryHeight * .06,
                    child: AnimatedToggleSwitch<int>.size(
                      current: _selectedIndexDropdown,
                      values: [0, 1],
                      iconOpacity: 0.2,
                      indicatorSize: const Size.fromWidth(100),
                      iconBuilder: iconBuilderDropdown,
                      borderWidth: 4.0,
                      iconAnimationType: AnimationType.onHover,
                      style: ToggleStyle(
                        backgroundColor: color,
                        borderColor: color,
                        borderRadius: BorderRadius.circular(14.0),
                        boxShadow: [
                          BoxShadow(
                            color: color,
                            spreadRadius: 0,
                            blurRadius: 0,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      styleBuilder: styleBuilderDropdown,
                      onChanged: (i) =>
                          setState(() => _selectedIndexDropdown = i),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: mediaQueryHeight * .064),
                  child: SizedBox(
                      child: _selectedIndexDropdown == 0
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: MultiSelectDropDown(
                                        borderRadius: 14,
                                        borderWidth: 4,
                                        focusedBorderWidth: 2,
                                        focusedBorderColor: color.darken(20),
                                        fieldBackgroundColor: color,
                                        borderColor: color.darken(20),
                                        optionsBackgroundColor: color.lighten(10),
                                        selectedOptionBackgroundColor: color.lighten(15),
                                        dropdownBorderRadius: 14,
                                        hintColor: onColor,
                                        hint: 'Age Ratings',
                                        onOptionSelected: (options) {
                                          widget.filterOptions
                                                  .selectedAgeRating =
                                              options
                                                  .map((item) => item.value)
                                                  .toList();
                                        },
                                        onOptionRemoved: (index, item) {
                                          setState(() {
                                            widget.filterOptions
                                                .selectedAgeRating!
                                                .remove(item.value);
                                          });
                                        },
                                        options: AgeRatingRating.values
                                            .map((rating) {
                                          return ValueItem(
                                            label: rating.value,
                                            value: rating.intValue,
                                          );
                                        }).toList(),
                                        maxItems: AgeRatingRating.values.length,
                                        selectionType: SelectionType.single,
                                        chipConfig: const ChipConfig(
                                            wrapType: WrapType.wrap),
                                        dropdownHeight: 300,
                                        optionTextStyle:
                                            const TextStyle(fontSize: 16),
                                        selectedOptionIcon:
                                            const Icon(Icons.check_circle),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: MultiSelectDropDown(
                                        borderRadius: 14,
                                        borderWidth: 4,
                                        focusedBorderWidth: 2,
                                        focusedBorderColor: color.darken(20),
                                        fieldBackgroundColor: color,
                                        borderColor: color.darken(20),
                                        optionsBackgroundColor: color.lighten(10),
                                        selectedOptionBackgroundColor: color.lighten(15),
                                        dropdownBorderRadius: 14,
                                        hintColor: onColor,
                                        hint: 'Category',
                                        onOptionSelected: (options) {
                                          widget.filterOptions
                                                  .selectedCategory =
                                              options
                                                  .map((item) => item.value)
                                                  .toList();
                                        },
                                        onOptionRemoved: (index, item) {
                                          setState(() {
                                            widget
                                                .filterOptions.selectedCategory!
                                                .remove(item.value);
                                          });
                                        },
                                        options: GameCategoryEnum.values
                                            .map((rating) {
                                          return ValueItem(
                                            label: rating.stringValue,
                                            value: rating.value,
                                          );
                                        }).toList(),
                                        maxItems:
                                            GameCategoryEnum.values.length,
                                        selectionType: SelectionType.single,
                                        chipConfig: const ChipConfig(
                                            wrapType: WrapType.wrap),
                                        dropdownHeight: 300,
                                        optionTextStyle:
                                            const TextStyle(fontSize: 16),
                                        selectedOptionIcon:
                                            const Icon(Icons.check_circle),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: MultiSelectDropDown(
                                        borderRadius: 14,
                                        borderWidth: 4,
                                        focusedBorderWidth: 2,
                                        focusedBorderColor: color.darken(20),
                                        fieldBackgroundColor: color,
                                        borderColor: color.darken(20),
                                        optionsBackgroundColor: color.lighten(10),
                                        selectedOptionBackgroundColor: color.lighten(15),
                                        dropdownBorderRadius: 14,
                                        hintColor: onColor,
                                        hint: 'Status',
                                        onOptionSelected: (options) {
                                          widget.filterOptions.selectedStatus =
                                              options
                                                  .map((item) => item.value)
                                                  .toList();
                                        },
                                        onOptionRemoved: (index, item) {
                                          setState(() {
                                            widget.filterOptions.selectedStatus!
                                                .remove(item.value);
                                          });
                                        },
                                        options:
                                            GameStatusEnum.values.map((rating) {
                                          return ValueItem(
                                            label: rating.stringValue,
                                            value: rating.value,
                                          );
                                        }).toList(),
                                        maxItems: GameStatusEnum.values.length,
                                        selectionType: SelectionType.single,
                                        chipConfig: const ChipConfig(
                                            wrapType: WrapType.wrap),
                                        selectedOptionIcon:
                                            const Icon(Icons.check_circle),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : _selectedIndexDropdown == 1
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      widget.themes.isNotEmpty
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child:
                                                  MultiSelectBottomSheetField<
                                                      int?>(
                                                    itemsTextStyle: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            14),
                                                    border: Border.all(
                                                        width: 4,
                                                        color:
                                                            color.darken(10))),
                                                selectedColor: color.darken(20),
                                                initialChildSize: 0.7,
                                                maxChildSize: 0.95,
                                                title: Text("Themes"),
                                                buttonText: Text("Themes"),
                                                items:
                                                    widget.themes.map((rating) {
                                                  return MultiSelectItem(
                                                      rating.id, rating.name!);
                                                }).toList(),
                                                searchable: true,
                                                onConfirm: (values) {
                                                  setState(() {
                                                    widget.filterOptions
                                                            .selectedThemes =
                                                        values;
                                                  });
                                                },
                                                chipDisplay:
                                                    MultiSelectChipDisplay(
                                                      scrollBar: HorizontalScrollBar(),
                                                      scroll: true,
                                                      chipColor: color.darken(10),
                                                      textStyle: TextStyle(color: onColor),
                                                  onTap: (item) {
                                                    setState(() {
                                                      widget.filterOptions
                                                          .selectedThemes!
                                                          .remove(item);
                                                    });
                                                  },
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      widget.genres.isNotEmpty
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child:
                                                  MultiSelectBottomSheetField<
                                                      int?>(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            14),
                                                    border: Border.all(
                                                        width: 4,
                                                        color:
                                                            color.darken(10))),
                                                selectedColor: color.darken(20),
                                                initialChildSize: 0.7,
                                                maxChildSize: 0.95,
                                                title: Text("Genres"),
                                                buttonText: Text("Genres"),
                                                items:
                                                    widget.genres.map((rating) {
                                                  return MultiSelectItem(
                                                      rating.id, rating.name!);
                                                }).toList(),
                                                searchable: true,
                                                onConfirm: (values) {
                                                  setState(() {
                                                    widget.filterOptions
                                                            .selectedGenres =
                                                        values;
                                                  });
                                                },
                                                chipDisplay:
                                                    MultiSelectChipDisplay(
                                                      scrollBar: HorizontalScrollBar(),
                                                      scroll: true,
                                                      chipColor: color.darken(10),
                                                      textStyle: TextStyle(color: onColor),
                                                  onTap: (item) {
                                                    setState(() {
                                                      widget.filterOptions
                                                          .selectedGenres!
                                                          .remove(item);
                                                    });
                                                  },
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      widget.platforms.isNotEmpty
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child:
                                                  MultiSelectBottomSheetField<
                                                      int?>(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            14),
                                                    border: Border.all(
                                                        width: 4,
                                                        color:
                                                            color.darken(10))),
                                                selectedColor: color.darken(20),
                                                initialChildSize: 0.7,
                                                maxChildSize: 0.95,
                                                title: Text("PLatforms"),
                                                buttonText: Text("Platforms"),
                                                items: widget.platforms
                                                    .map((rating) {
                                                  return MultiSelectItem(
                                                      rating.id, rating.name!);
                                                }).toList(),
                                                searchable: true,
                                                onConfirm: (values) {
                                                  setState(() {
                                                    widget.filterOptions
                                                            .selectedPlatforms =
                                                        values;
                                                  });
                                                },
                                                chipDisplay:
                                                    MultiSelectChipDisplay(
                                                      scrollBar: HorizontalScrollBar(),
                                                      scroll: true,
                                                      chipColor: color.darken(10),
                                                      textStyle: TextStyle(color: onColor),
                                                  onTap: (item) {
                                                    setState(() {
                                                      widget.filterOptions
                                                          .selectedPlatforms!
                                                          .remove(item);
                                                    });
                                                  },
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      widget.gameModes.isNotEmpty
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child:
                                                  MultiSelectBottomSheetField<
                                                      int?>(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            14),
                                                    border: Border.all(
                                                        width: 4,
                                                        color:
                                                            color.darken(10))),
                                                selectedColor: color.darken(20),
                                                initialChildSize: 0.7,
                                                maxChildSize: 0.95,
                                                title: Text("Game Modes"),
                                                buttonText: Text("Game Modes"),
                                                items: widget.gameModes
                                                    .map((rating) {
                                                  return MultiSelectItem(
                                                      rating.id, rating.name!);
                                                }).toList(),
                                                searchable: true,
                                                onConfirm: (values) {
                                                  setState(() {
                                                    widget.filterOptions
                                                            .selectedGameModes =
                                                        values;
                                                  });
                                                },
                                                chipDisplay:
                                                    MultiSelectChipDisplay(
                                                      scrollBar: HorizontalScrollBar(),
                                                      scroll: true,
                                                      chipColor: color.darken(10),
                                                      textStyle: TextStyle(color: onColor),
                                                  onTap: (item) {
                                                    setState(() {
                                                      widget.filterOptions
                                                          .selectedGameModes!
                                                          .remove(item);
                                                    });
                                                  },
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      widget.playerPerspectives.isNotEmpty
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child:
                                                  MultiSelectBottomSheetField<
                                                      int?>(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            14),
                                                    border: Border.all(
                                                        width: 4,
                                                        color:
                                                            color.darken(10))),
                                                selectedColor: color.darken(20),
                                                initialChildSize: 0.7,
                                                maxChildSize: 0.95,
                                                title:
                                                    Text("Player Perspective"),
                                                buttonText:
                                                    Text("Player Perspective"),
                                                items: widget.playerPerspectives
                                                    .map((rating) {
                                                  return MultiSelectItem(
                                                      rating.id, rating.name!);
                                                }).toList(),
                                                searchable: true,
                                                onConfirm: (values) {
                                                  setState(() {
                                                    widget.filterOptions
                                                            .selectedPlayerPerspectives =
                                                        values;
                                                  });
                                                },
                                                chipDisplay:
                                                    MultiSelectChipDisplay(
                                                      scrollBar: HorizontalScrollBar(),
                                                      scroll: true,
                                                      chipColor: color.darken(10),
                                                      textStyle: TextStyle(color: onColor),
                                                  onTap: (item) {
                                                    setState(() {
                                                      widget.filterOptions
                                                          .selectedPlayerPerspectives!
                                                          .remove(item);
                                                    });
                                                  },
                                                ),
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                )
                              : Container()),
                )
              ],
            ),
          ),
          SizedBox(
            height: 14,
          ),
          ClayContainer(
            spread: 2,
            depth: 60,
            borderRadius: 14,
            color: color,
            parentColor: onColor,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: mediaQueryHeight * .06,
                    child: AnimatedToggleSwitch<int>.size(
                      current: _selectedIndex,
                      values: [0, 1, 2],
                      iconOpacity: 0.2,
                      indicatorSize: const Size.fromWidth(100),
                      iconBuilder: iconBuilder,
                      borderWidth: 4.0,
                      iconAnimationType: AnimationType.onHover,
                      style: ToggleStyle(
                        backgroundColor: color,
                        borderColor: color,
                        borderRadius: BorderRadius.circular(14.0),
                        boxShadow: [
                          BoxShadow(
                            color: color,
                            spreadRadius: 0,
                            blurRadius: 0,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      styleBuilder: styleBuilder,
                      onChanged: (i) => setState(() => _selectedIndex = i),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: mediaQueryHeight * .064),
                  child: SizedBox(
                      child: _selectedIndex == 0
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  RatingCountSlider(
                                    title: 'Minimum Follows',
                                    value: widget.filterOptions.minFollows
                                        .toDouble(),
                                    onChanged: (int value) {
                                      setState(() {
                                        widget.filterOptions.minFollows = value;
                                      });
                                    },
                                  ),
                                  RatingCountSlider(
                                    title: 'Minimum Hypes',
                                    value: widget.filterOptions.minHypes
                                        .toDouble(),
                                    onChanged: (int value) {
                                      setState(() {
                                        widget.filterOptions.minHypes = value;
                                      });
                                    },
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Selected Dates: ${DateFormat('yyyy-MM-dd').format(widget.filterOptions.releaseDateValues.start)} - ${DateFormat('yyyy-MM-dd').format(widget.filterOptions.releaseDateValues.end)}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SfRangeSlider(
                                        min: DateTime(1947),
                                        max: DateTime.now()
                                            .add(Duration(days: 365)),
                                        values: widget
                                            .filterOptions.releaseDateValues,
                                        interval: 15,
                                        showTicks: true,
                                        showLabels: true,
                                        minorTicksPerInterval: 1,
                                        dateFormat: DateFormat.y(),
                                        dateIntervalType:
                                            DateIntervalType.years,
                                        onChanged: (SfRangeValues values) {
                                          setState(() {
                                            widget.filterOptions
                                                .releaseDateValues = values;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : _selectedIndex == 1
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      RatingRangeSlider(
                                        title: 'Rating Range',
                                        values:
                                            widget.filterOptions.ratingValues,
                                        onChanged: (SfRangeValues values) {
                                          setState(() {
                                            widget.filterOptions.ratingValues =
                                                values;
                                          });
                                        },
                                      ),
                                      RatingRangeSlider(
                                        title: 'Critics Rating Range',
                                        values: widget.filterOptions
                                            .aggregatedRatingValues,
                                        onChanged: (SfRangeValues values) {
                                          setState(() {
                                            widget.filterOptions
                                                    .aggregatedRatingValues =
                                                values;
                                          });
                                        },
                                      ),
                                      RatingRangeSlider(
                                        title: 'Total Rating Range',
                                        values: widget
                                            .filterOptions.totalRatingValues,
                                        onChanged: (SfRangeValues values) {
                                          setState(() {
                                            widget.filterOptions
                                                .totalRatingValues = values;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      RatingCountSlider(
                                        title: 'Minimum User Rating Count',
                                        value: widget.filterOptions.minRatings
                                            .toDouble(),
                                        onChanged: (int value) {
                                          setState(() {
                                            widget.filterOptions.minRatings =
                                                value;
                                          });
                                        },
                                      ),
                                      RatingCountSlider(
                                        title: 'Minimum Critics Rating Count',
                                        value: widget
                                            .filterOptions.minAggregatedRatings
                                            .toDouble(),
                                        onChanged: (int value) {
                                          setState(() {
                                            widget.filterOptions
                                                .minAggregatedRatings = value;
                                          });
                                        },
                                      ),
                                      RatingCountSlider(
                                        title: 'Minimum Total Rating Count',
                                        value: widget
                                            .filterOptions.minTotalRatings
                                            .toDouble(),
                                        onChanged: (int value) {
                                          setState(() {
                                            widget.filterOptions
                                                .minTotalRatings = value;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                )),
                )
              ],
            ),
          ),
          SizedBox(
            height: 14,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.searchBarController.close();
                    setState(() {});
                  },
                  child: FittedBox(child: Text('Cancel')),
                ),
              ),
              const SizedBox(width: 8,),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      widget.filterOptions.releaseDateValues = SfRangeValues(
                          DateTime(1947),
                          DateTime.now().add(Duration(days: 365)));
                      widget.filterOptions.selectedGameModes!.clear();
                      widget.filterOptions.selectedSorting.clear();
                      widget.filterOptions.selectedPlayerPerspectives!.clear();
                      widget.filterOptions.selectedPlatforms!.clear();
                      widget.filterOptions.selectedGenres!.clear();
                      widget.filterOptions.selectedThemes!.clear();
                      widget.filterOptions.selectedCategory!.clear();
                      widget.filterOptions.selectedAgeRating!.clear();
                      widget.filterOptions.selectedStatus!.clear();
                      widget.filterOptions.minRatings = 0;
                      widget.filterOptions.minTotalRatings = 0;
                      widget.filterOptions.minAggregatedRatings = 0;
                      widget.filterOptions.minFollows = 0;
                      widget.filterOptions.minHypes = 0;
                      widget.filterOptions.ratingValues = const SfRangeValues(0.0, 100.0);
                      widget.filterOptions.aggregatedRatingValues = const SfRangeValues(0.0, 100.0);
                      widget.filterOptions.totalRatingValues = const SfRangeValues(0.0, 100.0);
                    });
                    widget.pagingController.refresh();
                  },
                  child: FittedBox(child: Text('Reset Game Filter')),
                ),
              ),
              const SizedBox(width: 8,),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.searchBarController.close();
                    widget.pagingController.refresh();
                  },
                  child: FittedBox(child: Text('Apply')),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  String parseToDouble(double value) {
    return value.toStringAsPrecision(1);
  }

  Widget iconBuilder(int index) {
    IconData iconData;
    switch (index) {
      case 0:
        iconData = FontAwesomeIcons.fireFlameCurved;
        break;
      case 1:
        iconData = Icons.score_outlined;
        break;
      case 2:
        iconData = Icons.scoreboard_outlined;
        break;
      default:
        iconData = Icons.score_outlined;
    }

    return Icon(
      iconData,
      color: Theme.of(context)
          .colorScheme
          .onTertiaryContainer, // Adjust colors as needed
    );
  }

  ToggleStyle styleBuilder(int value) {
    return ToggleStyle(
      indicatorColor: Theme.of(context).colorScheme.tertiary.withOpacity(.6),
      borderColor: Colors.transparent,
      borderRadius: BorderRadius.circular(14.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          spreadRadius: 1,
          blurRadius: 2,
          offset: Offset(0, 1.5),
        ),
      ],
    );
  }

  Widget iconBuilderDropdown(int index) {
    IconData iconData;
    switch (index) {
      case 0:
        iconData = FontAwesomeIcons.circleInfo;
        break;
      case 1:
        iconData = FontAwesomeIcons.gamepad;
        break;
      default:
        iconData = Icons.score_outlined;
    }

    return Icon(
      iconData,
      color: Theme.of(context)
          .colorScheme
          .onTertiaryContainer, // Adjust colors as needed
    );
  }

  ToggleStyle styleBuilderDropdown(int value) {
    return ToggleStyle(
      indicatorColor: Theme.of(context).colorScheme.tertiary.withOpacity(.6),
      borderColor: Colors.transparent,
      borderRadius: BorderRadius.circular(14.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          spreadRadius: 1,
          blurRadius: 2,
          offset: Offset(0, 1.5),
        ),
      ],
    );
  }
}
