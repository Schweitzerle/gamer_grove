import 'package:flutter/material.dart';
import 'package:gamer_grove/core/entitlements/entitlement_service.dart';
import 'package:gamer_grove/core/entitlements/entitlements.dart';
import 'package:gamer_grove/core/entitlements/pro_feature.dart';
import 'package:gamer_grove/injection_container.dart';

/// Renders [builder] when the user is entitled to [feature], otherwise
/// [lockedBuilder]. Rebuilds automatically when entitlements change (e.g. right
/// after a purchase), so a locked screen swaps to the real content live.
class ProGate extends StatelessWidget {
  const ProGate({
    required this.feature,
    required this.builder,
    required this.lockedBuilder,
    super.key,
  });

  final ProFeature feature;
  final WidgetBuilder builder;
  final WidgetBuilder lockedBuilder;

  @override
  Widget build(BuildContext context) {
    final service = sl<EntitlementService>();
    return StreamBuilder<Entitlements>(
      stream: service.changes,
      initialData: service.entitlements,
      builder: (context, snapshot) {
        final entitlements = snapshot.data ?? const Entitlements.free();
        return entitlements.has(feature)
            ? builder(context)
            : lockedBuilder(context);
      },
    );
  }
}
