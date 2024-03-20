import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class RatingRangeSlider extends StatefulWidget {
  final String title;
  final SfRangeValues values;
  final Function(SfRangeValues) onChanged;
  final Color color;

  const RatingRangeSlider({
    Key? key,
    required this.title,
    required this.values,
    required this.onChanged, required this.color,
  }) : super(key: key);

  @override
  _RatingRangeSliderState createState() => _RatingRangeSliderState();
}

class _RatingRangeSliderState extends State<RatingRangeSlider> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.title} Range: ${widget.values.start} - ${widget.values.end}',
            style: TextStyle(fontWeight: FontWeight.bold, color: widget.color),
          ),
          SfRangeSlider(
            min: 0.0,
            max: 100.0,
            values: widget.values,
            interval: 20,
            showTicks: true,
            showLabels: true,
            minorTicksPerInterval: 1,
            onChanged: widget.onChanged,
          ),
        ],
      ),
    );
  }
}
