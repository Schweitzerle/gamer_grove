import 'package:flutter/material.dart';

/// One line of the loading readout.
///
/// The steps are what make this worth more than a spinner: they say what is
/// being fetched, and a wait you can follow feels shorter than a wait you
/// cannot.
@immutable
class LoadingStep {
  const LoadingStep({
    required this.text,
    this.substep,
    this.color,
    this.icon,
  });

  final String text;
  final String? substep;
  final Color? color;
  final IconData? icon;
}
