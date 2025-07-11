// lib/presentation/pages/game_detail/widgets/sections/game_engines_section.dart
import 'package:flutter/material.dart';
import '../../../../../domain/entities/game/game_engine.dart';
import '../../../../../core/utils/image_utils.dart';

class GameEnginesSection extends StatelessWidget {
  final List<GameEngine> gameEngines;

  const GameEnginesSection({
    super.key,
    required this.gameEngines,
  });

  @override
  Widget build(BuildContext context) {
    if (gameEngines.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context),
        const SizedBox(height: 16),
        _buildEnginesList(context),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.precision_manufacturing_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Development Tools',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${gameEngines.length} ${gameEngines.length == 1 ? 'engine' : 'engines'} used',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnginesList(BuildContext context) {
    // Unterschiedliche Layouts je nach Anzahl
    if (gameEngines.length == 1) {
      return _buildSingleEngineCard(context, gameEngines.first);
    } else if (gameEngines.length <= 3) {
      return _buildHorizontalEngineCards(context);
    } else {
      return _buildGridEngineCards(context);
    }
  }

  Widget _buildSingleEngineCard(BuildContext context, GameEngine engine) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8),
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          _buildEngineLogo(context, engine, size: 60),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  engine.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                if (engine.hasDescription) ...[
                  const SizedBox(height: 8),
                  Text(
                    engine.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                _buildEngineStats(context, engine),
              ],
            ),
          ),
          if (engine.hasUrl)
            IconButton(
              onPressed: () => _openEngineUrl(context, engine),
              icon: Icon(
                Icons.launch_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              tooltip: 'Visit ${engine.name} website',
            ),
        ],
      ),
    );
  }

  Widget _buildHorizontalEngineCards(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: gameEngines.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index < gameEngines.length - 1 ? 16 : 0,
            ),
            child: _buildEngineCard(context, gameEngines[index]),
          );
        },
      ),
    );
  }

  Widget _buildGridEngineCards(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemCount: gameEngines.length,
      itemBuilder: (context, index) {
        return _buildEngineCard(context, gameEngines[index]);
      },
    );
  }

  Widget _buildEngineCard(BuildContext context, GameEngine engine) {
    return GestureDetector(
      onTap: () => _showEngineDetails(context, engine),
      child: Container(
        width: 200, // Für horizontale Liste
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildEngineLogo(context, engine, size: 40),
            const SizedBox(height: 12),
            Text(
              engine.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            _buildEngineStats(context, engine, compact: true),
          ],
        ),
      ),
    );
  }

  Widget _buildEngineLogo(BuildContext context, GameEngine engine, {required double size}) {
    if (engine.hasLogo) {
      final logoUrl = ImageUtils.getMediumImageUrl(
        engine.logoId.toString(),
      );

      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
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
    // Verschiedene Icons für bekannte Engines
    IconData icon = Icons.settings_outlined;
    Color color = Theme.of(context).colorScheme.primary;

    final engineName = engine.name.toLowerCase();
    if (engineName.contains('unity')) {
      icon = Icons.view_in_ar_rounded;
      color = const Color(0xFF000000);
    } else if (engineName.contains('unreal')) {
      icon = Icons.architecture_rounded;
      color = const Color(0xFF0E1128);
    } else if (engineName.contains('godot')) {
      icon = Icons.auto_awesome_rounded;
      color = const Color(0xFF478CBF);
    } else if (engineName.contains('custom') || engineName.contains('proprietary')) {
      icon = Icons.code_rounded;
      color = const Color(0xFF6B46C1);
    } else if (engineName.contains('source')) {
      icon = Icons.memory_rounded;
      color = const Color(0xFFFF6B00);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Icon(
        icon,
        color: color,
        size: size * 0.6,
      ),
    );
  }

  Widget _buildEngineStats(BuildContext context, GameEngine engine, {bool compact = false}) {
    final stats = <Widget>[];

    if (engine.hasCompanies) {
      stats.add(_buildStatChip(
        context,
        icon: Icons.business_rounded,
        label: compact ? '${engine.companyCount}' : '${engine.companyCount} companies',
        color: Theme.of(context).colorScheme.secondary,
      ));
    }

    if (engine.hasPlatforms) {
      stats.add(_buildStatChip(
        context,
        icon: Icons.devices_rounded,
        label: compact ? '${engine.platformCount}' : '${engine.platformCount} platforms',
        color: Theme.of(context).colorScheme.tertiary,
      ));
    }

    if (stats.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      alignment: compact ? WrapAlignment.center : WrapAlignment.start,
      children: stats,
    );
  }

  Widget _buildStatChip(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
      }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showEngineDetails(BuildContext context, GameEngine engine) {
    showDialog(
      context: context,
      builder: (context) => GameEngineDetailsDialog(engine: engine),
    );
  }

  void _openEngineUrl(BuildContext context, GameEngine engine) {
    // TODO: Implement URL opening (url_launcher package)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${engine.name} website...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Dialog für detaillierte Game Engine Informationen
class GameEngineDetailsDialog extends StatelessWidget {
  final GameEngine engine;

  const GameEngineDetailsDialog({
    super.key,
    required this.engine,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          _buildEngineLogo(context, engine, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              engine.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (engine.hasDescription) ...[
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                engine.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
            ],

            if (engine.hasCompanies || engine.hasPlatforms) ...[
              Text(
                'Usage Statistics',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              if (engine.hasCompanies)
                _buildStatRow(
                  context,
                  icon: Icons.business_rounded,
                  title: 'Companies using this engine',
                  value: '${engine.companyCount}',
                  color: Theme.of(context).colorScheme.secondary,
                ),

              if (engine.hasPlatforms)
                _buildStatRow(
                  context,
                  icon: Icons.devices_rounded,
                  title: 'Supported platforms',
                  value: '${engine.platformCount}',
                  color: Theme.of(context).colorScheme.tertiary,
                ),

              const SizedBox(height: 16),
            ],

            // Popularity indicators
            if (engine.isPopularEngine || engine.isWidelySupported) ...[
              Text(
                'Recognition',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (engine.isPopularEngine)
                    _buildFeatureBadge(
                      context,
                      icon: Icons.star_rounded,
                      label: 'Popular Engine',
                      color: const Color(0xFFFF8F00),
                    ),
                  if (engine.isWidelySupported)
                    _buildFeatureBadge(
                      context,
                      icon: Icons.public_rounded,
                      label: 'Cross-Platform',
                      color: const Color(0xFF4CAF50),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (engine.hasUrl)
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Open URL
            },
            icon: const Icon(Icons.launch_rounded),
            label: const Text('Visit Website'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildEngineLogo(BuildContext context, GameEngine engine, {required double size}) {
    // Gleiche Logik wie in der GameEnginesSection
    if (engine.hasLogo) {
      final logoUrl = ImageUtils.getMediumImageUrl(
        engine.logoId.toString(),
      );

      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
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
    IconData icon = Icons.settings_outlined;
    Color color = Theme.of(context).colorScheme.primary;

    final engineName = engine.name.toLowerCase();
    if (engineName.contains('unity')) {
      icon = Icons.view_in_ar_rounded;
      color = const Color(0xFF000000);
    } else if (engineName.contains('unreal')) {
      icon = Icons.architecture_rounded;
      color = const Color(0xFF0E1128);
    } else if (engineName.contains('godot')) {
      icon = Icons.auto_awesome_rounded;
      color = const Color(0xFF478CBF);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Icon(
        icon,
        color: color,
        size: size * 0.6,
      ),
    );
  }

  Widget _buildStatRow(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String value,
        required Color color,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBadge(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
      }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}