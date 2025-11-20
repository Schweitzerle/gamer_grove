// ==================================================
// LIVE LOADING PROGRESS - CONSOLE-STYLE LOADING
// ==================================================

import 'dart:async';

// lib/presentation/widgets/live_loading_progress.dart
import 'package:flutter/material.dart';

class LiveLoadingProgress extends StatefulWidget {

  const LiveLoadingProgress({
    required this.title, required this.steps, super.key,
    this.stepDuration = const Duration(milliseconds: 800),
  });
  final String title;
  final List<LoadingStep> steps;
  final Duration stepDuration;

  @override
  State<LiveLoadingProgress> createState() => _LiveLoadingProgressState();
}

class _LiveLoadingProgressState extends State<LiveLoadingProgress>
    with TickerProviderStateMixin {
  int currentStepIndex = 0;
  Timer? _stepTimer;
  late AnimationController _pulseController;
  late AnimationController _typewriterController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _typewriterAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _typewriterController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.4,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ),);

    _typewriterAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _typewriterController,
      curve: Curves.easeOut,
    ),);

    _startLoading();
  }

  void _startLoading() {
    _stepTimer = Timer.periodic(widget.stepDuration, (timer) {
      if (mounted && currentStepIndex < widget.steps.length - 1) {
        setState(() {
          currentStepIndex++;
        });
        _typewriterController.reset();
        _typewriterController.forward();
      } else {
        timer.cancel();
      }
    });
    _typewriterController.forward();
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _pulseController.dispose();
    _typewriterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(_pulseAnimation.value),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Console-style output
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0;
                        i <= currentStepIndex && i < widget.steps.length;
                        i++)
                      _buildLoadingStep(widget.steps[i], i == currentStepIndex),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Progress Bar
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (currentStepIndex + 1) / widget.steps.length,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Progress Text
            Text(
              '${currentStepIndex + 1}/${widget.steps.length} steps completed',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingStep(LoadingStep step, bool isActive) {
    final isCompleted =
        !isActive && widget.steps.indexOf(step) < currentStepIndex;
    final stepColor = step.color ?? Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Icon
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(right: 12),
            child: isCompleted
                ? Icon(Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary, size: 16,)
                : isActive
                    ? AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color:
                                  stepColor.withOpacity(_pulseAnimation.value),
                              shape: BoxShape.circle,
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
          ),

          // Step Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step Text with Typewriter Effect
                if (isActive) AnimatedBuilder(
                        animation: _typewriterAnimation,
                        builder: (context, child) {
                          final visibleLength =
                              (step.text.length * _typewriterAnimation.value)
                                  .round();
                          final visibleText =
                              step.text.substring(0, visibleLength);

                          return RichText(
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '> ',
                                  style: TextStyle(
                                    color: stepColor,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                TextSpan(
                                  text: visibleText,
                                  style: TextStyle(
                                    color: stepColor,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                if (visibleLength < step.text.length &&
                                    _typewriterAnimation.value < 1.0)
                                  TextSpan(
                                    text: '▌',
                                    style: TextStyle(
                                      color: stepColor,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ) else RichText(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: isCompleted ? '✓ ' : '  ',
                              style: TextStyle(
                                color: isCompleted
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                            TextSpan(
                              text: step.text,
                              style: TextStyle(
                                color: isCompleted
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.8)
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),

                // Substep (if any)
                if (step.substep != null && isActive)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 16),
                    child: Text(
                      '  └─ ${step.substep}',
                      style: TextStyle(
                        color: stepColor.withOpacity(0.7),
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================
// LOADING STEP DATA CLASS
// ==================================================

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

// ==================================================
// PREDEFINED LOADING STEPS FOR EVENTS
// ==================================================

class EventLoadingSteps {
  static List<LoadingStep> eventDetails(BuildContext context) => [
        LoadingStep(
          text: 'Initializing event loader...',
          substep: 'Setting up data sources',
          color: Theme.of(context).colorScheme.secondary,
        ),
        LoadingStep(
          text: 'Fetching event details from IGDB...',
          substep: 'Retrieving event metadata',
          color: Theme.of(context).colorScheme.tertiary,
        ),
        LoadingStep(
          text: 'Loading featured games...',
          substep: 'Processing game collections',
          color: Theme.of(context).colorScheme.primary,
        ),
        LoadingStep(
          text: 'Enriching event data...',
          substep: 'Fetching networks and media',
          color: Theme.of(context).colorScheme.secondary,
        ),
        LoadingStep(
          text: 'Finalizing event details...',
          substep: 'Preparing UI components',
          color: Theme.of(context).colorScheme.primary,
        ),
      ];

  static List<LoadingStep> gameDetails(BuildContext context) => [
        LoadingStep(
          text: 'Connecting to game database...',
          color: Theme.of(context).colorScheme.secondary,
        ),
        LoadingStep(
          text: 'Fetching game information...',
          substep: 'Loading metadata and screenshots',
          color: Theme.of(context).colorScheme.tertiary,
        ),
        LoadingStep(
          text: 'Processing user data...',
          substep: 'Checking ratings and collections',
          color: Theme.of(context).colorScheme.primary,
        ),
        LoadingStep(
          text: 'Loading related content...',
          substep: 'Franchises, DLCs, and similar games',
          color: Theme.of(context).colorScheme.secondary,
        ),
        LoadingStep(
          text: 'Finalizing game details...',
          color: Theme.of(context).colorScheme.primary,
        ),
      ];
}

class CharacterLoadingSteps {
  static List<LoadingStep> characterDetails(BuildContext context) => [
        LoadingStep(
          text: 'Connecting to character database...',
          substep: 'Initializing IGDB connection',
          color: Theme.of(context).colorScheme.secondary,
        ),
        LoadingStep(
          text: 'Fetching character profile...',
          substep: 'Loading character metadata and images',
          color: Theme.of(context).colorScheme.tertiary,
        ),
        LoadingStep(
          text: 'Processing character games...',
          substep: 'Retrieving games featuring this character',
          color: Theme.of(context).colorScheme.primary,
        ),
        LoadingStep(
          text: 'Enriching character data...',
          substep: 'Loading additional character information',
          color: Theme.of(context).colorScheme.secondary,
        ),
        LoadingStep(
          text: 'Finalizing character details...',
          substep: 'Preparing character profile display',
          color: Theme.of(context).colorScheme.primary,
        ),
      ];
}

class PlatformLoadingSteps {
  static List<LoadingStep> platformDetails(BuildContext context) => [
        LoadingStep(
          text: 'Connecting to platform database...',
          substep: 'Initializing IGDB connection',
          color: Theme.of(context).colorScheme.secondary,
        ),
        LoadingStep(
          text: 'Fetching platform profile...',
          substep: 'Loading platform metadata',
          color: Theme.of(context).colorScheme.tertiary,
        ),
        LoadingStep(
          text: 'Processing platform games...',
          substep: 'Retrieving games published on this platform',
          color: Theme.of(context).colorScheme.primary,
        ),
        LoadingStep(
          text: 'Enriching platform data...',
          substep: 'Loading additional platform information',
          color: Theme.of(context).colorScheme.secondary,
        ),
        LoadingStep(
          text: 'Finalizing platform details...',
          substep: 'Preparing platform profile display',
          color: Theme.of(context).colorScheme.primary,
        ),
      ];
}

class GameEngineLoadingSteps {
  static List<LoadingStep> gameEngineDetails(BuildContext context) => [
        LoadingStep(
          text: 'Connecting to game engine database...',
          substep: 'Initializing IGDB connection',
          color: Theme.of(context).colorScheme.secondary,
        ),
        LoadingStep(
          text: 'Fetching game engine profile...',
          substep: 'Loading game engine metadata',
          color: Theme.of(context).colorScheme.tertiary,
        ),
        LoadingStep(
          text: 'Processing game engine games...',
          substep: 'Retrieving games published on this game engine',
          color: Theme.of(context).colorScheme.primary,
        ),
        LoadingStep(
          text: 'Enriching game engine data...',
          substep: 'Loading additional game engine information',
          color: Theme.of(context).colorScheme.secondary,
        ),
        LoadingStep(
          text: 'Finalizing game engine details...',
          substep: 'Preparing game engine profile display',
          color: Theme.of(context).colorScheme.primary,
        ),
      ];
}

class CompanyLoadingSteps {
  static List<LoadingStep> companyDetails(BuildContext context) => [
        LoadingStep(
          text: 'Connecting to company database...',
          substep: 'Initializing IGDB connection',
          color: Theme.of(context).colorScheme.secondary,
        ),
        LoadingStep(
          text: 'Fetching company profile...',
          substep: 'Loading company metadata and logo',
          color: Theme.of(context).colorScheme.tertiary,
        ),
        LoadingStep(
          text: 'Processing developed games...',
          substep: 'Retrieving games developed by this company',
          color: Theme.of(context).colorScheme.primary,
        ),
        LoadingStep(
          text: 'Processing published games...',
          substep: 'Retrieving games published by this company',
          color: Theme.of(context).colorScheme.primary,
        ),
        LoadingStep(
          text: 'Enriching company data...',
          substep: 'Loading parent company and websites',
          color: Theme.of(context).colorScheme.secondary,
        ),
        LoadingStep(
          text: 'Finalizing company details...',
          substep: 'Preparing company profile display',
          color: Theme.of(context).colorScheme.primary,
        ),
      ];
}
