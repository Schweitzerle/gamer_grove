// ==================================================
// GENERIC COMPANY SECTION - WIEDERVERWENDBAR
// ==================================================

// lib/presentation/widgets/sections/generic_company_section.dart
import 'package:flutter/material.dart';
import '../../../../core/utils/navigations.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import '../../../../domain/entities/company/company.dart';
import '../../../../domain/entities/involved_company.dart';

class GenericCompanySection extends StatelessWidget {
  // ✅ FLEXIBLE CONSTRUCTOR - Entweder InvolvedCompanies oder direkte Companies
  final List<InvolvedCompany>? involvedCompanies;
  final List<Company>? companies;
  final String title;
  final bool showRoles;

  const GenericCompanySection({
    super.key,
    this.involvedCompanies,
    this.companies,
    this.title = 'Related Companies',
    this.showRoles = true,
  }) : assert(involvedCompanies != null || companies != null,
            'Either involvedCompanies or companies must be provided');

  @override
  Widget build(BuildContext context) {
    // ✅ Determine which companies to show
    if (involvedCompanies != null && involvedCompanies!.isNotEmpty) {
      return _buildInvolvedCompanySection(context);
    } else if (companies != null && companies!.isNotEmpty) {
      return _buildDirectCompanySection(context);
    }

    return const SizedBox.shrink();
  }

  // ✅ INVOLVED COMPANY SECTION (für Game Detail Screens)
  Widget _buildInvolvedCompanySection(BuildContext context) {
    final developers = involvedCompanies!.where((c) => c.isDeveloper).toList();
    final publishers = involvedCompanies!.where((c) => c.isPublisher).toList();
    final others = involvedCompanies!
        .where((c) => !c.isDeveloper && !c.isPublisher)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (developers.isNotEmpty) ...[
          _buildInvolvedCompanySubsection(context, 'Developer', developers),
          if (publishers.isNotEmpty || others.isNotEmpty)
            const SizedBox(height: 20),
        ],
        if (publishers.isNotEmpty) ...[
          _buildInvolvedCompanySubsection(context, 'Publisher', publishers),
          if (others.isNotEmpty) const SizedBox(height: 20),
        ],
        if (others.isNotEmpty) ...[
          _buildInvolvedCompanySubsection(context, 'Other Companies', others),
        ],
      ],
    );
  }

  // ✅ DIRECT COMPANY SECTION (für Game Engine Detail Screens)
  Widget _buildDirectCompanySection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Icon(
                  Icons.business,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${companies!.length}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Companies Horizontal List
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: companies!.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < companies!.length - 1 ? 12 : 0,
                    ),
                    child: _buildDirectCompanyCard(context, companies![index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ INVOLVED COMPANY SUBSECTION (mit Rollen)
  Widget _buildInvolvedCompanySubsection(
    BuildContext context,
    String subtitle,
    List<InvolvedCompany> companyList,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title with Counter
        Row(
          children: [
            Text(
              subtitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${companyList.length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Horizontal Company Cards
        SizedBox(
          height: 120, // Fixed height for cards
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: companyList.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index < companyList.length - 1 ? 12 : 0,
                ),
                child: _buildInvolvedCompanyCard(context, companyList[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  // ✅ INVOLVED COMPANY CARD (mit Rollen)
  Widget _buildInvolvedCompanyCard(
      BuildContext context, InvolvedCompany involvedCompany) {
    final company = involvedCompany.company;
    final roles = _getRoles(involvedCompany);

    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigations.navigateToCompanyDetails(
              context,
              companyId: company.id,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Company Logo
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: company.logoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedImageWidget(
                              imageUrl: company.logoUrl!,
                              fit: BoxFit.contain,
                              errorWidget: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.business,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  size: 24,
                                ),
                              ),
                            ),
                          )
                        : Icon(
                            Icons.business,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            size: 24,
                          ),
                  ),
                ),

                const SizedBox(height: 8),

                // Company Name
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Text(
                        company.name,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      if (showRoles && roles.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          roles.join(' • '),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                fontSize: 9,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ DIRECT COMPANY CARD (ohne Rollen)
  Widget _buildDirectCompanyCard(BuildContext context, Company company) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigations.navigateToCompanyDetails(
              context,
              companyId: company.id,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Company Logo
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: company.hasLogo
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedImageWidget(
                              imageUrl: company.logoUrl!,
                              fit: BoxFit.contain,
                              errorWidget: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.business,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  size: 24,
                                ),
                              ),
                            ),
                          )
                        : Icon(
                            Icons.business,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            size: 24,
                          ),
                  ),
                ),

                const SizedBox(height: 8),

                // Company Name
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Text(
                        company.name,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ HELPER METHODS
  List<String> _getRoles(InvolvedCompany involvedCompany) {
    final roles = <String>[];

    if (involvedCompany.isDeveloper) roles.add('Dev');
    if (involvedCompany.isPublisher) roles.add('Pub');
    if (involvedCompany.isPorting) roles.add('Port');
    if (involvedCompany.isSupporting) roles.add('Supp');

    return roles;
  }
}

// ==================================================
// USAGE EXAMPLES
// ==================================================

/*
// 🎮 Für Game Detail Screen (mit InvolvedCompanies und Rollen):
GenericCompanySection(
  involvedCompanies: game.involvedCompanies,
  title: 'Development & Publishing',
  showRoles: true,
)

// ⚙️ Für Game Engine Detail Screen (mit direkten Companies):
GenericCompanySection(
  companies: gameEngine.companies,
  title: 'Companies Using This Engine',
  showRoles: false,
)

// 🏢 Für Company Detail Screen (mit verwandten Companies):
GenericCompanySection(
  companies: company.subsidiaries,
  title: 'Subsidiary Companies',
  showRoles: false,
)
*/
