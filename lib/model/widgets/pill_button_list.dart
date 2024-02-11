import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';

class PillButtonList extends StatelessWidget {
  final List<String> stringArray;
  final Color color;

  PillButtonList({required this.stringArray, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 5.0,
        runSpacing: 5.0,
        children: stringArray.map((text) {
          return GestureDetector(
            onTap: () {
              //TODO: zu gridview
            },
            child: ClayContainer(
              depth: 60,
              spread: 2,
              color: color,
              customBorderRadius: BorderRadius.circular(20),
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                  child: Text(
                    text,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
