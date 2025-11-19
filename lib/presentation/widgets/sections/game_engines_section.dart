// lib/presentation/pages/game_detail/widgets/sections/game_engines_section.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamer_grove/domain/entities/game/game_engine.dart';
import 'package:gamer_grove/core/utils/navigations.dart';
import 'package:gamer_grove/core/utils/image_utils.dart';

class GameEnginesSection extends StatelessWidget {
  final List<GameEngine> gameEngines;

  const GameEnginesSection({
    super.key,
    required this.gameEngines,
  });

  static const Color _engineColor = Color(0xFF6366F1); // Indigo

  @override
  Widget build(BuildContext context) {
    if (gameEngines.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context),
        const SizedBox(height: 12),
        _buildEnginesContent(context),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.precision_manufacturing_rounded,
          size: 18,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          'Game Engines',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildEnginesContent(BuildContext context) {
    // Einzelne Engine zentriert darstellen
    if (gameEngines.length == 1) {
      return _buildSingleEngineCard(context, gameEngines.first);
    }

    // Mehrere Engines als horizontal scrollbare Liste
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: gameEngines.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index < gameEngines.length - 1 ? 12 : 0,
            ),
            child: _buildEngineCard(context, gameEngines[index]),
          );
        },
      ),
    );
  }

  Widget _buildSingleEngineCard(BuildContext context, GameEngine engine) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigations.navigateToGameEngineDetails(
          context,
          gameEngineId: engine.id,
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _engineColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _engineColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            // Engine Logo oder Icon
            _buildEngineLogo(context, engine, size: 48),
            const SizedBox(width: 16),
            // Name und Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    engine.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _engineColor,
                        ),
                  ),
                  if (engine.hasDescription) ...[
                    const SizedBox(height: 6),
                    Text(
                      engine.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Chevron für Navigation
            Icon(
              Icons.chevron_right_rounded,
              color: _engineColor.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngineCard(BuildContext context, GameEngine engine) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigations.navigateToGameEngineDetails(
          context,
          gameEngineId: engine.id,
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _engineColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _engineColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            // Engine Logo oder Icon
            _buildEngineLogo(context, engine, size: 40),
            const SizedBox(width: 12),
            // Name und Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    engine.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _engineColor,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (engine.hasDescription) ...[
                    const SizedBox(height: 4),
                    Text(
                      engine.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ] else ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.touch_app_rounded,
                          size: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tap for details',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.5),
                                    fontSize: 11,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngineLogo(BuildContext context, GameEngine engine, {required double size}) {
    if (engine.hasLogo) {
      final logoUrl = ImageUtils.getMediumImageUrl(
        engine.logo?.url.toString(),
      );

      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.25),
          border: Border.all(
            color: _engineColor.withOpacity(0.2),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.25),
          child: Image.network(
            logoUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                _buildDefaultEngineLogo(context, engine, size),
          ),
        ),
      );
    }

    return _buildDefaultEngineLogo(context, engine, size);
  }

  Widget _buildDefaultEngineLogo(BuildContext context, GameEngine engine, double size) {
    final iconData = _getEngineIconData(engine);
    final color = _getEngineColor(engine);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Center(
        child: Icon(
          iconData,
          size: size * 0.55,
          color: color,
        ),
      ),
    );
  }

  IconData _getEngineIconData(GameEngine engine) {
    final engineName = engine.name.toLowerCase();
    if (engineName.contains('unity')) {
      return Icons.view_in_ar_rounded;
    } else if (engineName.contains('unreal')) {
      return Icons.architecture_rounded;
    } else if (engineName.contains('godot')) {
      return Icons.auto_awesome_rounded;
    } else if (engineName.contains('custom') || engineName.contains('proprietary')) {
      return Icons.code_rounded;
    } else if (engineName.contains('source')) {
      return Icons.memory_rounded;
    } else if (engineName.contains('frostbite')) {
      return Icons.ac_unit_rounded;
    } else if (engineName.contains('cryengine')) {
      return Icons.landscape_rounded;
    }
    return Icons.settings_rounded;
  }

  Color _getEngineColor(GameEngine engine) {
    final engineName = engine.name.toLowerCase();
    if (engineName.contains('unity')) {
      return const Color(0xFF000000);
    } else if (engineName.contains('unreal')) {
      return const Color(0xFF0E1128);
    } else if (engineName.contains('godot')) {
      return const Color(0xFF478CBF);
    } else if (engineName.contains('custom') || engineName.contains('proprietary')) {
      return const Color(0xFF6B46C1);
    } else if (engineName.contains('source')) {
      return const Color(0xFFFF6B00);
    } else if (engineName.contains('frostbite')) {
      return const Color(0xFF00A8E8);
    } else if (engineName.contains('cryengine')) {
      return const Color(0xFF2D9CDB);
    }
    return _engineColor;
  }
}
