import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';

class PillList extends StatelessWidget {
  final List<String> stringArray;
  final Color color;

  PillList({required this.stringArray, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 5.0,
        runSpacing: 5.0,
        children: stringArray.map((text) {
          return
            Card(
              color: color,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
              child: Text(
                text,
                style: TextStyle(color: Colors.black),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
