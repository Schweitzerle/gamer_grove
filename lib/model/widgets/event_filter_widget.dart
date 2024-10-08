import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class EventFilterOptions {
  SfRangeValues values;
  List<String?> selectedSorting = [];

  EventFilterOptions({
    required this.values,
    required this.selectedSorting,
  });
}

enum SortByEvent {
  nameAsc,
  nameDesc,
  startDateAsc,
  startDateDesc,
}
extension SortByEventExtension on SortByEvent {
  String get value {
    // Changed to String
    return _ratingToString(this);
  }

  String get valueApi {
  return _ratingToStringApi(this);  
  }
  
  int get intValue {
    return this.index;
  }

  static SortByEvent fromString(int value) {
    // Changed parameter type to int
    switch (value) {
      case 0:
        return SortByEvent.startDateAsc;
      case 1:
        return SortByEvent.startDateDesc;
      case 2:
        return SortByEvent.nameAsc;
      case 3:
        return SortByEvent.nameDesc;
      default:
        throw ArgumentError('Invalid value');
    }
  }
}

String _ratingToString(SortByEvent? rating) {
  if (rating == null) return 'N/A';
  switch (rating) {
    case SortByEvent.startDateAsc:
      return 'Event Date ⬆️';
    case SortByEvent.startDateDesc:
      return 'Event Date ⬇️';
    case SortByEvent.nameAsc:
      return 'Name A-Z';
    case SortByEvent.nameDesc:
      return 'Name Z-A';
    default:
      return 'N/A';
  }
}

String _ratingToStringApi(SortByEvent? rating) {
  if (rating == null) return 'N/A';
  switch (rating) {
    case SortByEvent.startDateAsc:
      return 'start_time asc';
    case SortByEvent.startDateDesc:
      return 'start_time desc';
    case SortByEvent.nameAsc:
      return 'name asc';
    case SortByEvent.nameDesc:
      return 'name desc';
    default:
      return 'N/A';
  }
}

class EventFilterScreen extends StatefulWidget {
  final FloatingSearchBarController searchBarController;
  final PagingController pagingController;
  final EventFilterOptions filterOptions;

  EventFilterScreen({
    Key? key,
    required this.searchBarController,
    required this.pagingController,
    required this.filterOptions,
  }) : super(key: key);

  @override
  _EventFilterScreenState createState() => _EventFilterScreenState();
}

class _EventFilterScreenState extends State<EventFilterScreen> {
  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;

    Color color = Theme.of(context).colorScheme.inversePrimary.darken(10);
    Color onColor = color.onColor;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ClayContainer(
            spread: 2,
            depth: 60,
            borderRadius: 14,
            color: color,
            parentColor: onColor,
            child: SizedBox(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: MultiSelectDropDown(
                          borderRadius: 14,
                          borderWidth: 4,
                          focusedBorderWidth: 2,
                          focusedBorderColor: color.darken(10),
                          fieldBackgroundColor: color,
                          borderColor: color.darken(10),
                          optionsBackgroundColor: color.lighten(10),
                          selectedOptionBackgroundColor: color.lighten(15),
                          dropdownBorderRadius: 14,
                          hintColor: onColor,
                          hintStyle: TextStyle(color: onColor, fontWeight: FontWeight.bold),
                          singleSelectItemStyle: TextStyle(color: onColor, fontWeight: FontWeight.bold),
                          optionBuilder: (context, valueItem, isSelected) {
                            return ListTile(
                              title: Text(valueItem.label, style: TextStyle(color: color.darken(20).onColor),),
                              trailing: isSelected
                                  ? Icon(Icons.check_circle, color: color.darken(40),)
                                  : Icon(Icons.radio_button_unchecked, color: color.darken(20).onColor,),
                            );
                          },
                          dropdownBackgroundColor: color.darken(10),
                          hint: 'Sort By',
                          onOptionSelected: (options) {
                            widget.filterOptions
                                .selectedSorting =
                                options
                                    .map((item) => item.value)
                                    .toList();
                          },
                          onOptionRemoved: (index, item) {
                            setState(() {
                              widget.filterOptions
                                  .selectedSorting!
                                  .remove(item.value);
                            });
                          },
                          options: SortByEvent.values
                              .map((rating) {
                            return ValueItem(
                              label: rating.value,
                              value: rating.valueApi,
                            );
                          }).toList(),
                          maxItems: SortByEvent.values.length,
                          selectionType: SelectionType.single,
                          chipConfig: const ChipConfig(
                              wrapType: WrapType.wrap),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 14,),
          ClayContainer(
            spread: 2,
            depth: 60,
            borderRadius: 14,
            color: color,
            parentColor: onColor,
            child: SizedBox(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text('Event Date',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, color: onColor)),
                    const SizedBox(height: 8),
                    // Add some space between texts
                    Text(
                      'Selected Dates: ${DateFormat('yyyy-MM-dd').format(widget.filterOptions.values.start)} - ${DateFormat('yyyy-MM-dd').format(widget.filterOptions.values.end)}',
                      style: TextStyle(fontSize: 14, color: onColor),
                    ),
                    const SizedBox(height: 8),
                    // Add some space between texts and slider
                    SfRangeSlider(
                      min: DateTime(2017),
                      max: DateTime.now().add(const Duration(days: 365)),
                      values: widget.filterOptions.values,
                      interval: 2,
                      showTicks: true,
                      showLabels: true,
                      minorTicksPerInterval: 1,
                      dateFormat: DateFormat.y(),
                      dateIntervalType: DateIntervalType.years,
                      onChanged: (SfRangeValues values) {
                        setState(() {
                          widget.filterOptions.values = values;
                        });
                      },
                    ),
                  ],
                ),
              ),
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
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(color),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.0),
                              side: BorderSide(color: onColor)
                          )
                      )
                  ),
                  onPressed: () {
                    widget.searchBarController.close();
                    setState(() {});
                  },
                  child: const FittedBox(child: Text('Cancel')),
                ),
              ),
              const SizedBox(width: 8,),
              Expanded(
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(color),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.0),
                              side: BorderSide(color: onColor)
                          )
                      )
                  ),
                  onPressed: () {
                    setState(() {
                      widget.filterOptions.values = SfRangeValues(DateTime(2017), DateTime.now().add(Duration(days: 365)));
                    });
                    widget.pagingController.refresh();
                  },
                  child: const FittedBox(child: Text('Reset Event Filter')),
                ),
              ),
              const SizedBox(width: 8,),
              Expanded(
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(color),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.0),
                              side: BorderSide(color: onColor)
                          )
                      )
                  ),
                  onPressed: () {
                    widget.searchBarController.close();
                    widget.pagingController.refresh();
                  },
                  child: const FittedBox(child: Text('Apply')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
