import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class RatingCountSlider extends StatefulWidget {
  final String title;
  final double value;
  final Function(int) onChanged;
  final Color color;

  const RatingCountSlider({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    required this.color
  });

  @override
  _RatingCountSliderState createState() => _RatingCountSliderState();
}

class _RatingCountSliderState extends State<RatingCountSlider> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(fontWeight: FontWeight.bold, color: widget.color.onColor),
          ),
          SfSlider(
            min: 0.0,
            max: 100.0,
            tooltipShape: const SfPaddleTooltipShape(),
            value: widget.value,
            interval: 20,
            showTicks: false,
            showLabels: true,
            enableTooltip: true,
            minorTicksPerInterval: 1,
            onChanged: (dynamic value) {
              setState(() {
                widget.onChanged(value.toInt());
              });
            },
          ),
        ],
      ),
    );
  }
}
