// ==================================================
// ACCORDION TILE WIDGET
// ==================================================

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

class AccordionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const AccordionTile({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: child,
        ),
      ],
    );
  }
}
