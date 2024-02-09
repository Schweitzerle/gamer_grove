import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/widgets.dart';
import 'package:gamer_grove/utils/ThemManager.dart';

class ThemeButton extends StatelessWidget {
  final FlexScheme scheme;
  final String themeName;

  const ThemeButton({
    Key? key,
    required this.scheme,
    required this.themeName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ColorScheme schemeTheme = FlexThemeData.light(scheme: scheme).colorScheme;
    return ClayContainer(
      spread: 2,
      depth: 60,
      customBorderRadius: BorderRadius.circular(12),
      color: Theme.of(context).colorScheme.inversePrimary,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              ThemeManager(scheme: scheme).setTheme(context);
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 4, // Adjusted the flex value here
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(8.0),
                    ),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        _buildColorBox(schemeTheme.primary),
                        _buildColorBox(schemeTheme.secondary),
                        _buildColorBox(schemeTheme.primaryContainer),
                        _buildColorBox(schemeTheme.tertiary),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8.0), // Adjust the spacing here
                Expanded(
                  flex: 1, // Reduced the flex value here
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        themeName,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorBox(Color color) {
    return Container(
      color: color,
      height: 50,
      width: 50,
    );
  }
}
