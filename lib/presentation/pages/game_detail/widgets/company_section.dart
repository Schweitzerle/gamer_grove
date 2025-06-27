// ==================================================
// COMPANY SECTION - HORIZONTAL CARDS VERSION
// ==================================================

// lib/presentation/pages/game_detail/widgets/company_section.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import '../../../../domain/entities/involved_company.dart';

class CompanySection extends StatelessWidget {
  final List<InvolvedCompany> companies;

  const CompanySection({
    super.key,
    required this.companies,
  });

  @override
  Widget build(BuildContext context) {
    final developers = companies.where((c) => c.isDeveloper).toList();
    final publishers = companies.where((c) => c.isPublisher).toList();
    final others = companies.where((c) => !c.isDeveloper && !c.isPublisher).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (developers.isNotEmpty) ...[
          _buildCompanySubsection(context, 'Developer', developers),
          if (publishers.isNotEmpty || others.isNotEmpty)
            const SizedBox(height: 20),
        ],

        if (publishers.isNotEmpty) ...[
          _buildCompanySubsection(context, 'Publisher', publishers),
          if (others.isNotEmpty)
            const SizedBox(height: 20),
        ],

        if (others.isNotEmpty) ...[
          _buildCompanySubsection(context, 'Other Companies', others),
        ],
      ],
    );
  }

  Widget _buildCompanySubsection(
      BuildContext context,
      String title,
      List<InvolvedCompany> companyList,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title with Counter
        Row(
          children: [
            Text(
              title,
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
                child: CompanyCard(
                  involvedCompany: companyList[index],
                  onTap: () {
                    // TODO: Navigate to company details
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Tapped on ${companyList[index].company.name}'),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ==================================================
// COMPANY CARD WIDGET
// ==================================================

class CompanyCard extends StatelessWidget {
  final InvolvedCompany involvedCompany;
  final VoidCallback? onTap;

  const CompanyCard({
    super.key,
    required this.involvedCompany,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final company = involvedCompany.company;
    final roles = _getRoles();

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
          onTap: onTap,
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
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
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
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.business,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            size: 24,
                          ),
                        ),
                      ),
                    )
                        : Icon(
                      Icons.business,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Company Name
                Expanded(
                  flex: 1,
                  child: Text(
                    company.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 4),

                // Role Badge
                if (roles.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getRoleColor(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getRoleColor(context).withOpacity(0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      roles.first, // Show primary role
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getRoleColor(context),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
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

  List<String> _getRoles() {
    final roles = <String>[];
    if (involvedCompany.isDeveloper) roles.add('Developer');
    if (involvedCompany.isPublisher) roles.add('Publisher');
    if (involvedCompany.isPorting) roles.add('Porting');
    if (involvedCompany.isSupporting) roles.add('Support');
    return roles;
  }

  Color _getRoleColor(BuildContext context) {
    if (involvedCompany.isDeveloper) {
      return Colors.blue;
    } else if (involvedCompany.isPublisher) {
      return Colors.green;
    } else if (involvedCompany.isPorting) {
      return Colors.orange;
    } else if (involvedCompany.isSupporting) {
      return Colors.purple;
    } else {
      return Theme.of(context).colorScheme.primary;
    }
  }
}