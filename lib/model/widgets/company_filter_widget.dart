import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import 'event_filter_widget.dart';

class CompanyFilterOptions {
  SfRangeValues values;
  List<String?> selectedSorting = [];

  // Constructor
  CompanyFilterOptions({
    required this.values,
    required this.selectedSorting,
  });
}

enum SortByCompany {
  startDateAsc,
  startDateDesc,
  nameAsc,
  nameDesc,
}
extension SortByCompanyExtension on SortByCompany {
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

  static SortByCompany fromString(int value) {
    // Changed parameter type to int
    switch (value) {
      case 0:
        return SortByCompany.startDateAsc;
      case 1:
        return SortByCompany.startDateDesc;
      case 2:
        return SortByCompany.nameAsc;
      case 3:
        return SortByCompany.nameDesc;
      default:
        throw ArgumentError('Invalid value');
    }
  }
}

String _ratingToString(SortByCompany? rating) {
  if (rating == null) return 'N/A';
  switch (rating) {
    case SortByCompany.startDateAsc:
      return 'Event Date Asc';
    case SortByCompany.startDateDesc:
      return 'Event Date Desc';
    case SortByCompany.nameAsc:
      return 'Name A-Z';
    case SortByCompany.nameDesc:
      return 'Name Z-A';
    default:
      return 'N/A';
  }
}

String _ratingToStringApi(SortByCompany? rating) {
  if (rating == null) return 'N/A';
  switch (rating) {
    case SortByCompany.startDateAsc:
      return 'start_date asc';
    case SortByCompany.startDateDesc:
      return 'start_date desc';
    case SortByCompany.nameAsc:
      return 'name asc';
    case SortByCompany.nameDesc:
      return 'name desc';
    default:
      return 'N/A';
  }
}

class CompanyFilterScreen extends StatefulWidget {
  final FloatingSearchBarController searchBarController;
  final PagingController pagingController;
  final CompanyFilterOptions filterOptions;

  const CompanyFilterScreen({
    Key? key,
    required this.searchBarController,
    required this.pagingController,
    required this.filterOptions,
  }) : super(key: key);

  @override
  _CompanyFilterScreenState createState() => _CompanyFilterScreenState();
}

class _CompanyFilterScreenState extends State<CompanyFilterScreen> {
  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;

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
            parentColor: Theme.of(context).colorScheme.onTertiaryContainer,
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
                          options: SortByCompany.values
                              .map((rating) {
                            return ValueItem(
                              label: rating.value,
                              value: rating.valueApi,
                            );
                          }).toList(),
                          maxItems: SortByCompany.values.length,
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
            color: Theme.of(context).colorScheme.tertiaryContainer,
            parentColor: Theme.of(context).colorScheme.onTertiaryContainer,
            child: SizedBox(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text('Company Founding Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8), // Add some space between texts
                    Text(
                      'Selected Dates: ${DateFormat('yyyy-MM-dd').format(widget.filterOptions.values.start)} - ${DateFormat('yyyy-MM-dd').format(widget.filterOptions.values.end)}',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 8), // Add some space between texts and slider
                    SfRangeSlider(
                      min: DateTime(1968),
                      max: DateTime.now().add(Duration(days: 365)),
                      values: widget.filterOptions.values,
                      interval: 10,
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
                  onPressed: () {
                    widget.searchBarController.close();
                    setState(() {
                    });
                  },
                  child: FittedBox(child: Text('Cancel')),
                ),
              ),
              SizedBox(width: 8,),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      widget.filterOptions.values = SfRangeValues(DateTime(1968), DateTime.now().add(Duration(days: 365)));
                    });
                    widget.pagingController.refresh();
                  },
                  child: FittedBox(child: Text('Reset Company Filter')),
                ),
              ),
              SizedBox(width: 8,),
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
          ),
        ],
      ),
    );
  }
}
