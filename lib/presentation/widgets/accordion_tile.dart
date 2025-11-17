// ==================================================
// ACCORDION TILE WIDGET
// ==================================================

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

class AccordionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final bool isFirst;
  final bool isLast;

  const AccordionTile({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.isFirst = true,
    this.isLast = true,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        tilePadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: 4,
        ),
        childrenPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(12) : Radius.zero,
            bottom: isLast ? const Radius.circular(12) : Radius.zero,
          ),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(12) : Radius.zero,
            bottom: isLast ? const Radius.circular(12) : Radius.zero,
          ),
        ),
        children: [
          child,
        ],
      ),
    );
  }
}
