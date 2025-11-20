// lib/presentation/pages/characters/widgets/character_details_accordion.dart
import 'package:flutter/material.dart';
import 'package:gamer_grove/core/constants/app_constants.dart';
import 'package:gamer_grove/domain/entities/character/character.dart';
import 'package:gamer_grove/presentation/widgets/sections/game_details_accordion.dart';
import 'package:intl/intl.dart';

class CharacterDetailsAccordion extends StatelessWidget {

  const CharacterDetailsAccordion({
    required this.character, super.key,
  });
  final Character character;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingMedium,
      ),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildAccordionContent(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.info_outline,
            color: Colors.teal,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Character Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildAccordionContent(BuildContext context) {
    final accordionItems = <Widget>[];

    // Character Identity Section
    if (_hasIdentityInfo()) {
      accordionItems.add(
        EnhancedAccordionTile(
          title: 'Identity & Origins',
          icon: Icons.person_outline,
          preview: _buildIdentityPreview(context),
          child: _buildIdentitySection(context),
        ),
      );
    }

    // Character Metadata Section
    if (_hasMetadataInfo()) {
      accordionItems.add(
        EnhancedAccordionTile(
          title: 'Character Metadata',
          icon: Icons.dataset_outlined,
          preview: _buildMetadataPreview(context),
          child: _buildMetadataSection(context),
        ),
      );
    }

    // External Links Section
    if (_hasExternalLinks()) {
      accordionItems.add(
        EnhancedAccordionTile(
          title: 'External Links',
          icon: Icons.link,
          preview: _buildLinksPreview(context),
          child: _buildExternalLinksSection(context),
        ),
      );
    }

    if (accordionItems.isEmpty) {
      return _buildNoDetailsAvailable(context);
    }

    return Column(
      children: accordionItems
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: item,
              ),)
          .toList(),
    );
  }

  Widget _buildIdentitySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (character.genderEnum != null)
          _buildDetailRow(
            context,
            icon: Icons.person_outline,
            label: 'Gender',
            value: character.displayGender,
            color: Colors.blue,
          ),
        if (character.speciesEnum != null)
          _buildDetailRow(
            context,
            icon: Icons.pets,
            label: 'Species',
            value: character.displaySpecies,
            color: Colors.green,
          ),
        if (character.countryName != null)
          _buildDetailRow(
            context,
            icon: Icons.location_on_outlined,
            label: 'Country of Origin',
            value: character.countryName!,
            color: Colors.orange,
          ),
        if (character.akas.isNotEmpty) _buildAlternativeNamesDetail(context),
      ],
    );
  }

  Widget _buildMetadataSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(
          context,
          icon: Icons.tag,
          label: 'Character ID',
          value: character.id.toString(),
          color: Colors.purple,
        ),
        if (character.slug != null)
          _buildDetailRow(
            context,
            icon: Icons.link,
            label: 'URL Slug',
            value: character.slug!,
            color: Colors.indigo,
          ),
        if (character.createdAt != null)
          _buildDetailRow(
            context,
            icon: Icons.calendar_today,
            label: 'Added to Database',
            value: DateFormat.yMMMd().format(character.createdAt!),
            color: Colors.teal,
          ),
        if (character.updatedAt != null)
          _buildDetailRow(
            context,
            icon: Icons.update,
            label: 'Last Updated',
            value: DateFormat.yMMMd().format(character.updatedAt!),
            color: Colors.cyan,
          ),
        _buildDetailRow(
          context,
          icon: Icons.videogame_asset,
          label: 'Featured in Games',
          value: '${character.gameIds.length} games',
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildExternalLinksSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (character.url != null)
          _buildLinkTile(
            context,
            icon: Icons.link,
            label: 'Official Character Page',
            url: character.url!,
          ),
        // Add more external links here if available
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativeNamesDetail(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.alternate_email,
                size: 16, color: Colors.amber,),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alternative Names',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: character.akas.map((name) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2,),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.amber.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String url,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          url,
          style: TextStyle(color: Colors.grey.shade600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.open_in_new, size: 16),
        onTap: () {
          // TODO: Launch URL
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening: $url')),
          );
        },
      ),
    );
  }

  Widget _buildNoDetailsAvailable(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              size: 32,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'No Additional Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Extended character information is not available.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Preview builders for collapsed state
  Widget _buildIdentityPreview(BuildContext context) {
    final items = <String>[];
    if (character.genderEnum != null) items.add(character.displayGender);
    if (character.speciesEnum != null) items.add(character.displaySpecies);
    if (character.countryName != null) items.add(character.countryName!);

    return Text(
      items.take(2).join(' • '),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMetadataPreview(BuildContext context) {
    return Text(
      'ID: ${character.id} • ${character.gameIds.length} games',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
    );
  }

  Widget _buildLinksPreview(BuildContext context) {
    return Text(
      character.url != null ? 'Official page available' : 'No external links',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
    );
  }

  // Helper methods to check if sections should be shown
  bool _hasIdentityInfo() {
    return character.genderEnum != null ||
        character.speciesEnum != null ||
        character.countryName != null ||
        character.akas.isNotEmpty;
  }

  bool _hasMetadataInfo() {
    return true; // Always show metadata section
  }

  bool _hasExternalLinks() {
    return character.url != null; // Add more link checks here
  }
}
