import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import '../../utils/ThemManager.dart';
import '../widgets/ThemeButton.dart';

class ThemeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<FlexScheme> flexSchemes = FlexScheme.values;

    return Scaffold(
      appBar: AppBar(
        title: Text('Themes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemCount: flexSchemes.length, // Only show 4 selected themes
          itemBuilder: (context, index) {
            final scheme = flexSchemes[index];
            return Padding(
              padding: const EdgeInsets.all(3.0),
              child: ThemeButton(
                scheme: scheme,
                themeName: scheme.toString().split('.').last,
              ),
            );
          },
        ),
      ),
    );
  }
}
